package Testing.Goals {
	import Testing.OpcodeTest;
	import Values.InstructionValue;
	import Values.NumericValue;
	import Values.OpcodeValue;
	import LevelStates.LevelState;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class OpcodeTutorialGoal extends GeneratedGoal {
		
		public function OpcodeTutorialGoal() {
			var vec:Vector.<OpcodeValue> = new Vector.<OpcodeValue>;
			vec.push(OpcodeValue.OP_SAVI);
			super("DESCR: TODO", OpcodeTest, vec, 6, 10);
		}
	}

}