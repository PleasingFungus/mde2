package Testing.Goals {
	import Testing.Tests.OpcodeTest;
	import Values.InstructionValue;
	import Values.IntegerValue;
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
			super(OpcodeTest, vec, 6, 3, MinInstructions);
		}
	}

}