package Actions {
	import Components.AssociatedWire;
	import Components.Bloc;
	import Components.Wire;
	import flash.geom.Point;
	import Components.WireHistory;
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
		}
		
		override public function execute():Action {
			bloc.remove(oldLoc);
			bloc.mobilize();
			return super.execute();
		}
		
		override public function revert():Action {
			bloc.place(oldLoc);
			return super.revert();
		}
		
		override public function get canRedo():Boolean {
			return false;
		}
		
	}

}