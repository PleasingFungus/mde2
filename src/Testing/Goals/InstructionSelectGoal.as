package Testing.Goals {
	import Testing.Tests.InstructionSelectTest;
	import Values.OpcodeValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InstructionSelectGoal extends GeneratedGoal {
		
		public function InstructionSelectGoal(MinInstructions:int = 5) {
			var expectedOps:Vector.<OpcodeValue> = new Vector.<OpcodeValue>;
			expectedOps.push(OpcodeValue.OP_SAVI);
			expectedOps.push(OpcodeValue.OP_ADDM);
			super(InstructionSelectTest, expectedOps, 12);
			minInstructions = MinInstructions;
		}
		
	}

}