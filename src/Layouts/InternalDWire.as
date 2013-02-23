package Layouts {
	import Components.Wire;
	import Displays.DWire;
	import Values.Value;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InternalDWire extends DWire {
		
		public function InternalDWire(wire:InternalWire) {
			super(wire);
		}
		
		override protected function getColor():uint {
			var iWire:InternalWire = wire as InternalWire;
			
			//if (wire.getSource() == null || wire.connections.length < 2)
				//return 0xff0000;
			
			var value:Value = iWire.getValue();
			if (value.unknown)
				return 0xc219d9;
			if (value.unpowered)
				return 0x1d19d9;
			return 0x0;
		}
	}

}