package Modules {
	import Values.Value;
	import Values.NumericValue;
	import Values.OpcodeValue;
	import Components.Port;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ASU extends Module {
		
		public function ASU(X:int, Y:int) {
			super(X, Y, "+-", 2, 1, 1);
			delay = 4;
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
				case OpcodeValue.OP_ADD.toNumber(): return new NumericValue(inputA.toNumber() + inputB.toNumber());
				case OpcodeValue.OP_SUB.toNumber(): return new NumericValue(inputA.toNumber() - inputB.toNumber());
				default: return U.V_UNKNOWN;
			}
		}
		
		override public function renderName():String {
			return name + "\n\n" + drive(outputs[0]);
		}
		
	}

}