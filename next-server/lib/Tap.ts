import fs from 'fs/promises';
import { join } from 'path';
import { satisfies, SemVer } from 'semver';
import FileTransformer from './FileTransformer';

interface DirectoryInfo {
	type: 'directory';
	entries: (DirectorySummary | FileSummary)[];
}

interface FileInfo {
	type: 'file';
	content: string;
	mtime: number;
}

interface DirectorySummary {
	type: 'directory';
	name: string;
}

interface FileSummary {
	type: 'file';
	name: string;
	mtime: number;
}

type FileResponse = FileInfo | string;
type DirectoryResponse = DirectoryInfo | null;

export type Response = FileResponse | DirectoryResponse;

export default class Tap {
	private fileTransformers: FileTransformer[] = [];

	constructor(
		private readonly version: SemVer | null,
		private readonly rootPath: string,
	) {
		if (this.version && !satisfies(this.version, '>= 0.3.0')) {
			throw new Error('Unsupported version');
		}
	}

	addFileTransformer(transformer: FileTransformer) {
		this.fileTransformers.push(transformer);
	}

	async readPath(
		path: string,
	): Promise<DirectoryInfo | FileInfo | null | string> {
		this.validatePath(path);
		const fullPath = this.getPhysicalPath(path);

		const info = await fs.stat(fullPath);
		if (info.isDirectory()) {
			return await this.readDir(fullPath);
		}

		return await this.readFile(fullPath);
	}

	private validatePath(path: string) {
		const parts = path.split('/');
		if (parts.some((part) => part === '.' || part === '..')) {
			throw new Error('Invalid path');
		}
	}

	private getPhysicalPath(path: string) {
		return join(this.rootPath, path);
	}

	private async readDir(fullPath: string): Promise<DirectoryInfo | null> {
		if (this.version === null) {
			return null;
		}

		const entries = (await fs.readdir(fullPath)).filter((file) => {
			return file !== '.' && file !== '..';
		});

		return {
			type: 'directory',
			entries: await Promise.all(
				entries.map(async (file) => {
					const stat = await fs.stat(join(fullPath, file));

					if (stat.isDirectory()) {
						return {
							type: 'directory',
							name: file,
						};
					} else {
						return {
							type: 'file',
							name: file,
							mtime: stat.mtime.getTime(),
						};
					}
				}),
			),
		};
	}

	private async transformContent(fullPath: string, content: string) {
		for (const transformer of this.fileTransformers) {
			content = await transformer.transform(fullPath, content);
		}

		return content;
	}

	private async readFile(fullPath: string): Promise<string | FileInfo> {
		const content = await fs.readFile(fullPath, 'utf8');
		const stat = await fs.stat(fullPath);

		const transformedContent = await this.transformContent(
			fullPath,
			content,
		);

		if (this.version === null) {
			return transformedContent;
		}

		return {
			type: 'file',
			content,
			mtime: stat.mtime.getTime(),
		};
	}
}
