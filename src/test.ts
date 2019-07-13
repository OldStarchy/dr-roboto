declare class Recipe {
	[index: number]: Item;

	public getItemsCount(): { item: Item; count: number }[];
}

declare class Item {
	public getRecipe(): Recipe;
}

abstract class Task {
	// public parentTask: Task | null = null;
	public readonly subTasks: Task[] = [];

	public initialize(state: TurtleState): void {}

	public addSubTask(task: Task): void {
		this.subTasks.push(task);
		// task.parentTask = this;
	}

	public flatten() {
		return [...this.subTasks, this];
	}

	public abstract combine(otherTask: this);
}

function equalType<T, V extends T>(a: T, b: V): a is V {
	return a instanceof b.constructor;
}

abstract class ItemTask extends Task {
	public constructor(public readonly item: Item) {
		super();
	}
}

class GatherItemTask extends Task {
	public constructor(
		public readonly item: Item,
		public readonly count: number
	) {
		super();
	}

	public combine(otherTask: this) {
		otherTask;
	}
}

declare class Inventory {
	getItemCount(item: Item): number;
	take(item: Item, count: number): void;
}

declare class TurtleState {
	public inventory: Inventory;
}

class BuildTask extends Task {
	public constructor(public item: Item) {
		super();
	}

	public initialize(state: TurtleState) {
		const recipe = this.item.getRecipe();
		const ingredients = recipe.getItemsCount();

		for (const ingredient of ingredients) {
			const availableOfItem = state.inventory.getItemCount(
				ingredient.item
			);
			if (availableOfItem >= ingredient.count) {
				state.inventory.take(ingredient.item, ingredient.count);
			} else {
				state.inventory.take(ingredient.item, availableOfItem);
				this.addSubTask(
					new GatherItemTask(
						ingredient.item,
						ingredient.count - availableOfItem
					)
				);
			}
		}
	}
}

class Planner {
	public compile(tasks: Task[]) {
		const executableTasks: Task[] = [];

		for (const task of tasks) {
			executableTasks.push(...task.flatten());
		}

		// Combine adjacent tasks;
		// [get 1 log, get 1 log, craft chest, get 1 log, get 1 log, craft chest]
		// becomes
		// [get 2 log, craft chest, get 2 log, craft chest]
		const reducedTasks: Task[] = executableTasks.reduce<Task[]>(
			(result, currentTask) => {
				if (!result[result.length - 1].combine(currentTask)) {
					result.push(currentTask);
				}
				return result;
			},
			[executableTasks.shift()]
		);

		return new Plan(reducedTasks);
	}
}

class Plan {
	public constructor(public tasks: Task[]) {}
}
