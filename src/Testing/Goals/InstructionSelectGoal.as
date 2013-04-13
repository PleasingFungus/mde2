package Testing.Goals {
	import Testing.Tests.InstructionSelectTest;
	import Values.OpcodeValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InstructionSelectGoal extends GeneratedGoal {
		
		public function InstructionSelectGoal() {
			var expectedOps:Vector.<OpcodeValue> = new Vector.<OpcodeValue>;
			expectedOps.push(OpcodeValue.OP_SAVI);
			expectedOps.push(OpcodeValue.OP_ADDM);
			super("Execute all instructions! TODO", InstructionSelectTest, expectedOps, 12, 50);
			minInstructions = 5;
		}
		
	}

}