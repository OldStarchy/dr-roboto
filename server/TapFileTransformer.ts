import { basename } from 'path';
import AppContext from './AppContext';
import FileTransformer from './FileTransformer';

export default class TapFileTransformer implements FileTransformer {
	transform(
		context: AppContext,
		filename: string,
		fileContent: string,
	): string {
		if (basename(filename) === 'tap.lua') {
			return fileContent
				.replace('%%PUBLIC_PROTO%%', context.publicProto)
				.replace('%%PUBLIC_DOMAIN%%', context.publicDomain)
				.replace('%%PUBLIC_PATH%%', '');
		}

		return fileContent;
	}
}
