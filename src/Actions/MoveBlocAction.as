package Actions {
	import flash.geom.Point;
	import Components.Bloc;
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
			
			if (!U.state.actionStack.length) {
				execute();
				return;
			}
			
			var lastAction:Action = U.state.actionStack.pop();
			if (!(lastAction is BlocLiftAction)) {
				U.state.actionStack.push(lastAction);
				execute();
				return;
			}
			
			var cLastAction:BlocLiftAction = lastAction as BlocLiftAction;
			if (cLastAction.bloc != bloc) {
				U.state.actionStack.push(lastAction);
				execute();
				return;
			}
			
			var oldLoc:Point = cLastAction.oldLoc;
			
			if (newLoc.equals(oldLoc)) {
				execute();
				U.state.actionStack.pop(); //remove both this & the predecessor from do/undo if placing & removing to same place?
				return;
			}
			
			bloc.place(newLoc);
			U.state.actionStack.push(new MigrateBlocAction(bloc, newLoc, oldLoc));
			U.state.save();
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