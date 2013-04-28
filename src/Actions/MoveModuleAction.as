package Actions {
	import flash.geom.Point;
	import Modules.Module;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class MoveModuleAction extends Action {
		
		public var module:Module;
		public var newLoc:Point;
		public function MoveModuleAction(module:Module, newLoc:Point) {
			super();
			this.module = module;
			this.newLoc = newLoc;
			
			if (!U.state.actionStack.length) {
				execute();
				return;
			}
			
			var lastAction:Action = U.state.actionStack.pop();
			if (!(lastAction is CustomAction)) {
				U.state.actionStack.push(lastAction);
				execute();
				return;
			}
			
			var cLastAction:CustomAction = lastAction as CustomAction;
			if (cLastAction.exec != Module.remove || cLastAction.revt != Module.place || cLastAction.param != module) {
				U.state.actionStack.push(lastAction);
				execute();
				return;
			}
			
			var oldLoc:Point = cLastAction.param2 as Point;
			
			if (newLoc.equals(oldLoc)) {
				execute();
				U.state.actionStack.pop(); //remove both this & the predecessor from do/undo if placing & removing to same place?
				return;
			}
			
			Module.place(module, newLoc);
			U.state.actionStack.push(new MigrateModuleAction(module, newLoc, oldLoc));
			U.state.save();
		}
		
		override public function execute():Action {
			Module.place(module, newLoc);
			return super.execute();
		}
		
		override public function revert():Action {
			Module.remove(module);
			return super.revert();
		}
	}

}