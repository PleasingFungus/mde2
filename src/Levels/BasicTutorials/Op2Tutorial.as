package Levels.BasicTutorials {
	import Levels.Level;
	import Modules.*;
	import Testing.Goals.InstructionSelectGoal;
	import Values.OpcodeValue;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Op2Tutorial extends Level {
		
		public function Op2Tutorial() {
			super("Two Instructions", new InstructionSelectGoal, false,
										 [ConstIn, Adder, Latch, DataWriter, DataReader, InstructionDecoder, InstructionDemux], [OpcodeValue.OP_SAVI, OpcodeValue.OP_ADDM]);
			info = "There are two different instruction types that appear in this level, and a new part, the Instruction Multiplexer module.";
			useModuleRecord = false;
		}
		
	}

}