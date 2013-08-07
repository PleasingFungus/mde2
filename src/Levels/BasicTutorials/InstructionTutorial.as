package Levels.BasicTutorials {
	import Levels.Level;
	import Modules.*;
	import Testing.Goals.InstructionTutorialGoal;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InstructionTutorial extends Level {
		
		public function InstructionTutorial() {
			super("Instructions", new InstructionTutorialGoal, false,
											[ConstIn, Adder, Latch, DataWriter, DataReader, InstructionDecoder]);
			info = "Instructions are made up of four numbers. The first number, the opcode, says what type of instruction it is. "
			info += "The other three, the source, target, & destination, have meanings that vary by opcode.\n\n"
			info += "For this level, for each instruction in memory, just write the opcode, source, target & destination over four lines."
			writerLimit = 4;
			useModuleRecord = false;
		}
		
	}

}