import * as tstl from 'typescript-to-lua';
import * as ts from 'typescript';
import {
	StatementVisitResult,
	createAssignmentStatement,
	SyntaxKind,
	createCallExpression,
	createIdentifier,
	createTableIndexExpression,
	createStringLiteral,
	ExpressionVisitResult
} from 'typescript-to-lua';
import { TSTLErrors } from 'typescript-to-lua/dist/TSTLErrors';
import {
	TSHelper as tsHelper,
	ContextType
} from 'typescript-to-lua/dist/TSHelper';
import { Decorator, DecoratorKind } from 'typescript-to-lua/dist/Decorator';

export class CustomTransformer extends tstl.LuaTransformer {
	public constructor(program: ts.Program) {
		super(program);
	}
	public transformClassDeclaration(
		statement: ts.ClassLikeDeclaration,
		nameOverride?: tstl.Identifier
	): StatementVisitResult {
		// return super.transformClassDeclaration(statement, nameOverride);
		this.classStack.push(statement);

		if (statement.name === undefined && nameOverride === undefined) {
			throw TSTLErrors.MissingClassName(statement);
		}

		let className: tstl.Identifier;
		let classNameText: string;
		if (nameOverride !== undefined) {
			className = nameOverride;
			classNameText = nameOverride.text;
		} else if (statement.name !== undefined) {
			className = this.transformIdentifier(statement.name);
			classNameText = statement.name.text;
		} else {
			throw TSTLErrors.MissingClassName(statement);
		}

		const decorators = tsHelper.getCustomDecorators(
			this.checker.getTypeAtLocation(statement),
			this.checker
		);

		// Find out if this class is extension of existing class
		const extensionDirective = decorators.get(DecoratorKind.Extension);
		const isExtension = extensionDirective !== undefined;

		const isMetaExtension = decorators.has(DecoratorKind.MetaExtension);

		if (isExtension && isMetaExtension) {
			throw TSTLErrors.InvalidExtensionMetaExtension(statement);
		}

		if (
			(isExtension || isMetaExtension) &&
			this.getIdentifierExportScope(className) !== undefined
		) {
			// Cannot export extension classes
			throw TSTLErrors.InvalidExportsExtension(statement);
		}

		// Get type that is extended
		const extendsType = tsHelper.getExtendedType(statement, this.checker);

		if (!(isExtension || isMetaExtension) && extendsType) {
			// Non-extensions cannot extend extension classes
			const extendsDecorators = tsHelper.getCustomDecorators(
				extendsType,
				this.checker
			);
			if (
				extendsDecorators.has(DecoratorKind.Extension) ||
				extendsDecorators.has(DecoratorKind.MetaExtension)
			) {
				throw TSTLErrors.InvalidExtendsExtension(statement);
			}
		}

		// You cannot extend LuaTable classes
		if (extendsType) {
			const decorators = tsHelper.getCustomDecorators(
				extendsType,
				this.checker
			);
			if (decorators.has(DecoratorKind.LuaTable)) {
				throw TSTLErrors.InvalidExtendsLuaTable(statement);
			}
		}

		// LuaTable classes must be ambient
		if (
			decorators.has(DecoratorKind.LuaTable) &&
			!tsHelper.isAmbient(statement)
		) {
			throw TSTLErrors.ForbiddenLuaTableNonDeclaration(statement);
		}

		// Get all properties with value
		const properties = statement.members
			.filter(ts.isPropertyDeclaration)
			.filter(member => member.initializer);

		// Divide properties into static and non-static
		const staticFields = properties.filter(tsHelper.isStatic);
		const instanceFields = properties.filter(
			prop => !tsHelper.isStatic(prop)
		);

		const result: tstl.Statement[] = [];

		// Overwrite the original className with the class we are overriding for extensions
		if (isMetaExtension) {
			if (!extendsType) {
				throw TSTLErrors.MissingMetaExtension(statement);
			}

			const extendsName = tstl.createStringLiteral(extendsType.symbol
				.escapedName as string);
			className = tstl.createIdentifier('__meta__' + extendsName.value);

			// local className = debug.getregistry()["extendsName"]
			const assignDebugCallIndex = tstl.createVariableDeclarationStatement(
				className,
				tstl.createTableIndexExpression(
					tstl.createCallExpression(
						tstl.createTableIndexExpression(
							tstl.createIdentifier('debug'),
							tstl.createStringLiteral('getregistry')
						),
						[]
					),
					extendsName
				),
				statement
			);

			result.push(assignDebugCallIndex);
		}

		if (extensionDirective !== undefined) {
			const extensionNameArg = extensionDirective.args[0];
			if (extensionNameArg) {
				className = tstl.createIdentifier(extensionNameArg);
			} else if (extendsType) {
				className = tstl.createIdentifier(extendsType.symbol
					.escapedName as string);
			}
		}

		let localClassName: tstl.Identifier;
		if (this.isUnsafeName(className.text)) {
			localClassName = tstl.createIdentifier(
				this.createSafeName(className.text),
				undefined,
				className.symbolId
			);
			tstl.setNodePosition(localClassName, className);
		} else {
			localClassName = className;
		}

		if (!isExtension && !isMetaExtension) {
			if (extendsType) {
				// result.push(
				// 	createAssignmentStatement(
				// 		className,
				// 		createCallExpression(
				// 			createIdentifier('Class'),
				// 			extendsType
				// 		)
				// 	)
				// );
			} else {
				result.push(
					createAssignmentStatement(
						className,

						createCallExpression(createIdentifier('Class'))
					)
				);
			}
			result.push(
				createAssignmentStatement(
					createTableIndexExpression(
						className,
						createStringLiteral('ClassName')
					),
					createStringLiteral(classNameText)
				)
			);
		} else {
			for (const f of instanceFields) {
				const fieldName = this.transformPropertyName(f.name);

				const value =
					f.initializer !== undefined
						? this.transformExpression(f.initializer)
						: undefined;

				// className["fieldName"]
				const classField = tstl.createTableIndexExpression(
					tstl.cloneIdentifier(className),
					fieldName
				);

				// className["fieldName"] = value;
				const assignClassField = tstl.createAssignmentStatement(
					classField,
					value
				);

				result.push(assignClassField);
			}
		}

		// Find first constructor with body
		if (!isExtension && !isMetaExtension) {
			const constructor = statement.members.filter(
				n => ts.isConstructorDeclaration(n) && n.body
			)[0] as ts.ConstructorDeclaration;
			if (constructor) {
				// Add constructor plus initialization of instance fields
				const constructorResult = this.transformConstructorDeclaration(
					constructor,
					localClassName,
					instanceFields,
					statement
				);
				result.push(
					...this.statementVisitResultToArray(constructorResult)
				);
			} else if (!extendsType) {
				// Generate a constructor if none was defined in a base class
				const constructorResult = this.transformConstructorDeclaration(
					ts.createConstructor([], [], [], ts.createBlock([], true)),
					localClassName,
					instanceFields,
					statement
				);
				result.push(
					...this.statementVisitResultToArray(constructorResult)
				);
			} else if (
				instanceFields.length > 0 ||
				statement.members.some(m =>
					tsHelper.isGetAccessorOverride(m, statement, this.checker)
				)
			) {
				// Generate a constructor if none was defined in a class with instance fields that need initialization
				// localClassName.constructor = function(self, ...)
				//     baseClassName.constructor(self, ...)
				//     ...
				const constructorBody = this.transformClassInstanceFields(
					statement,
					instanceFields
				);
				const superCall = tstl.createExpressionStatement(
					tstl.createCallExpression(
						this.transformSuperKeyword(ts.createSuper()),
						[this.createSelfIdentifier(), tstl.createDotsLiteral()]
					)
				);
				constructorBody.unshift(superCall);
				const constructorFunction = tstl.createFunctionExpression(
					tstl.createBlock(constructorBody),
					[this.createSelfIdentifier()],
					tstl.createDotsLiteral(),
					undefined,
					tstl.FunctionExpressionFlags.Declaration
				);
				result.push(
					tstl.createAssignmentStatement(
						this.createConstructorName(localClassName),
						constructorFunction,
						statement
					)
				);
			}
		}

		// Transform get accessors
		statement.members.filter(ts.isGetAccessor).forEach(getAccessor => {
			const transformResult = this.transformGetAccessorDeclaration(
				getAccessor,
				localClassName
			);
			result.push(...this.statementVisitResultToArray(transformResult));
		});

		// Transform set accessors
		statement.members.filter(ts.isSetAccessor).forEach(setAccessor => {
			const transformResult = this.transformSetAccessorDeclaration(
				setAccessor,
				localClassName
			);
			result.push(...this.statementVisitResultToArray(transformResult));
		});

		// Transform methods
		statement.members.filter(ts.isMethodDeclaration).forEach(method => {
			const methodResult = this.transformMethodDeclaration(
				method,
				localClassName,
				isExtension || isMetaExtension
			);
			result.push(...this.statementVisitResultToArray(methodResult));
		});

		// Add static declarations
		for (const field of staticFields) {
			this.validateClassElement(field);

			const fieldName = this.transformPropertyName(field.name);
			const value = field.initializer
				? this.transformExpression(field.initializer)
				: undefined;

			const classField = tstl.createTableIndexExpression(
				tstl.cloneIdentifier(localClassName),
				fieldName
			);

			const fieldAssign = tstl.createAssignmentStatement(
				classField,
				value
			);

			result.push(fieldAssign);
		}

		const decorationStatement = this.createConstructorDecorationStatement(
			statement
		);
		if (decorationStatement) {
			result.push(decorationStatement);
		}

		this.classStack.pop();

		return result;
	}

