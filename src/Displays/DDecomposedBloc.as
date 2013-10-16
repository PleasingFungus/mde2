package Displays {
	import Modules.CustomModule;
	import flash.geom.Point;
	import Actions.DecomposeAction;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DDecomposedBloc extends DBloc {
		
		public var customModule:CustomModule;
		public function DDecomposedBloc() {
			super();
		}
		
		override protected function execPlaceAction(placeLoc:Point):void {
			new DecomposeAction(bloc, placeLoc, customModule).execute();
		}
	}

}