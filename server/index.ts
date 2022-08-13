import crypto from 'crypto';
import dotenv from 'dotenv';
import fs from 'fs';
import Koa, {Middleware} from 'koa';
import KoaJson from 'koa-json';
import KoaStatic from 'koa-static';
import path from 'path';
import {satisfies, SemVer} from 'semver';

// stop the path import from eslinting way
path.join('a', 'b');

dotenv.config();

interface AppContext extends Koa.DefaultContext {
	tapVersion?: SemVer;
}
const app = new Koa<Koa.DefaultState, AppContext>();

app.use(KoaJson());

app.use(async (ctx, next) => {
	const userAgent = ctx.request.header['user-agent'];

	//allow http-01 challenge
	if (userAgent && userAgent.includes('HTTP-01-Proxy')) {
		return next();
	}

	// if (!userAgent || !/^computercraft\/([0-9.]+)$/.test(userAgent)) {
	// 	ctx.status = 403;
	// 	return;
	// }

	const tapVersion = ctx.request.header['x-tap'];
	if (typeof tapVersion === 'string') {
		const tapSemver = new SemVer(tapVersion);

		ctx.tapVersion = tapSemver;
		if (satisfies(tapSemver, '>=0.1.0')) {
			return tapHandler(ctx, next);
		} else {
			ctx.body = 'Invalid tap version';
			ctx.status = 400;
			return;
		}

	} else {
		return koaStatic(ctx, next);
	}
});

// app.use(
// 	createAuthMiddleware(
// 		new DefaultAdminAuthenticator(),
// 		new FileAuthenticator('auth.json')
// 	)
// );

const root = './computerRoot';
const koaStatic = KoaStatic(root, {
	hidden: true,
});

function compareHash(
	filepath: string,
	type: 'md5' | 'crc32' | string,
	givenHash: string
) {
	const fileHash = crypto
		.createHash(type)
		.update(fs.readFileSync(filepath))
		.digest('hex');

	// console.log({ fileHash, hash: givenHash });
	return fileHash === givenHash;
}

const tapHandler: Middleware<Koa.DefaultState, AppContext> = (ctx, next) => {
	const requestPath = ctx.request.path;
	const tapVersion = ctx.tapVersion!;

	if (/\.\./.test(requestPath)) {
		ctx.status = 403;
		return;
	}

	const fullPath = path.join(root, requestPath);

	const ifNoneMatch = ctx.request.header['if-none-match'];
	if (typeof ifNoneMatch === 'string') {
		const [type, hash] = ifNoneMatch.split(' ');

		if (compareHash(fullPath, type, hash)) {
			ctx.status = 304;
			return;
		}
	}

	if (fs.existsSync(fullPath)) {
		//is dir
		if (fs.statSync(fullPath).isDirectory()) {
			const entries = fs.readdirSync(fullPath).filter((file) => {
				return file !== '.' && file !== '..';
			});

			if (satisfies(tapVersion, '^0.2.0')) {
				ctx.body = JSON.stringify({
					type: 'directory',
					entries: entries.map((file) => {
						const stat = fs.statSync(path.join(fullPath, file));

						if (stat.isDirectory()) {
							return {
								type: 'directory',
								name: file,
							};
						} else {
							return {
								name: file,
								type: 'file',
								mtime: fs.statSync(path.join(fullPath, file)).mtime.getTime(),
							};
						}
					}),
				});
			} else {
				ctx.body = JSON.stringify({
					type: 'directory',
					entries,
				});
			}
		} else {
			ctx.lastModified = fs.statSync(fullPath).mtime;

			ctx.body = JSON.stringify({
				type: 'file',
				content: fs.readFileSync(fullPath, 'utf8'),
				mtime: fs.statSync(fullPath).mtime.getTime(),
			});
		}
	} else {
		ctx.status = 404;
	}

	return;
};

const host = process.env.T_HOST || 'localhost';
const useTls = process.env.T_TLS === 'true';
const port = useTls
	? process.env.T_TLS_PORT || '3001'
	: process.env.T_PORT || '3000';

if (!/^[0-9]+$/.test(port)) {
	console.error('T_PORT environment variable is not a number');
	process.exit(1);
}

const server = useTls
	? require('https').createServer(
			{
				key: fs.readFileSync('./certs/privkey.pem', 'utf8'),
				cert: fs.readFileSync('./certs/fullchain.pem', 'utf8'),
			},
			app.callback()
	  )
	: require('http').createServer(app.callback());

server.listen(Number.parseInt(port, 10), host);

server.on('listening', () => {
	const address = server.address();
	if (address) {
		if (typeof address === 'object') {
			console.log(
				`Listening on ${address.family} ${address.address}:${address.port}`
			);
		} else {
			console.log(`Listening on ${address}`);
		}
	}
});
