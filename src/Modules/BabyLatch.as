package Modules {
	import Components.Port;
	import Values.*
	import Layouts.*;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class BabyLatch extends StatefulModule {
		
		public function BabyLatch(X:int, Y:int, InitialValue:int = 0) {
			super(X, Y, "BLatch", Module.CAT_STORAGE, 1, 1, 0, InitialValue);
			delay = 1;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			return new InternalLayout([new InternalNode(this, new Point(layout.ports[1].offset.x - 2, layout.ports[1].offset.y), [layout.ports[0], layout.ports[1]], [],
														function getValue():Value { return value; })]);
		}
		
		override public function renderName():String {
			return "LCH" +"\n\n" + value;
		}
		
		override public function getDescription():String {
			return "Stores & continuously outputs a value. Each tick, sets its value to the input."
		}
		
		override public function drive(port:Port):Value {
			return value;
		}
		
		override protected function statefulUpdate():Boolean {
			var input:Value = inputs[0].getValue();
			U.state.time.deltas.push(new Delta(U.state.time.moment, this, value));
			value = input;
			return true;
		}
		
	}

}