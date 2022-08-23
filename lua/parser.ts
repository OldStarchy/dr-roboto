interface Token {
	type: string;
	value?: string | number | boolean;
}

class Tokenizer {
	rules: Array<{
		regex: RegExp;
		callback: (match: RegExpMatchArray) => Token | void;
	}>;
	tokens: Array<{ token: Token; location: { start: number; end: number } }>;
	index: number;

	constructor() {
		this.rules = [];
		this.tokens = [];
		this.index = 0;
	}

	addRule(
		regex: RegExp,
		callback: (match: RegExpMatchArray) => Token | void,
	) {
		this.rules.push({ regex, callback });
	}

	tokenize(text: string) {
		this.tokens = [];
		this.index = 0;

		while (this.index < text.length) {
			let matched = false;
			for (const rule of this.rules) {
				const regex = new RegExp(rule.regex.source, 'y');
				regex.lastIndex = this.index;
				const match = regex.exec(text);
				if (match) {
					const token = rule.callback(match);
					if (token) {
						this.tokens.push({
							token,
							location: {
								start: this.index,
								end: this.index + match[0].length,
							},
						});
					}
					this.index += match[0].length;
					matched = true;
					break;
				}
			}
			if (!matched) {
				const line =
					text.substring(0, this.index).split(/[\r\n]/).length - 1;
				const column =
					this.index - text.lastIndexOf(/[\r\n]/, this.index);
				const lineText = text.split(/[\r\n]/)[line];

				throw new Error(
					`Unexpected token at line ${line}, column ${column} in ${lineText}`,
				);
			}
		}
	}
}

const tokenizer = new Tokenizer();

tokenizer.addRule(/[ \t]+/, (lexer) => {
	return {
		type: 'whitespace',
		value: lexer[0],
	};
});

tokenizer.addRule(/[\r\n]/, (lexer) => {
	return {
		type: 'newline',
		value: lexer[0],
	};
});

tokenizer.addRule(/--.*(?=[\r\n]|$)/, (lexer) => {
	return {
		type: 'comment',
		value: lexer[0],
	};
});

const keywords = [
	'function',
	'end',
	'local',
	'if',
	'then',
	'else',
	'elseif',
	'while',
	'do',
	'repeat',
	'until',
	'for',
	'in',
	'break',
	'return',
	'not',
	'and',
	'or',
	'nil',
	'true',
	'false',
];

tokenizer.addRule(new RegExp(`(${keywords.join('|')})\\b`), (match) => {
	return {
		type: match[0],
	};
});

tokenizer.addRule(/[\d]+/, (match) => {
	return {
		type: 'number',
		value: match[0],
	};
});

tokenizer.addRule(/[\w]+/, (match) => {
	return {
		type: 'identifier',
		value: match[0],
	};
});

tokenizer.addRule(/"([^"]*)"/, (match) => {
	return {
		type: 'string',
		value: match[1],
	};
});

tokenizer.addRule(/'([^']*)'/, (match) => {
	return {
		type: 'string',
		value: match[1],
	};
});

const operators = [
	'+',
	'-',
	'*',
	'/',
	'^',
	'%',
	'..',
	'<',
	'>',
	'<=',
	'>=',
	'==',
	'~=',
];
function regexEscape(str: string) {
	return str.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
}

tokenizer.addRule(
	new RegExp(`(${operators.map(regexEscape).join('|')})`),
	(match) => {
		return {
			type: 'operator',
			value: match[0],
		};
	},
);

tokenizer.addRule(/[\[\]\(\)\{\}\.\:\,\;\=\+\/\-\*]/, (match) => {
	return {
		type: match[0],
	};
});

class Lexer {
	tokens: Array<{ token: Token; location: { start: number; end: number } }>;
	index: number;

	constructor(
		tokens: Array<{
			token: Token;
			location: { start: number; end: number };
		}>,
	) {
		this.tokens = tokens;
		this.index = 0;
	}

	peek() {
		return this.tokens[this.index];
	}

	advance() {
		this.index++;
	}

	next() {
		return this.tokens[this.index++];
	}

	accept(type: string) {
		if (this.peek()?.token.type === type) {
			return this.next();
		}
	}

	expect(type: string) {
		const token = this.accept(type);
		if (token) {
			return token;
		}
		throw new Error(`Expected token of type ${type}`);
	}

	acceptKeyword(keyword: string) {
		return this.accept(keyword);
	}

	expectKeyword(keyword: string) {
		const token = this.acceptKeyword(keyword);
		if (token) {
			return token;
		}
		throw new Error(`Expected keyword ${keyword}`);
	}

	acceptIdentifier() {
		return this.accept('identifier');
	}

	expectIdentifier() {
		const token = this.acceptIdentifier();
		if (token) {
			return token;
		}
		throw new Error(`Expected identifier`);
	}

	acceptNumber() {
		return this.accept('number');
	}

	expectNumber() {
		const token = this.acceptNumber();
		if (token) {
			return token;
		}
		throw new Error(`Expected number`);
	}

