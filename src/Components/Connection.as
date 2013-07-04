package Components {
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Connection {
		
		public var primary:Carrier;
		public var secondary:Carrier;
		public var meeting:Point;
		public var origin:Point;
		public function Connection(Primary:Carrier, Secondary:Carrier, Meeting:Point) {
			primary = Primary;
			secondary = Secondary;
			meeting = Meeting;
			if (secondary.isEndpoint(meeting) && secondary is Wire) {
				var wire:Wire = secondary as Wire;
				origin = meeting.equals(wire.start) ? wire.end : wire.start;
			} else 
				origin = meeting;
		}
		
	}

}