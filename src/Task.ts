class Task extends RootClass {
	public toString() {
		return 'Task{' + this.ClassName + '}';
	}
	public serialize() {
		const obj: any = {};
		for (const i in this) {
			obj[i] = this[i];
		}
		return obj;
	}
	public static Deserialize(obj: {}) {
		throw 'not implemented';
	}
}

includeAll('Tasks/Task');
