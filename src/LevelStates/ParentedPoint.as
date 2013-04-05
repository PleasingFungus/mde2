package LevelStates {
	import Components.Port;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ParentedPoint extends Point {
		
		public var parent:Port;
		public function ParentedPoint(x:int, y:int, parent:Port) {
			super(x, y);
			this.parent = parent;
		}
		
	}

}