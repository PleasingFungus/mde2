package Modules {
	import Components.Port;
	import Values.Value;
	import Values.OpcodeValue;
	import Values.InstructionValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InstructionMemory extends Module {
		
		public function InstructionMemory(X:int, Y:int) {
			super(X, Y, "I-Mem", Module.CAT_STORAGE, 0, 4, 1);
			controls[0].name = "Line";
			outputs[0].name = "Op";
			outputs[1].name = "Src";
			outputs[2].name = "Targ";
			outputs[3].name = "Dest";
			delay = 10;
		}
		
		override public function renderName():String {
			return "IMEM\n\n" + controls[0].getValue()+": "+value;
		}
		
		override public function getDescription():String {
			return "Outputs the opcode, source, target & destination of the instruction at the specified line."
		}
		
		override public function drive(port:Port):Value {			
			var memoryValue:Value = value;
			if (!memoryValue)
				return U.V_UNPOWERED;
			if (!(memoryValue is InstructionValue))
				return U.V_UNKNOWN;
			
			var instrValue:InstructionValue = memoryValue as InstructionValue;
			
			var portIndex:int = outputs.indexOf(port);
			switch (portIndex) {
				case 0: return instrValue.operation;
				case 1: return instrValue.sourceArg;
				case 2: return instrValue.targetArg;
				case 3: return instrValue.destArg;
				default: return null; //crashme!
			}
		}
		
		protected function get value():Value { 
			var line:Value = controls[0].getValue();
			if (line.unpowered || line.unknown) return line;
			
			var index:int = line.toNumber();
			if (index >= U.state.memory.length || index < 0)
				return U.V_UNPOWERED;
			
			return U.state.memory[index];
		}
	}

}