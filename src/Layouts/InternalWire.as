package Layouts {
	import Components.Wire;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InternalWire extends Wire {
		
		public var control:Boolean;
		public var getValue:Function;
		public var getConnected:Function
		public function InternalWire(Start:Point, End:Point, Control:Boolean, GetConnected:Function, GetValue:Function) {
			super(Start);
			constrained = false;
			attemptPathTo(End);
			control = Control;
			getConnected = GetConnected;
			getValue = GetValue;
		}
		
		public function shiftTo(newEnd:Point):void {
			var delta:Point = newEnd.subtract(path[path.length - 1]);
			for each (var p:Point in path) {
				p.x += delta.x;
				p.y += delta.y;
			}
		}
	}

}