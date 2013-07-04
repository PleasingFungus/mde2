package Actions {
	import Components.Wire;
	import flash.geom.Point;
	import Components.Bloc;
	import Components.WireHistory;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class MigrateBlocAction extends Action {
		
		public var bloc:Bloc;
		public var newLoc:Point;
		public var oldLoc:Point;
		public var history:Vector.<WireHistory>;
		public function MigrateBlocAction(bloc:Bloc, newLoc:Point, oldLoc:Point, history:Vector.<WireHistory>) {
			super();
			this.bloc = bloc;
			this.newLoc = newLoc;
			this.oldLoc = oldLoc;
			this.history = history;
		}
		
		override public function execute():Action {
			var wireHistory:WireHistory;
			var associatedWires:Vector.<Wire> = new Vector.<Wire>;
			for each (wireHistory in history) {
				Wire.remove(wireHistory.wire);
				associatedWires.push(wireHistory.wire);
			}
			bloc.associatedWires = associatedWires;
				
			bloc.remove(oldLoc);
			bloc.place(newLoc);
			for each (wireHistory in history)
				Wire.place(wireHistory.wire);
			return super.execute();
		}
		
		override public function revert():Action {
			var wireHistory:WireHistory;
			var associatedWires:Vector.<Wire> = new Vector.<Wire>;
			for each (wireHistory in history) {
				Wire.remove(wireHistory.wire);
				associatedWires.push(wireHistory.wire);
			}
			bloc.associatedWires = associatedWires;
			
			bloc.remove(newLoc);
			bloc.place(oldLoc);
			for each (wireHistory in history) {
				wireHistory.revert();
				Wire.place(wireHistory.wire);
			}
			return super.revert();
		}
		
	}

}