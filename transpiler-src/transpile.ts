// @ts-check

//Compile this by running the build task (after npm install)

import * as tstl from 'typescript-to-lua';
import * as ts from 'typescript';
import * as fs from 'fs';
import { CustomTransformer } from './CustomTransformer';
import { debounce } from 'debounce';

function compile(filename?: string) {
	const options: tstl.CompilerOptions = {
		luaTarget: tstl.LuaTarget.Lua51
	};
	const program = ts.createProgram({
		rootNames: filename
			? [`src/${filename}`].concat(
					...fs
						.readdirSync('src/')
						.filter(fname => fname.endsWith('.d.ts'))
						.map(fname => 'src/' + fname)
			  )
			: fs
					.readdirSync('src/')
					.filter(fname => fname.endsWith('.ts'))
					.map(fname => 'src/' + fname),
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
		const outFName = file.fileName
			.replace('src', 'dist')
			.replace('.ts', '.lua');
		if (
			file.lua
				.split('\n')
				.map(line => line.trim())
				.filter(line => line !== '' && !line.startsWith('--')).length >
			0
		)
			fs.writeFileSync(outFName, file.lua);
		else {
			if (fs.existsSync(outFName)) {
				fs.unlinkSync(outFName);
			}
		}
	});
}

const onChange = debounce((e, filename) => {
	if (e == 'change') {
		process.stdout.write(`Change in ${filename}; recompiling... `);
		if (filename.endsWith('.d.ts')) compile();
		else compile(filename);
		console.log('done.');
	} else {
		console.log(`Unexpected event "${e}".`);
	}
}, 500);

process.stdout.write(`Compiling... `);
compile();
console.log('done.');

fs.watch('src/', onChange);
console.log('Watching for changes');
// console.log(result.diagnostics);
// console.log(result.transpiledFiles);
// // Emit result
// console.log(tstl.emitTranspiledFiles(options, result.transpiledFiles));
