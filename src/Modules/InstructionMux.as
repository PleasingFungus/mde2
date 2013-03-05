package Modules {
	import Components.Port;
	import Values.InstructionValue;
	import Values.OpcodeValue;
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InstructionMux extends Module {
		
		public var width:int;
		public function InstructionMux(X:int, Y:int) {
			width = U.state ? U.state.level.expectedOps.length : 1;
			super(X, Y, "I-Mux", Module.CAT_LOGIC, 1, width, 1);
			if (U.state)
				for (var i:int = 0; i < width; i++)
					outputs[i].name = U.state.level.expectedOps[i].toString();
			delay = Math.ceil(Math.log(width) / Math.log(2));
		}
		
		protected function resetPorts():void {
			outputs = new Vector.<Port>;
			for (var i:int = 0; i < width; i++)
				outputs.push(new Port(true, this));
		}
		
		override public function renderName():String {
			return "I-Mux\n\n" + inputs[0].getValue()+"->"+ controls[0].getValue();
		}
		
		override public function drive(port:Port):Value {
			var index:int = outputs.indexOf(port);
			var control:Value = controls[0].getValue();
			if (control.unknown || control.unpowered)
				return control;
			
			var op:OpcodeValue = OpcodeValue.fromValue(control);
			var opIndex:int = U.state.level.expectedOps.indexOf(op);
			if (opIndex == index)
				return inputs[0].getValue();
			return U.V_UNPOWERED;
		}
		
	}

}