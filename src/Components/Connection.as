package Components {
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Connection {
		
		public var carrier:Carrier;
		public var points:Vector.<Point>;
		public var origin:Point;
		public function Connection(carrier:Carrier, point:Point) {
			this.carrier = carrier;
			points = new Vector.<Point>;
			points.push(point);
			
			if (carrier.isEndpoint(point) && carrier is Wire) {
				var wire:Wire = carrier as Wire;
				origin = point.equals(wire.start) ? wire.end : wire.start;
			} else 
				origin = point;
		}
		
	}

}