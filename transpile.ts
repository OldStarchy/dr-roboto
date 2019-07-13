// @ts-check

//Compile this by running the build task (after npm install)

import * as tstl from 'typescript-to-lua';
import * as ts from 'typescript';
import * as fs from 'fs';

class CustomTransformer extends tstl.LuaTransformer {
	public constructor(program: ts.Program) {
		super(program);
	}

	public transformArrayLiteral(
		expression: ts.ArrayLiteralExpression
	): tstl.ExpressionVisitResult {
		// Call the original transformArrayLiteral first, to get the default result.
		// You could also skip this and create your own table expression with tstl.createTableExpression()
		const result = super.transformArrayLiteral(
			expression
		) as tstl.TableExpression;

		// Create the 'n = <elements.length>' node
		const nIdentifier = tstl.createIdentifier('n');
		const nValue = tstl.createNumericLiteral(expression.elements.length);
		const tableField = tstl.createTableFieldExpression(nValue, nIdentifier);

		// Add the extra table field we created to the default transformation result
		if (result.fields === undefined) {
			result.fields = [];
		}
		result.fields.push(tableField);

		return result;
	}
}

function compile() {
	console.log('compiling');
	const options: tstl.CompilerOptions = {
		luaTarget: tstl.LuaTarget.Lua51,
		outDir: 'dist'
	};
	const program = ts.createProgram({
		rootNames: ['src/test.ts'],
		options
	});

	const transformer = new CustomTransformer(program);
	const printer = new tstl.LuaPrinter(options);

	const result = tstl.transpile({
		program,
		transformer,
		printer
	});

	result.transpiledFiles.forEach(file => {
		fs.writeFileSync(
			file.fileName.replace('src', 'dist').replace('.ts', '.lua'),
			file.lua
		);
	});
}

compile();

fs.watch('src/', (e, filename) => {
	console.log(e);
	compile();
});
console.log('watching');
// console.log(result.diagnostics);
// console.log(result.transpiledFiles);
// // Emit result
// console.log(tstl.emitTranspiledFiles(options, result.transpiledFiles));
