import fs from 'fs/promises';
import path from 'path';
import PackageRegistry from './PackageRegistry';
import { readPackage, TapFile } from './TapFile';

export default class FilePackageRegistry implements PackageRegistry {
	constructor(private readonly root: string) {}

	async getPackage(name: string): Promise<TapFile | null> {
		const fullPath = path.join(this.root, name, 'tap.json');

		const [tapFile, errors] = readPackage(fullPath);

		return tapFile;
	}

	async getPackages(): Promise<TapFile[]> {
		const entries = await fs.readdir(this.root);

		return (
			await Promise.all(
				entries.map(async (entry) => {
					const fullPath = path.join(this.root, entry);

					if (await (await fs.stat(fullPath)).isDirectory()) {
						const tapFilePath = path.join(fullPath, 'tap.json');

						const [tapFile, errors] = await readPackage(
							tapFilePath,
						);

						if (errors) {
							return null;
						}

						return tapFile;
					}

					return null;
				}),
			)
		).filter((pkg): pkg is TapFile => pkg !== null);
	}
}