	acceptString() {
		return this.accept('string');
	}

	expectString() {
		const token = this.acceptString();
		if (token) {
			return token;
		}
		throw new Error(`Expected string`);
	}

	acceptNewline() {
		return this.accept('newline');
	}

	expectNewline() {
		const token = this.acceptNewline();
		if (token) {
			return token;
		}
		throw new Error(`Expected newline`);
	}

	acceptWhitespace() {
		return this.accept('whitespace');
	}

	expectWhitespace() {
		const token = this.acceptWhitespace();
		if (token) {
			return token;
		}
		throw new Error(`Expected whitespace`);
	}

	acceptComment() {
		return this.accept('comment');
	}

	expectComment() {
		const token = this.acceptComment();
		if (token) {
			return token;
		}
		throw new Error(`Expected comment`);
	}
}

type AstNode<T = Record<string, any>> = T & {
	type: string;
};

class Parser {
	lexer: Lexer;

	constructor(lexer: Lexer) {
		this.lexer = lexer;
	}

	parse() {
		try {
			return this.parseBlock();
		} catch (err) {
			console.error(err);

			const token = this.lexer.peek();
			if (token) {
				console.error(
					`Error parsing token ${token.token.type} at ${token.location.start}`,
				);
			}
		}
	}

	parseNewlines() {
		const newlines = [];
		let newline;
		while ((newline = this.lexer.acceptNewline())) {
			newlines.push(newline);
		}
		return {
			type: 'newlines',
			newlines,
		};
	}

	parseStatement(): AstNode {
		const token = this.lexer.peek();
		if (token.token.type === 'function') {
			return this.parseFunction();
		} else if (token.token.type === 'local') {
			return this.parseLocal();
		} else if (token.token.type === 'if') {
			return this.parseIf();
		} else if (token.token.type === 'while') {
			return this.parseWhile();
		} else if (token.token.type === 'repeat') {
			return this.parseRepeat();
		} else if (token.token.type === 'for') {
			return this.parseFor();
		} else if (token.token.type === 'break') {
			return this.parseBreak();
		} else if (token.token.type === 'return') {
			return this.parseReturn();
		} else if (token.token.type === 'newline') {
			return this.parseNewlines();
		} else if (token.token.type === 'comment') {
			return this.parseComment();
		} else if (token.token.type === 'whitespace') {
			return this.parseWhitespace();
		} else {
			return this.parseExpression();
		}
	}

	parseComment(): AstNode {
		const token = this.lexer.expectComment();
		return {
			type: 'comment',
			comment: token.token.value,
		};
	}

	parseWhitespace(): AstNode {
		const token = this.lexer.expectWhitespace();
		return {
			type: 'whitespace',
			whitespace: token.token.value,
		};
	}

	parseBlock(): AstNode {
		const statements = [];
		const endings = ['end', 'else', 'elseif', 'until'];
		while (!endings.includes(this.lexer.peek()?.token.type)) {
			statements.push(this.parseStatement());

			const next = this.lexer.peek();
			if (
				next.token.type == 'newline' ||
				next.token.type == 'comment' ||
				next.token.type == 'whitespace' ||
				next.token.type == ';'
			) {
				this.lexer.advance();
			}
		}

		//consume ending
		this.lexer.advance();

		return {
			type: 'block',
			statements,
		};
	}

	parseFunction(): AstNode {
		this.lexer.expectKeyword('function');
		this.lexer.expectWhitespace();
		const name = this.lexer.expectIdentifier();
		this.lexer.acceptWhitespace();
		this.lexer.expect('(');
		this.lexer.acceptWhitespace();
		const parameters = [];
		while (!this.lexer.accept(')')) {
			parameters.push(this.lexer.expectIdentifier());
			this.lexer.acceptWhitespace();
			this.lexer.accept(',');
			this.lexer.acceptWhitespace();
		}
		const body = this.parseBlock();
		this.lexer.expectKeyword('end');
		return {
			type: 'function',
			name: name.token.value,
			parameters,
			body,
		};
	}

	parseLocal(): AstNode {
		this.lexer.expectKeyword('local');
		this.lexer.expectWhitespace();
		const name = this.lexer.expectIdentifier();
		this.lexer.acceptWhitespace();
		this.lexer.expect('=');
		this.lexer.acceptWhitespace();
		const value = this.parseExpression();
		return {
			type: 'local',
			name: name.token.value,
			value,
		};
	}

	parseIf(): AstNode {
		this.lexer.expectKeyword('if');
		this.lexer.expectWhitespace();
		const condition = this.parseExpression();
		this.lexer.acceptWhitespace();
		this.lexer.expectKeyword('then');
		const body = this.parseBlock();
		const elseIfs = [];
		while (this.lexer.acceptKeyword('elseif')) {
			const condition = this.parseExpression();
			this.lexer.expectKeyword('then');
			const body = this.parseBlock();
			elseIfs.push({ condition, body });
		}
		let elseBody = null;
		if (this.lexer.acceptKeyword('else')) {
			elseBody = this.parseBlock();
		}
		this.lexer.expectKeyword('end');
		return {
			type: 'if',
			condition,
			body,
			elseIfs,
			elseBody,
		};
	}

