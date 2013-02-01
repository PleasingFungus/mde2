package Modules {
	import Components.Port;
	import Values.NumericValue;
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Adder extends Module {
		
		public function Adder(X:int, Y:int) {
			super(X, Y, "+", 2, 1, 0);
			delay = 3;
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