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
			super();
			description = "Split instructions into their component parts!"
			dynamicallyTested = true;
			timeLimit = 36;
			
			initialInstructions = new Vector.<InstructionValue>;
			initialInstructions.push( new InstructionValue(OpcodeValue.OP_ADD, 0, 5, 7, "This is a comment."));
			initialInstructions.push( new InstructionValue(OpcodeValue.OP_MUL, 3, 2, 6, "It describes an instruction."));
			initialInstructions.push( new InstructionValue(OpcodeValue.OP_DIV, 4, 5, 4, "Don't worry about it now."));
			
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