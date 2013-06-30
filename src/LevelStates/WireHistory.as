package LevelStates {
	import Components.Wire;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class WireHistory {
		
		public var wire:Wire;
		public var path:Vector.<Point>;
		public function WireHistory(wire:Wire) {
			this.wire = wire;
			path = wire.path.slice();
		}
		
	}

}