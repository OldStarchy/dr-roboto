import AppContext from './AppContext';

export default interface FileTransformer {
	transform(
		context: AppContext,
		filename: string,
		fileContent: string,
	): string;
}
