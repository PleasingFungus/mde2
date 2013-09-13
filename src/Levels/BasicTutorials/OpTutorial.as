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
			super("One Instruction", new OpcodeTutorialGoal, false, [ConstIn, Adder, Latch, DataWriter, DataReader, InstructionDecoder], [OpcodeValue.OP_SAVI]);
			info = "From this level onward, your goal will be to go through memory, starting at 0, and execute every instruction there.\n\n"
			info = "Instructions are made up of four numbers. The first number, the opcode, says what type of instruction it is. "
			info += "The other three, the source, target, & destination, have meanings that vary by opcode.\n\n"
			info += "Every level has a fixed set of instruction types, but several permutations will be generated to test your solution. ";
			info += "Click 'Memory' in the top bar to see examples.";
			useModuleRecord = false;
			commentsEnabled = true;
		}
		
	}

}