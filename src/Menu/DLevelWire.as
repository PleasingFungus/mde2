package Menu {
	import Components.Wire;
	import Displays.DWire;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DLevelWire extends DWire {
		
		public var beaten:Boolean;
		public function DLevelWire(wire:Wire, Beaten:Boolean) {
			beaten = Beaten;
			super(wire);
		}
		
		override protected function getColor():uint {
			return beaten ? U.DEFAULT_COLOR : 0x707070;
		}
		
		override protected function drawJoin(current:Point):void {	}
	}

}