/** @noSelfInFile */
const LOG_NONE = -1;
const LOG_SOME = 0;
const LOG_ALL = 1;

let logLevel = 1;

function findTests(rootDir: string): string[] {
	const results: string[] = [];

	const dirsToCheck = [rootDir];

	while (dirsToCheck.length > 0) {
		const currentDirectory = table.remove(dirsToCheck);

		if (fs.isDir(currentDirectory)) {
			const files = fs.list(currentDirectory);

			for (const file of files) {
				if (fs.isDir(currentDirectory + '/' + file)) {
					if (file != '.' && file != '..') {
						table.insert(
							dirsToCheck,
							currentDirectory + '/' + file
						);
					}
				} else if (string.sub(file, -'Test.lua'.length) == 'Test.lua') {
					table.insert(results, currentDirectory + '/' + file);
				}
			}
		}
	}

	return results;
}

function loadAllTests() {
	const tests = [];
	const env = setmetatable(
		{
			test: function(...args: any[]) {
				const testObjs = createTests(...args);

				for (const i in testObjs) {
					table.insert(tests, testObjs[i]);
				}
			}
		},
		{
			__index: getfenv()
		}
	);

	const files = findTests('.');
	for (const file of files) {
		pcall(() => {
			const [chunk, err] = loadfile(file, env);
			if (chunk == null) {
				throw `Could not load test file: ${file}: ${err}`;
			}
			chunk();
		});
	}

	return tests;
}

const args = arguments;

if (args.length > 0) {
	if (args[1] != null) {
		logLevel = tonumber(args[1]);
		table.remove(args, 1);
	}
}

if (args.length == 0) {
	console.log('Running startup tests...');
	console.log();
	let allTests = loadAllTests();
	const totalCount = allTests.length;
	allTests = filterTests(allTests, 'Crafter.*', true);
	const runCount = allTests.length;

	runTests(allTests, logLevel);

	if (runCount < totalCount) {
		console.log('(skipped ' + (totalCount - runCount) + ')');
	}
} else {
	let allTests = loadAllTests();
	allTests = filterTests(allTests, args);
	runTests(allTests, logLevel);
}
