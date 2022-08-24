import { basename } from 'path';
import FileTransformer from './FileTransformer';

export default class ValueInjectorFileTransformer implements FileTransformer {
	constructor(private readonly values: Record<string, string>) {}

	transform(filename: string, fileContent: string): string {
		if (basename(filename) === 'tap.lua') {
			return fileContent.replace(/\%\%([A-Z_]*?)\%\%/g, (match, key) => {
				return this.values[key] || match;
			});
		}

		return fileContent;
	}
}
