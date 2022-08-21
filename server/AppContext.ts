import Koa from 'koa';
import { SemVer } from 'semver';

export default interface AppContext extends Koa.DefaultContext {
	tapVersion?: SemVer;
	publicProto: string;
	publicDomain: string;
}
