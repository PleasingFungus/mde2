package Actions {
	import Components.Bloc;
	import Components.Wire;
	import flash.geom.Point;
	import LevelStates.WireHistory;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class BlocLiftAction extends Action {
		
		public var bloc:Bloc;
		public var oldLoc:Point;
		public var history:Vector.<WireHistory>;
		public function BlocLiftAction(bloc:Bloc, oldLoc:Point) {
			super();
			this.bloc = bloc;
			this.oldLoc = oldLoc;
			
			history = new Vector.<WireHistory>;
			for each (var wire:Wire in bloc.associatedWires)
				history.push(new WireHistory(wire));
		}
		
		override public function execute():Action {
			bloc.remove(oldLoc);
			return super.execute();
		}
		
		override public function revert():Action {
			for each (var wireHistory:WireHistory in history)
				wireHistory.revert();
			bloc.place(oldLoc);
			return super.revert();
		}
		
		override public function get canRedo():Boolean {
			return false;
		}
		
	}

}