	public transformSuperKeyword(
		expression: ts.SuperExpression
	): ExpressionVisitResult {
		const classDeclaration = this.classStack[this.classStack.length - 1];
		const typeNode = tsHelper.getExtendedTypeNode(
			classDeclaration,
			this.checker
		);
		if (typeNode === undefined) {
			throw TSTLErrors.UnknownSuperType(expression);
		}

		const extendsExpression = typeNode.expression;
		let baseClassName: tstl.AssignmentLeftHandSideExpression;
		if (ts.isIdentifier(extendsExpression)) {
			// Use "baseClassName" if base is a simple identifier
			baseClassName = this.transformIdentifier(extendsExpression);
		} else {
			if (classDeclaration.name === undefined) {
				throw TSTLErrors.MissingClassName(expression);
			}

			// Use "className.____super" if the base is not a simple identifier
			baseClassName = tstl.createTableIndexExpression(
				this.transformIdentifier(classDeclaration.name),
				tstl.createStringLiteral('____super'),
				expression
			);
		}
		return baseClassName;
	}

	private createConstructorName(
		className: tstl.Identifier
	): tstl.TableIndexExpression {
		return tstl.createTableIndexExpression(
			tstl.cloneIdentifier(className),
			tstl.createStringLiteral('constructor')
		);
	}

