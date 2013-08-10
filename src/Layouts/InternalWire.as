package Layouts {
	import Components.Wire;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import Components.InternalWirePather;
	import Components.Pather;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InternalWire extends Wire {
		
		public var controlPointIndex:int = C.INT_NULL;
		public var controlTruncated:Boolean;
		public var getValue:Function;
		public var getConnected:Function;
		public var endpoint:Point;
		public var bounds:Rectangle;
		public var reversed:Boolean;
		public var dashed:Boolean;
		public var truncatedByControlWireFromEnd:Boolean;
		public function InternalWire(Start:Point, End:Point, Bounds:Rectangle,
								     GetConnected:Function, GetValue:Function) {
			super(Start);
			constrained = false;
			
			endpoint = End;
			bounds = Bounds;
			attemptPathTo(End);
			if (!end.equals(End))
				throw new Error("Internal wire pathing failure!");
			if (path.length < 2)
				path = new Vector.<Point>;
			endpoint = null;
			bounds = null; //not guaranteed to be well-defined after init
			
			getConnected = GetConnected;
			getValue = GetValue;
		}
		
		override protected function makePather():Pather {
			return new InternalWirePather(this);
		}
		
		public function update():void { }
		
		public function shiftTo(newEnd:Point):void {
			if (!path.length) return;
			var delta:Point = newEnd.subtract(reversed ? end : start);
			for each (var p:Point in path) {
				p.x += delta.x;
				p.y += delta.y;
			}
		}
	}

}