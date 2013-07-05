package Components {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class AssociatedWire {
		
		public var wire:Wire;
		public var connection:Connection;
		public function AssociatedWire(wire:Wire, connection:Connection) {
			this.wire = wire;
			this.connection = connection;
		}
		
	}

}