import Koa from 'koa';

export default class BasicAuthHelper {
	public static getBasicAuthCredentials(
		context: Koa.Context
	): [string, string] | null {
		const authHeader = context.request.header.authorization;

		if (!authHeader || !/^Basic [a-zA-Z-1-9=]+$/.test(authHeader)) {
			return null;
		}

		const auth = Buffer.from(authHeader.substring(5), 'base64')
			.toString('utf8')
			.split(':');
		if (auth.length !== 2) {
			return null;
		}

		return auth as [string, string];
	}
}
