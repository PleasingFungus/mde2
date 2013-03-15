package Testing.Goals {
	import Testing.Tests.RegfileTest;
	import Values.OpcodeValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class RegfileGoal extends GeneratedGoal {
		
		public function RegfileGoal() {
			var expectedOps:Vector.<OpcodeValue> = new Vector.<OpcodeValue>;
			expectedOps.push(OpcodeValue.OP_SET);
			expectedOps.push(OpcodeValue.OP_ADD);
			super("Execute all instructions and store all register values in memory! TODO", RegfileTest, expectedOps, 6, 100);
		}
		
	}

}