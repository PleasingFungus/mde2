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
		
		
		//override public function validTransition(cur:Point, next:Point):Boolean {
			//return next.equals(iWire.endpoint) || cur.equals(iWire.endpoint) || iWire.bounds.containsPoint(cur);
		//}
	}

}