	public transformCallExpression(
		expression: ts.CallExpression
	): ExpressionVisitResult {
		// Check for calls on primitives to override
		let parameters: tstl.Expression[] = [];

		const isTupleReturn = tsHelper.isTupleReturnCall(
			expression,
			this.checker
		);
		const isTupleReturnForward =
			expression.parent &&
			ts.isReturnStatement(expression.parent) &&
			tsHelper.isInTupleReturnFunction(expression, this.checker);
		const isInDestructingAssignment = tsHelper.isInDestructingAssignment(
			expression
		);
		const isInSpread =
			expression.parent && ts.isSpreadElement(expression.parent);
		const returnValueIsUsed =
			expression.parent && !ts.isExpressionStatement(expression.parent);
		const wrapResult =
			isTupleReturn &&
			!isTupleReturnForward &&
			!isInDestructingAssignment &&
			!isInSpread &&
			returnValueIsUsed;

		if (ts.isPropertyAccessExpression(expression.expression)) {
			const result = this.transformPropertyCall(expression);
			return wrapResult ? this.wrapInTable(result) : result;
		}

		if (ts.isElementAccessExpression(expression.expression)) {
			const result = this.transformElementCall(expression);
			return wrapResult ? this.wrapInTable(result) : result;
		}

		const signature = this.checker.getResolvedSignature(expression);

		// Handle super calls properly
		if (expression.expression.kind === ts.SyntaxKind.SuperKeyword) {
			parameters = this.transformArguments(
				expression.arguments,
				signature,
				ts.createThis()
			);

			return tstl.createCallExpression(
				tstl.createTableIndexExpression(
					this.transformSuperKeyword(ts.createSuper()),
					tstl.createStringLiteral('constructor')
				),
				parameters
			);
		}

		const expressionType = this.checker.getTypeAtLocation(
			expression.expression
		);
		if (
			tsHelper.isStandardLibraryType(
				expressionType,
				undefined,
				this.program
			)
		) {
			const result = this.transformGlobalFunctionCall(expression);
			if (result) {
				return result;
			}
		}

		const callPath = this.transformExpression(expression.expression);
		const signatureDeclaration = signature && signature.getDeclaration();
		parameters = this.transformArguments(expression.arguments, signature);

		const callExpression = tstl.createCallExpression(
			callPath,
			parameters,
			expression
		);
		return wrapResult ? this.wrapInTable(callExpression) : callExpression;
	}

