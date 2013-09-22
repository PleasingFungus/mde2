package Components {
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class PseudoPort extends Port {
		
		public var loc:Point;
		public function PseudoPort(P:Point) {
			super(false, null);
			loc = P;
		}
		
		override public function get Loc():Point {
			return loc;
		}
		
	}

}