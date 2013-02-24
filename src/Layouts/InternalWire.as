package Layouts {
	import Components.Wire;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InternalWire extends Wire {
		
		public var controlPoint:int = C.INT_NULL;
		public var reversed:Boolean;
		public var getValue:Function;
		public var getConnected:Function;
		protected var endpoint:Point;
		protected var bounds:Rectangle;
		public function InternalWire(Start:Point, End:Point, Bounds:Rectangle,
								     Reversed:Boolean, GetConnected:Function, GetValue:Function) {
			super(Start);
			reversed = Reversed;
			constrained = false;
			
			endpoint = End;
			bounds = Bounds;
			attemptPathTo(End);
			
			getConnected = GetConnected;
			getValue = GetValue;
		}
		
		override protected function mayMoveThrough(p:Point):Boolean {
			return p.equals(endpoint) || bounds.containsPoint(p);
		}
		
		public function update():void { }
		
		public function shiftTo(newEnd:Point):void {
			var delta:Point = newEnd.subtract(path[reversed ? 0 : path.length - 1]);
			for each (var p:Point in path) {
				p.x += delta.x;
				p.y += delta.y;
			}
		}
	}

}