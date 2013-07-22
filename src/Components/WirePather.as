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
		
		override public function validPoint(p:Point):Boolean {
			if (!wire.constrained)
				return true;
			
			if (U.state.grid.moduleContentsAtPoint(p))
				return false;
			
			var carriers:Vector.<Carrier> = U.state.grid.carriersAtPoint(p);
			return !carriers;
		}
		
		override public function validTransition(a:Point, b:Point):Boolean {
			if (!wire.constrained)
				return true;
			return !U.state.grid.lineContents(a, b);
		}
		
	}

}