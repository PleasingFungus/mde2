package Components {
	import flash.geom.Point;
	import Layouts.InternalWire;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InternalWirePather extends WirePather {
		
		public function InternalWirePather(wire:Wire) {
			super(wire);
		}
		
		
		override public function validTransition(a:Point, _:Point):Boolean {
			return true//a.equals((wire as InternalWire).endpoint) || (wire as InternalWire).bounds.containsPoint(a);
		}
	}

}