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
			super(X, Y, "I-Mem", 0, 4, 1);
			controls[0].name = "Line";
			outputs[0].name = "Op";
			outputs[1].name = "Src";
			outputs[2].name = "Targ";
			outputs[3].name = "Dest";
			delay = 25;
		}
		
		override public function renderName():String {
			var out:String = "IMEM\n\n" + controls[0].getValue()+": ";
			
			var instrValue:InstructionValue = instruction;
			if (instrValue)
				out += instrValue;
			else
				out += OpcodeValue.OP_NOOP;
			
			return out;
		}
		
		override public function drive(port:Port):Value {
			var line:Value = controls[0].getValue();
			if (line.unpowered || line.unknown) return line;
			
			var index:int = line.toNumber();
			if (index >= U.state.memory.length)
				return U.V_UNKNOWN;
			
			var memoryValue:Value = U.state.memory[index];
			if (!memoryValue)
				return U.V_UNKNOWN;
			
			var instrValue:InstructionValue = InstructionValue.fromValue(memoryValue);
			
			var portIndex:int = outputs.indexOf(port);
			switch (portIndex) {
				case 0: return instrValue.operation;
				case 1: return instrValue.sourceArg;
				case 2: return instrValue.targetArg;
				case 3: return instrValue.destArg;
			}
			
			return null; //crashme!
		}
		
		protected function get instruction():InstructionValue { 
			var line:Value = controls[0].getValue();
			if (line.unpowered || line.unknown) return null;
			
			var index:int = line.toNumber();
			if (index >= U.state.memory.length)
				return null;
			
			var memoryValue:Value = U.state.memory[index];
			if (!memoryValue)
				return null;
			
			return InstructionValue.fromValue(memoryValue);
		}
	}

}