package Components {
	import flash.geom.Point;
	import Layouts.InternalWire;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InternalWirePather extends Pather {
		
		private var iWire:InternalWire;
		public function InternalWirePather(iWire:InternalWire) {
			super();
			this.iWire = iWire;
		}
		
		
		override public function validTransition(a:Point, _:Point):Boolean {
			return true//a.equals(iWire.endpoint) || iWire.bounds.containsPoint(a);
		}
	}

}