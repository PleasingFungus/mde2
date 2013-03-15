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
		public var getValue:Function;
		public var getConnected:Function;
		protected var endpoint:Point;
		protected var bounds:Rectangle;
		public var reversed:Boolean;
		public var fullControl:Boolean;
		public var reverseControlTruncation:Boolean;
		public function InternalWire(Start:Point, End:Point, Bounds:Rectangle,
								     GetConnected:Function, GetValue:Function) {
			super(Start);
			constrained = false;
			
			endpoint = End;
			bounds = Bounds;
			attemptPathTo(End);
			endpoint = null;
			bounds = null; //not guaranteed to be well-defined after init
			
			getConnected = GetConnected;
			getValue = GetValue;
		}
		
		override protected function mayMoveThrough(p:Point, delta:Point):Boolean {
			return p.equals(endpoint) || bounds.containsPoint(p);
		}
		
		public function update():void { }
		
		public function shiftTo(newEnd:Point):void {
			var delta:Point = newEnd.subtract(path[reversed ? path.length - 1 : 0]);
			for each (var p:Point in path) {
				p.x += delta.x;
				p.y += delta.y;
			}
		}
	}

}