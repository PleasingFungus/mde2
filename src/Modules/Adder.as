package Modules {
	import Components.Port;
	import Values.NumericValue;
	import Values.Value;
	
	import Layouts.PortLayout;
	import Layouts.InternalLayout;
	import Layouts.InternalNode;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Adder extends Module {
		
		public function Adder(X:int, Y:int) {
			super(X, Y, "+", Module.CAT_ARITH, 2, 1, 0);
			delay = 2;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			var outport:PortLayout = layout.ports[2];
			return new InternalLayout([new InternalNode(this, new Point(outport.offset.x - layout.dim.x / 2 - 1 / 2, outport.offset.y),
														[layout.ports[0], layout.ports[1], layout.ports[2]], [],
													    function getValue():Value { return drive(outputs[0]); }, "+" )]);
		}
		
		override public function drive(port:Port):Value {
			var inputA:Value = inputs[0].getValue();
			var inputB:Value = inputs[1].getValue();
			if (inputA.unknown || inputB.unknown)
				return U.V_UNKNOWN;
			if (inputA.unpowered || inputB.unpowered)
				return U.V_UNPOWERED;
			return new NumericValue(inputA.toNumber() + inputB.toNumber());
		}
		
		override public function renderName():String {
			return name + "\n\n" + drive(outputs[0]);
		}
	}

}