	parseWhile(): AstNode {
		this.lexer.expectKeyword('while');
		const condition = this.parseExpression();
		this.lexer.expectKeyword('do');
		const body = this.parseBlock();
		this.lexer.expectKeyword('end');
		return {
			type: 'while',
			condition,
			body,
		};
	}

	parseRepeat(): AstNode {
		this.lexer.expectKeyword('repeat');
		const body = this.parseBlock();
		this.lexer.expectKeyword('until');
		const condition = this.parseExpression();
		return {
			type: 'repeat',
			condition,
			body,
		};
	}

	parseFor(): AstNode {
		this.lexer.expectKeyword('for');
		const name = this.lexer.expectIdentifier();
		this.lexer.expect('=');
		const start = this.parseExpression();
		this.lexer.expect(',');
		const end = this.parseExpression();
		let step = null;
		if (this.lexer.accept(',')) {
			step = this.parseExpression();
		}
		this.lexer.expectKeyword('do');
		const body = this.parseBlock();
		this.lexer.expectKeyword('end');
		return {
			type: 'for',
			name: name.token.value,
			start,
			end,
			step,
			body,
		};
	}

	parseBreak(): AstNode {
		this.lexer.expectKeyword('break');
		return {
			type: 'break',
		};
	}

	parseReturn(): AstNode {
		this.lexer.expectKeyword('return');
		const values = [];
		while (this.lexer.peek()) {
			values.push(this.parseExpression());
		}
		return {
			type: 'return',
			values,
		};
	}

	parseExpression(): AstNode {
		return this.parseBinaryExpression();
	}

	parseBinaryExpression(): AstNode {
		return this.parseBinaryExpressionWithPrecedence(-1);
	}

	parseBinaryExpressionWithPrecedence(precedence: number): AstNode {
		let left = this.parseUnaryExpression();
		while (true) {
			this.lexer.acceptWhitespace();
			const token = this.lexer.peek();
			if (token.token.type === 'operator') {
				const op = token.token.value as string;
				const opPrecedence = getPrecedence(op);
				if (opPrecedence > precedence) {
					this.lexer.advance();
					this.lexer.acceptWhitespace();
					const right =
						this.parseBinaryExpressionWithPrecedence(opPrecedence);
					left = {
						type: 'binary',
						operator: op,
						left,
						right,
					};
					continue;
				}
			}
			break;
		}
		return left;
	}

	parseUnaryExpression(): AstNode {
		const token = this.lexer.peek();
		if (token.token.type === 'operator') {
			const op = token.token.value;
			if (op === '-' || op === '#') {
				this.lexer.advance();
				const right = this.parseUnaryExpression();
				return {
					type: 'unary',
					operator: op,
					right,
				};
			}
		}
		return this.parsePrimaryExpression();
	}

	parsePrimaryExpression(): AstNode {
		const token = this.lexer.peek();
		if (token.token.type === 'identifier') {
			this.lexer.advance();
			return {
				type: 'identifier',
				name: token.token.value,
			};
		} else if (token.token.type === 'number') {
			this.lexer.advance();
			return {
				type: 'number',
				value: token.token.value,
			};
		} else if (token.token.type === 'string') {
			this.lexer.advance();
			return {
				type: 'string',
				value: token.token.value,
			};
		} else if (token.token.type === 'boolean') {
			this.lexer.advance();
			return {
				type: 'boolean',
				value: token.token.value,
			};
		} else if (token.token.type === 'nil') {
			this.lexer.advance();
			return {
				type: 'nil',
			};
		} else if (token.token.type === 'operator') {
			const op = token.token.value;
			if (op === '(') {
				this.lexer.advance();
				const expr = this.parseExpression();
				this.lexer.expect(')');
				return expr;
			}
		} else if (token.token.type === 'keyword') {
			const keyword = token.token.value;
			if (keyword === 'function') {
				return this.parseFunction();
			}
		}
		throw new Error(
			`Unexpected token ${token.token.type} ${token.token.value}`,
		);
	}
}

function getPrecedence(op: string) {
	switch (op) {
		case '+':
		case '-':
			return 1;
		case '*':
		case '/':
			return 2;
		default:
			return 0;
	}
}

export default Parser;

const test = `
-- This is a comment
function test()
	local a = 1
	if a == 1 then
		return 1
	elseif a == 2 then
		return 2
	else
		return 3
	end
end
`;

tokenizer.tokenize(test);

for (const token of tokenizer.tokens) {
	console.log(token.token.type + ' "' + (token.token?.value ?? '') + '"');
}

const lexer = new Lexer(tokenizer.tokens);
const parser = new Parser(lexer);
const ast = parser.parse();
console.log(JSON.stringify(ast, null, 2));
