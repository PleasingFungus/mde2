package Components {
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class WirePather extends Pather {
		
		public var wire:Wire;
		public function WirePather(wire:Wire) {
			this.wire = wire;
		}
		
		override public function validTarget(p:Point):Boolean {
			return !(wire.constrained && U.state.grid.moduleContentsAtPoint(p));
		}
		
		override public function validTransition(a:Point, b:Point):Boolean {
			if (U.state.grid.moduleContentsAtPoint(a))
				return false;
			
			var carriers:Vector.<Carrier> = U.state.grid.carriersAtPoint(a);
			if (!carriers)
				return true;
			
			var otherCarrier:Carrier = U.state.grid.lineContents(a, b);
			if (otherCarrier)
				return false;
			
			return true;
		}
		
	}

}