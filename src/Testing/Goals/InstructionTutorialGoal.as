package Testing.Goals {
	import LevelStates.LevelState;
	import Values.*;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InstructionTutorialGoal extends LevelGoal {
		
		private var initialInstructions:Vector.<InstructionValue>;
		public function InstructionTutorialGoal() {
			super("Split instructions into their component parts!\n\n");
			description += "Instructions are made up of four numbers. The first number, the opcode, says what type of instruction it is. "
			description += "The other three, the source, target, & destination, have meanings that vary by opcode.\n"
			description += "For this level, for each instruction in memory, just write the opcode, source, target & destination over four lines."
			dynamicallyTested = true;
			timeLimit = 36;
			
			initialInstructions = new Vector.<InstructionValue>;
			initialInstructions.push( new InstructionValue(OpcodeValue.OP_ADD, 0, 5, 7));
			initialInstructions.push( new InstructionValue(OpcodeValue.OP_MUL, 3, 2, 6));
			initialInstructions.push( new InstructionValue(OpcodeValue.OP_DIV, 4, 5, 4));
			
			expectedMemory = generateBlankMemory();
			for (var i:int = 0; i < initialInstructions.length; i++) {
				var instruction:InstructionValue = initialInstructions[i];
				expectedMemory[i*4] = instruction.operation;
				expectedMemory[i*4+1] = instruction.sourceArg;
				expectedMemory[i*4+2] = instruction.targetArg;
				expectedMemory[i*4+3] = instruction.destArg;
			}
		}
		
		override public function genMem():Vector.<Value> {
			var mem:Vector.<Value> = generateBlankMemory();
			for (var i:int = 0; i < initialInstructions.length; i++)
				mem[i * 4] = initialInstructions[i];
			return mem;
		}
		
	}

}