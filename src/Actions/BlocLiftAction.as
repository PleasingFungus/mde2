package Actions {
	import Components.Bloc;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class BlocLiftAction extends Action {
		
		public var bloc:Bloc;
		public var oldLoc:Point;
		public function BlocLiftAction(bloc:Bloc, oldLoc:Point) {
			super();
			this.bloc = bloc;
			this.oldLoc = oldLoc;
		}
		
		override public function execute():Action {
			bloc.remove(oldLoc);
			return super.execute();
		}
		
		override public function revert():Action {
			bloc.place(oldLoc);
			return super.revert();
		}
		
	}

}