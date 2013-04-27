package Modules {
	import Components.Port;
	import Values.*
	import Layouts.*;
	import Layouts.Nodes.StandardNode;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class BabyLatch extends StatefulModule {
		
		public function BabyLatch(X:int, Y:int, InitialValue:int = 0) {
			super(X, Y, "Basic Storage", Module.CAT_STORAGE, 1, 1, 0, InitialValue);
			abbrev = "l";
			delay = 1;
			storesData = true;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			return new InternalLayout([new StandardNode(this, new Point(layout.ports[1].offset.x - 2, layout.ports[1].offset.y), [layout.ports[0], layout.ports[1]], [],
														function getValue():Value { return value; }, "Stored value")]);
		}
		
		override public function renderDetails():String {
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
			if (input.unpowered)
				return false;
			
			U.state.time.deltas.push(new Delta(U.state.time.moment, this, value));
			value = input;
			return true;
		}
		
	}

}