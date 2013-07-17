package Modules {
	import Components.Port;
	import Values.NumericValue;
	import Values.Value;
	
	import Layouts.*;
	import Layouts.Nodes.TallNode;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Subtractor extends Module {
		
		public function Subtractor(X:int, Y:int) {
			super(X, Y, "Subtractor", ModuleCategory.ARITH, 2, 1, 0);
			abbrev = "-";
			symbol = _symbol;
			delay = 2;
		}
		
		override protected function generateLayout():ModuleLayout {
			var layout:ModuleLayout = super.generateLayout();
			layout.ports[0].port.name = "Minuend";
			layout.ports[1].port.name = "Subtrahend";
			layout.ports[layout.ports.length - 1].offset.y += 2;
			return layout;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			var outport:PortLayout = layout.ports[2];
			return new InternalLayout([new TallNode(this, new Point(outport.offset.x - layout.dim.x / 2 - 1 / 2, outport.offset.y),
														[layout.ports[0], layout.ports[1], layout.ports[2]], [],
													    function getValue():Value { return drive(outputs[0]); }, "Difference" )]);
		}
		
		override public function drive(port:Port):Value {
			var inputA:Value = inputs[0].getValue();
			var inputB:Value = inputs[1].getValue();
			if (inputA.unknown || inputB.unknown)
				return U.V_UNKNOWN;
			if (inputA.unpowered || inputB.unpowered)
				return U.V_UNPOWERED;
			return new NumericValue(inputA.toNumber() - inputB.toNumber());
		}
		
		override public function renderDetails():String {
			return name + "\n\n" + drive(outputs[0]);
		}
		
		override public function getDescription():String {
			return "Outputs the difference of its inputs."
		}
		
		
		[Embed(source = "../../lib/art/modules/symbol_minus_24.png")] private const _symbol:Class;
	}

}