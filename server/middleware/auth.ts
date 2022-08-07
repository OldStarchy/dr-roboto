import Koa from 'koa';
import Authenticator from '../Authenticator';

export function createAuthMiddleware(...providers: Authenticator[]) {
	return function authMiddleware(
		ctx: Koa.Context,
		next: Koa.Next
	): Promise<void> | void {
		const messages = [];
		for (const provider of providers) {
			const result = provider.authenticate(ctx);
			if (result.success) {
				return next();
			}

			if (result.message !== '') {
				messages.push(result.message);
			}
		}

		ctx.status = 400;
		ctx.body = 'Failed to authenticate\n\n' + messages.join('\n');
		// '\n\n' +
		// ctx.req.rawHeaders.join('\n');

		return;
	};
}
