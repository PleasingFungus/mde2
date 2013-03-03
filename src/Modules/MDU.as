package Modules {
	import Values.Value;
	import Values.NumericValue;
	import Values.OpcodeValue;
	import Components.Port;
	
	import Layouts.*;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class MDU extends Module {
		
		public function MDU(X:int, Y:int) {
			super(X, Y, "*/", Module.CAT_ARITH, 2, 1, 1);
			delay = 4;
		}
		
		override protected function generateLayout():ModuleLayout {
			var layout:ModuleLayout = super.generateLayout();
			layout.dim.x -= 2;
			layout.dim.y -= 2;
			layout.ports[3].offset.y += 2;
			layout.ports[3].offset.x -= 2;
			return layout;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			var controlport:PortLayout = layout.ports[2];
			var outport:PortLayout = layout.ports[3];
			return new InternalLayout([new InternalNode(this, new Point(outport.offset.x - layout.dim.x / 2 - 1 / 2, outport.offset.y),
														[layout.ports[0], layout.ports[1], outport], [],
														function getValue():Value { return drive(outputs[0]); } ),
									   new InternalNode(this, new Point(controlport.offset.x, controlport.offset.y + 3),
														[controlport], [],
														function getValue():Value {
															switch (controls[0].getValue().toNumber()) {
																case OpcodeValue.OP_MUL.toNumber(): return OpcodeValue.OP_MUL;
																case OpcodeValue.OP_DIV.toNumber(): return OpcodeValue.OP_DIV;
																default: return U.V_UNKNOWN;
															}
														})]);
		}
		
		override public function drive(port:Port):Value {
			var inputA:Value = inputs[0].getValue();
			var inputB:Value = inputs[1].getValue();
			var control:Value = controls[0].getValue();
			
			if (inputA.unknown || inputB.unknown || control.unknown)
				return U.V_UNKNOWN;
			if (inputA.unpowered || inputB.unpowered || control.unpowered)
				return U.V_UNPOWERED;
			
			switch (control.toNumber()) {
				case OpcodeValue.OP_NOOP.toNumber(): return U.V_UNPOWERED;
				case OpcodeValue.OP_MUL.toNumber(): return new NumericValue(inputA.toNumber() * inputB.toNumber());
				case OpcodeValue.OP_DIV.toNumber(): return inputB.toNumber() ? new NumericValue(inputA.toNumber() / inputB.toNumber()) : U.V_UNKNOWN;
				default: return U.V_UNKNOWN;
			}
		}
		
		override public function renderName():String {
			return name + "\n\n" + drive(outputs[0]);
		}
		
	}

}