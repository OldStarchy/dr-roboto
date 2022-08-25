import type { NextPage } from 'next';
import { ChangeEvent, useEffect, useState } from 'react';

let socket: WebSocket;

const Home: NextPage = () => {
	const [input, setInput] = useState('');

	useEffect(() => void socketInitializer(), []);

	const socketInitializer = async () => {
		socket = new WebSocket('wss://ntap.sorokin.id.au/api/remote');

		socket.addEventListener('open', () => {
			console.log('connected');
		});

		socket.addEventListener('message', (msg) => {
			console.log(msg.data);
			const data = JSON.parse(msg.data);
			if (data[1] === 'update-input') {
				setInput(data[1]);
			}
		});
	};

	const onChangeHandler = (e: ChangeEvent<HTMLInputElement>) => {
		setInput(e.target.value);
		socket.send(JSON.stringify(['input-change', e.target.value]));
	};

	return (
		<input
			placeholder="Type something"
			value={input}
			onChange={onChangeHandler}
		/>
	);
};

export default Home;
