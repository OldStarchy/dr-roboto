import { NextApiRequest, NextApiResponse } from 'next';

declare module 'net' {
	interface Socket {
		server: import('https').Server;
	}
}

const SocketHandler = (req: NextApiRequest, res: NextApiResponse) => {
	console.log('socket request');
	res.socket!.on('data', () => void console.log('data'));

	console.log(req.headers);

	// io.on('connection', (socket) => {
	// 	socket.on('input-change', (msg) => {
	// 		socket.broadcast.emit('update-input', msg);
	// 	});
	// });
	if (req.headers.upgrade != 'websocket') {
		res.status(400).end();
	}

	const websocketKey = req.headers['sec-websocket-key'];
	const websocketAccept = Buffer.from(
		websocketKey + '258EAFA5-E914-47DA-95CA-C5AB0DC85B11',
		'base64',
	).toString('base64');

	res.write(
		'HTTP/1.1 101 Web Socket Protocol Handshake\r\n' +
			'Upgrade: WebSocket\r\n' +
			'Connection: Upgrade\r\n' +
			'Sec-WebSocket-Accept: ' +
			websocketAccept +
			'\r\n' +
			'\r\n',
	);
	res.end();
};

export default SocketHandler;