	public transformGetAccessorDeclaration(
		getAccessor: ts.GetAccessorDeclaration,
		className: tstl.Identifier
	): StatementVisitResult {
		if (getAccessor.body === undefined) {
			return undefined;
		}

		this.validateClassElement(getAccessor);

		const name = this.transformIdentifier(
			getAccessor.name as ts.Identifier
		);

		const [body] = this.transformFunctionBody(
			getAccessor.parameters,
			getAccessor.body
		);
		const accessorFunction = tstl.createFunctionExpression(
			tstl.createBlock(body),
			[this.createSelfIdentifier()],
			undefined,
			undefined,
			tstl.FunctionExpressionFlags.Declaration
		);

		const methodTable = tstl.cloneIdentifier(className);

		const classGetters = tstl.createTableIndexExpression(
			methodTable,
			tstl.createStringLiteral('____getters')
		);
		const getter = tstl.createTableIndexExpression(
			classGetters,
			tstl.createStringLiteral(name.text)
		);
		const assignGetter = tstl.createAssignmentStatement(
			getter,
			accessorFunction,
			getAccessor
		);
		return assignGetter;
	}

	public transformSetAccessorDeclaration(
		setAccessor: ts.SetAccessorDeclaration,
		className: tstl.Identifier
	): StatementVisitResult {
		if (setAccessor.body === undefined) {
			return undefined;
		}

		this.validateClassElement(setAccessor);

		const name = this.transformIdentifier(
			setAccessor.name as ts.Identifier
		);

		const [params, dot, restParam] = this.transformParameters(
			setAccessor.parameters,
			this.createSelfIdentifier()
		);

		const [body] = this.transformFunctionBody(
			setAccessor.parameters,
			setAccessor.body,
			restParam
		);
		const accessorFunction = tstl.createFunctionExpression(
			tstl.createBlock(body),
			params,
			dot,
			restParam,
			tstl.FunctionExpressionFlags.Declaration
		);

		const methodTable = tstl.cloneIdentifier(className);

		const classSetters = tstl.createTableIndexExpression(
			methodTable,
			tstl.createStringLiteral('____setters')
		);
		const setter = tstl.createTableIndexExpression(
			classSetters,
			tstl.createStringLiteral(name.text)
		);
		const assignSetter = tstl.createAssignmentStatement(
			setter,
			accessorFunction,
			setAccessor
		);
		return assignSetter;
	}
	public transformMethodDeclaration(
		node: ts.MethodDeclaration,
		className: tstl.Identifier,
		noPrototype: boolean
	): StatementVisitResult {
		// Don't transform methods without body (overload declarations)
		if (!node.body) {
			return undefined;
		}

		this.validateClassElement(node);

		let methodName = this.transformPropertyName(node.name);

		const type = this.checker.getTypeAtLocation(node);
		const context =
			!tsHelper.isStatic(node) && !tsHelper.isAmbient(node)
				? this.createSelfIdentifier()
				: undefined;
		const [paramNames, dots, restParamName] = this.transformParameters(
			node.parameters,
			context
		);

		const [body] = this.transformFunctionBody(
			node.parameters,
			node.body,
			restParamName
		);
		const functionExpression = tstl.createFunctionExpression(
			tstl.createBlock(body),
			paramNames,
			dots,
			restParamName,
			tstl.FunctionExpressionFlags.Declaration,
			node.body
		);

		const methodTable = tstl.cloneIdentifier(className);

		return tstl.createAssignmentStatement(
			tstl.createTableIndexExpression(methodTable, methodName),
			functionExpression,
			node
		);
	}

