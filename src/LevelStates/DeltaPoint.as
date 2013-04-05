package LevelStates {
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DeltaPoint extends Point {
		
		public var delta:Point;
		public function DeltaPoint(X:int = 0, Y:int = 0, Delta:Point = null) {
			super(X, Y);
			Delta = Delta ? Delta : new Point;
		}
		
	}

}