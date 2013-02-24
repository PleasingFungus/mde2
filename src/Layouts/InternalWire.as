package Layouts {
	import Components.Wire;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InternalWire extends Wire {
		
		public var controlPoint:int = C.INT_NULL;
		public var out:Boolean;
		public var getValue:Function;
		public var getConnected:Function
		public function InternalWire(Start:Point, End:Point, Out:Boolean, GetConnected:Function, GetValue:Function) {
			super(Start);
			out = Out;
			constrained = false;
			attemptPathTo(End);
			getConnected = GetConnected;
			getValue = GetValue;
		}
		
		public function update():void { }
		
		public function shiftTo(newEnd:Point):void {
			var delta:Point = newEnd.subtract(path[out ? 0 : path.length - 1]);
			for each (var p:Point in path) {
				p.x += delta.x;
				p.y += delta.y;
			}
		}
	}

}