	public transformNewExpression(
		node: ts.NewExpression
	): ExpressionVisitResult {
		const name = this.transformExpression(node.expression);
		const signature = this.checker.getResolvedSignature(node);
		const params = node.arguments
			? this.transformArguments(node.arguments, signature)
			: [tstl.createBooleanLiteral(true)];

		const type = this.checker.getTypeAtLocation(node);
		const classDecorators = tsHelper.getCustomDecorators(
			type,
			this.checker
		);

		this.checkForLuaLibType(type);

		if (
			classDecorators.has(DecoratorKind.Extension) ||
			classDecorators.has(DecoratorKind.MetaExtension)
		) {
			throw TSTLErrors.InvalidNewExpressionOnExtension(node);
		}

		if (classDecorators.has(DecoratorKind.CustomConstructor)) {
			const customDecorator = classDecorators.get(
				DecoratorKind.CustomConstructor
			);
			if (
				customDecorator === undefined ||
				customDecorator.args[0] === undefined
			) {
				throw TSTLErrors.InvalidDecoratorArgumentNumber(
					'@customConstructor',
					0,
					1,
					node
				);
			}

			return tstl.createCallExpression(
				tstl.createIdentifier(customDecorator.args[0]),
				this.transformArguments(node.arguments || []),
				node
			);
		}

		if (classDecorators.has(DecoratorKind.LuaTable)) {
			if (node.arguments && node.arguments.length > 0) {
				throw TSTLErrors.ForbiddenLuaTableUseException(
					'No parameters are allowed when constructing a LuaTable object.',
					node
				);
			} else {
				return tstl.createTableExpression();
			}
		}

		return tstl.createCallExpression(name, params, node);
	}
	public transformImportDeclaration(
		statement: ts.ImportDeclaration
	): StatementVisitResult {
		throw TSTLErrors.DefaultImportsNotSupported(statement);
	}

	public transformIdentifier(identifier: ts.Identifier): tstl.Identifier {
		if (identifier.originalKeywordKind === ts.SyntaxKind.UndefinedKeyword) {
			// TODO this is a hack that allows use to keep Identifier
			// as return time as changing that would break a lot of stuff.
			// But this should be changed to return tstl.createNilLiteral()
			// at some point.
			return tstl.createIdentifier('nil');
		}

		let text = this.hasUnsafeIdentifierName(identifier)
			? this.createSafeName(this.getIdentifierText(identifier))
			: this.getIdentifierText(identifier);

		if (text == 'arguments') {
			text = '{...}';
		}
		const symbolId = this.getIdentifierSymbolId(identifier);
		return tstl.createIdentifier(text, identifier, symbolId);
	}
}
