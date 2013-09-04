package Actions {
	import Components.Wire;
	import flash.geom.Point;
	import Components.Bloc;
	import Components.WireHistory;
	import Components.AssociatedWire;
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
			bloc.remove(oldLoc);
			bloc.place(newLoc);
			return super.execute();
		}
		
		override public function revert():Action {
			bloc.remove(newLoc);
			bloc.place(oldLoc);
			return super.revert();
		}
		
	}

}