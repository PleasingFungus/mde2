package Levels.BasicTutorials {
	import Levels.Level;
	import Modules.*;
	import Testing.Goals.OpcodeTutorialGoal;
	import Values.OpcodeValue;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class OpTutorial extends Level {
		
		public function OpTutorial() {
			super("One Instruction", new OpcodeTutorialGoal, false, [ConstIn, Adder, BabyLatch, DataWriter, DataReader, InstructionDecoder], [OpcodeValue.OP_SAVI]);
			info = "From this level onward, your goal will be to go through memory, starting at 0, and execute every instruction there. "
			info += "Every level has a fixed set of instruction types, but several permutations will be generated to test your solution.";
		}
		
	}

}