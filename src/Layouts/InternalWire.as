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
		public function InternalWire(Start:Point, End:Point, Control:Boolean, GetValue:Function = null) {
			super(Start);
			constrained = false;
			attemptPathTo(End);
			control = Control;
			getValue = GetValue;
		}
	}

}