package Components {
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class WirePather extends Pather {
		
		public var wire:Wire;
		private var _source:Port;
		public function WirePather(wire:Wire) {
			this.wire = wire;
		}
		
		override protected function init(start:Point):void {
			_source = null;
			var carriers:Vector.<Carrier> = U.state.grid.carriersAtPoint(start);
			for each (var carrier:Carrier in carriers) { 
				_source = carrier.getSource();
				if (_source)
					break;
			}
		}
		
		override public function validTarget(p:Point):Boolean {
			return !(wire.constrained && U.state.grid.moduleContentsAtPoint(p));
		}
		
		override public function validPoint(p:Point, delta:Point):Boolean {
			if (!wire.constrained)
				return true;
			
			if (U.state.grid.moduleContentsAtPoint(p))
				return false;
			
			if (U.state.grid.lineContents(p, p.add(delta)))
				return false;
			
			return true;
		}
		
		override public function validTransition(a:Point, b:Point):Boolean {
			if (!wire.constrained)
				return true;
			
			if (U.state.grid.lineContents(a, b))
				return false;
			
			var carriers:Vector.<Carrier> = U.state.grid.carriersAtPoint(a);
			if (!carriers)
				return true;
			
			for each (var carrier:Carrier in carriers) {
				if (!carrier.isEndpoint(a))
					continue;
				var source:Port = carrier.getSource();
				if (source && source != _source)
					return false;
			}
			return true;
		}
		
	}

}