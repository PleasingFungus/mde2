package Modules {
	import Components.Port;
	import Values.Value;
	import Values.BooleanValue;
	import Layouts.*;
	import Layouts.Nodes.TallNode;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Not extends Module {
		
		public function Not(X:int, Y:int) {
			super(X, Y, "Not", Module.CAT_LOGIC, 1, 1, 0);
			delay = 1;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			var outport:PortLayout = layout.ports[1];
			return new InternalLayout([new TallNode(this, new Point(outport.offset.x - layout.dim.x / 2 - 1 / 2, outport.offset.y),
														[layout.ports[0], layout.ports[1]], [],
													    function getValue():Value { return drive(outputs[0]); }, "Negation of input" )]);
		}
		
		override public function drive(port:Port):Value {
			var input:Value = inputs[0].getValue();
			if (input.unknown || input.unpowered)
				return input;
			return BooleanValue.fromValue(input).boolValue ? BooleanValue.NUMERIC_FALSE : BooleanValue.NUMERIC_TRUE;
		}
		
		override public function renderDetails():String {
			return name + "\n\n" + drive(outputs[0]);
		}
		
		override public function getDescription():String {
			return "If input is " + BooleanValue.FALSE + ", outputs " + BooleanValue.NUMERIC_TRUE + ". Else, outputs " + BooleanValue.NUMERIC_FALSE + ".";
		}
		
	}

}