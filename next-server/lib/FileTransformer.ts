export default interface FileTransformer {
	transform(filename: string, fileContent: string): string;
}
