package Actions {
	import flash.geom.Point;
	import Modules.Module;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class MigrateModuleAction extends Action {
		
		public var module:Module;
		public var newLoc:Point;
		public var oldLoc:Point;
		public function MigrateModuleAction(module:Module, newLoc:Point, oldLoc:Point) {
			super();
			this.module = module;
			this.newLoc = newLoc;
			this.oldLoc = oldLoc;
		}
		
		override public function execute():Action {
			Module.remove(module);
			Module.place(module, newLoc);
			return super.execute();
		}
		
		override public function revert():Action {
			Module.remove(module);
			Module.place(module, oldLoc);
			return super.revert();
		}
		
	}

}