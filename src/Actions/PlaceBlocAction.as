package Actions {
	import Components.Bloc;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class PlaceBlocAction extends Action {
		
		public var loc:Point;
		public var bloc:Bloc;
		public function PlaceBlocAction(bloc:Bloc, loc:Point) {
			this.loc = loc;
			this.bloc = bloc;
		}
		
		override public function execute():Action {
			bloc.manifest(loc);
			return super.execute();
		}
		
		override public function revert():Action {
			bloc.demanifest();
			return super.revert();
		}
		
	}

}