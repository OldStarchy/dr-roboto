import Koa from 'koa';
import Authenticator from './Authenticator';
import BasicAuthHelper from './BasicAuthHelper';

export class DefaultAdminAuthenticator implements Authenticator {
	authenticate(context: Koa.Context) {
		const defaultAdminConfig = this.getDefaultAdminConfig();
		if (defaultAdminConfig === null) {
			return { success: false, message: '' };
		}

		const auth = BasicAuthHelper.getBasicAuthCredentials(context);
		if (auth === null) {
			return { success: false, message: 'Credentials not provided' };
		}

		const [defaultAdminUsername, defaultAdminPassword] = defaultAdminConfig;
		const [username, password] = auth;

		if (username === defaultAdminUsername) {
			const valid = this.comparePasswords(password, defaultAdminPassword);

			if (valid) {
				return { success: true, message: '' };
			}
		}

		return { success: false, message: 'Invalid credentials' };
	}

	private getDefaultAdminConfig(): [string, string] | null {
		const T_DEFAULT_ADMIN_USERNAME = process.env.T_DEFAULT_ADMIN_USERNAME;
		const T_DEFAULT_ADMIN_PASSWORD = process.env.T_DEFAULT_ADMIN_PASSWORD;

		if (
			T_DEFAULT_ADMIN_USERNAME === undefined ||
			T_DEFAULT_ADMIN_PASSWORD === undefined
		) {
			return null;
		}

		if (
			T_DEFAULT_ADMIN_USERNAME.length === 0 ||
			T_DEFAULT_ADMIN_PASSWORD.length === 0
		) {
			//todo log warning invalid env
			return null;
		}

		return [T_DEFAULT_ADMIN_USERNAME, T_DEFAULT_ADMIN_PASSWORD];
	}

	private comparePasswords(password1: string, password2: string): boolean {
		let valid = true;

		const lim = Math.max(password1.length, password2.length);
		for (let i = 0; i < lim; i++) {
			const char1 = password1.charCodeAt(i);
			const char2 = password2.charCodeAt(i);

			if (char1 !== char2 || isNaN(char1) || isNaN(char2)) {
				valid = false;
			}
		}

		return valid;
	}
}
