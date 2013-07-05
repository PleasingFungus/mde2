package Components {
	import Components.Wire;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class WireHistory {
		
		public var wire:Wire;
		public var path:Vector.<Point>; //store compressed zigzag form instead?
		public function WireHistory(wire:Wire) {
			this.wire = wire;
			path = new Vector.<Point>;
			for each (var point:Point in wire.path)
				path.push(point.clone());
		}
		
		public function revertBasic():void {
			wire.path = new Vector.<Point>;
			for each (var point:Point in path)
				wire.path.push(point.clone());
			wire.cacheInvalid = true;
		}
		
		public function revertAndPlace():void {
			revertBasic();
			Wire.place(wire);
		}
	}

}