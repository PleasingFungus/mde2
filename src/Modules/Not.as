package Modules {
	import Components.Port;
	import Values.Value;
	import Values.BooleanValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Not extends Module {
		
		public function Not(X:int, Y:int) {
			super(X, Y, "Not", Module.CAT_LOGIC, 1, 1, 0);
			delay = 1;
		}
		
		override public function drive(port:Port):Value {
			var input:Value = inputs[0].getValue();
			if (input.unknown || input.unpowered)
				return input;
			return BooleanValue.fromValue(input).boolValue ? BooleanValue.FALSE : BooleanValue.TRUE;
		}
		
		override public function renderName():String {
			return name + "\n\n" + drive(outputs[0]);
		}
		
		override public function getDescription():String {
			return "If input is " + BooleanValue.FALSE + ", outputs " + BooleanValue.TRUE + ". Else, outputs " + BooleanValue.FALSE + ".";
		}
		
	}

}