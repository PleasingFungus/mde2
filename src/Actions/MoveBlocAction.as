package Actions {
	import flash.geom.Point;
	import Components.Bloc;
	import Components.Wire;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class MoveBlocAction extends Action {
		
		public var bloc:Bloc;
		public var newLoc:Point;
		public function MoveBlocAction(bloc:Bloc, newLoc:Point) {
			super();
			this.bloc = bloc;
			this.newLoc = newLoc;
		}
		
		public function specialExecute():void {
			if (!U.state.actions.actionStack.length) {
				execute();
				return;
			}
			
			var lastAction:Action = U.state.actions.actionStack.pop();
			if (!(lastAction is BlocLiftAction)) {
				U.state.actions.actionStack.push(lastAction);
				execute();
				return;
			}
			
			var cLastAction:BlocLiftAction = lastAction as BlocLiftAction;
			if (cLastAction.bloc != bloc) {
				U.state.actions.actionStack.push(lastAction);
				execute();
				return;
			}
			
			var oldLoc:Point = cLastAction.oldLoc;
			
			if (newLoc.equals(oldLoc)) {
				bloc.place(newLoc);
				return;
			}
			
			bloc.place(newLoc);
			var migrateAction:MigrateBlocAction = new MigrateBlocAction(bloc, newLoc, oldLoc, cLastAction.history);
			U.state.actions.actionStack.push(migrateAction);
			U.state.actions.clearRedo();
			migrateAction.hasExecuted = true;
			finish();
		}
		
		override public function execute():Action {
			bloc.place(newLoc);
			return super.execute();
		}
		
		override public function revert():Action {
			bloc.remove(newLoc);
			return super.revert();
		}
	}

}