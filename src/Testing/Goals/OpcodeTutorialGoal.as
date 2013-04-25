package Testing.Goals {
	import Testing.Tests.OpcodeTest;
	import Values.InstructionValue;
	import Values.NumericValue;
	import Values.OpcodeValue;
	import LevelStates.LevelState;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class OpcodeTutorialGoal extends GeneratedGoal {
		
		public function OpcodeTutorialGoal(MinInstructions:int = 4) {
			var vec:Vector.<OpcodeValue> = new Vector.<OpcodeValue>;
			vec.push(OpcodeValue.OP_SAVI);
			super("Execute all instructions from memory!", OpcodeTest, vec, 6, 3, MinInstructions);
			description += "\n\n(From this level onward, your goal will be to go through memory, starting at 0, and execute every instruction there. "
			description += "Every level has a fixed set of instruction types, but several permutations will be generated to test your solution.)";
		}
	}

}