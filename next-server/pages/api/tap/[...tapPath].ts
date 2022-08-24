// Next.js API route support: https://nextjs.org/docs/api-routes/introduction
import type { NextApiRequest, NextApiResponse } from 'next';
import path from 'path';
import { SemVer } from 'semver';
import Tap, { Response } from '../../../lib/Tap';
import ValueInjectorFileTransformer from '../../../lib/ValueInjectorFileTransformer';

export default async function handler(
	req: NextApiRequest,
	res: NextApiResponse<Response>,
) {
	if (!req.url) return;

	const publicProto = req.headers['x-forwarded-proto'] as string;
	const publicHost = req.headers['x-forwarded-host'] as string;

	const tapHeader = req.headers['x-tap'];
	const tapVersion =
		typeof tapHeader !== 'string' ? null : new SemVer(tapHeader);

	const tap = new Tap(tapVersion, path.resolve('../computerRoot'));
	tap.addFileTransformer(
		new ValueInjectorFileTransformer({
			PUBLIC_PROTO: publicProto,
			PUBLIC_DOMAIN: publicHost,
			PUBLIC_PATH: '/api/tap',
		}),
	);

	const tapPath = (req.query.tapPath as string[]).join('/');

	try {
		const result = await tap.readPath(tapPath);

		if (result === null) {
			res.status(404).end();
		}

		if (typeof result === 'string') {
			res.setHeader('Content-Type', 'text/plain');
		} else {
			res.setHeader('Content-Type', 'application/json');
		}

		res.status(200).send(result);
	} catch (e) {
		res.status(404).end();
	}
}
