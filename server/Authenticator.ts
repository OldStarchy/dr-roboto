import Koa from 'koa';

export default interface Authenticator {
	authenticate(context: Koa.Context): { success: boolean; message: string };
}
