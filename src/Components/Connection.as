package Components {
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Connection {
		
		public var primary:Carrier;
		public var secondary:Carrier;
		public var point:Point;
		public function Connection(Primary:Carrier, Secondary:Carrier, point:Point) {
			primary = Primary;
			secondary = Secondary;
			this.point = point;
		}
		
	}

}