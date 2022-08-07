import crypto from 'crypto';
import fs from 'fs';
import { Context } from 'koa';
import path from 'path';
import Authenticator from './Authenticator';
import BasicAuthHelper from './BasicAuthHelper';

interface Auth {
	username: string;
	passkey: string;
}

class FileAuthenticator implements Authenticator {
	constructor(private authFile: string) {
		if (path.extname(authFile) !== '.json') {
			throw new Error('authFile must be a json file');
		}
	}

	private readAuth(): Auth[] {
		if (!fs.existsSync(this.authFile)) {
			return [];
		}

		return JSON.parse(fs.readFileSync(this.authFile, 'utf8')) as Auth[];
	}

	private writeAuth(auth: Auth[]): void {
		fs.writeFileSync(this.authFile, JSON.stringify(auth, null, '\t'));
	}

	private generatePassKey(password: string): string {
		const salt = crypto.randomBytes(16).toString('hex');

		return `${salt}:${crypto
			.createHash('sha256')
			.update(salt + password)
			.digest('hex')}`;
	}

	private verifyPassKey(password: string, passkey: string): boolean {
		const [salt, hash] = passkey.split(':');

		return (
			hash ===
			crypto
				.createHash('sha256')
				.update(salt + password)
				.digest('hex')
		);
	}

	public addAuth(username: string, password: string): void {
		const authData = this.readAuth();

		authData.push({
			username,
			passkey: this.generatePassKey(password),
		});

		this.writeAuth(authData);
	}

	public authenticate(context: Context) {
		const auth = BasicAuthHelper.getBasicAuthCredentials(context);
		if (auth === null) {
			return { success: false, message: 'Credentials not provided' };
		}

		const [username, password] = auth;

		const authData = this.readAuth();

		for (const authEntry of authData) {
			if (
				authEntry.username === username &&
				this.verifyPassKey(password, authEntry.passkey)
			) {
				return { success: true, message: '' };
			}
		}

		return { success: false, message: 'Invalid credentials' };
	}

	// function userExists(username: string): boolean {
	// 	const authFileContent = getAuth();

	// 	for (const authEntry of authFileContent) {
	// 		if (authEntry.username === username) {
	// 			return true;
	// 		}
	// 	}

	// 	return false;
	// }
}

export default FileAuthenticator;
