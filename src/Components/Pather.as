package Components {
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Pather {
		
		public function Pather() {
			
		}
		
		public function validTarget(p:Point):Boolean { return true; }
		public function validPoint(p:Point, delta:Point):Boolean { return true; }
		public function validTransition(a:Point, b:Point):Boolean { return true; }
		
		protected function init(start:Point):void { }
		
		public function dumbPath(start:Point, end:Point):Vector.<Point> {
			var path:Vector.<Point> = new Vector.<Point>;
			path.push(start);
			init(start);
			if (!validTarget(end))
				return path;
			
			var current:Point = start;
			var next:Point;
			for (var delta:Point = end.subtract(current); delta.x || delta.y; delta = end.subtract(current)) {
				var nextDelta:Point = delta.x > 0 ? RIGHT_DELTA : LEFT_DELTA;
				next = current.add(nextDelta);
				var valid:Boolean = (end.equals(next) || validPoint(next, nextDelta)) && validTransition(current, next);
				if ((!delta.x || !valid) && delta.y) {
					nextDelta = delta.y > 0 ? DOWN_DELTA : UP_DELTA;
					next = current.add(nextDelta);
					valid = (end.equals(next) || validPoint(next, nextDelta)) && validTransition(current, next);
				}
				
				if (!valid)
					break;
				
				path.push(current = next);
			}
			
			return path;
		}
		
		private const LEFT_DELTA:Point = new Point( -1, 0);
		private const RIGHT_DELTA:Point = new Point( 1, 0);
		private const UP_DELTA:Point = new Point( 0, -1);
		private const DOWN_DELTA:Point = new Point( 0, 1);
	}

}