return {
	plank = {
		items = {log = 1},
		grid = {'log'},
		produces = 4,
	},
	stick = {
		items = {plank = 2},
		grid = {'plank', nil, nil, 'plank'},
		produces = 4
	},
	torch = {
		items = {stick = 1, coal = 1},
		grid = {'coal', nil, nil, 'stick'},
		produces = 4
	}
}
