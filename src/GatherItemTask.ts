class GatherItemTask extends Task {
	public constructor(public item: string, public count: number) {
		super();
	}

	public toString() {
		return 'Gather ' + this.count + ' ' + this.item + '(s)';
	}

	public static Deserialize(obj: any) {
		return new GatherItemTask(obj.item, obj.count);
	}
}

const a = new GatherItemTask('fish', 3);

console.log(a.serialize());
