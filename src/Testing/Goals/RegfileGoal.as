package Testing.Goals {
	import Testing.Tests.RegfileTest;
	import Values.IntegerValue;
	import Values.OpcodeValue;
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class RegfileGoal extends GeneratedGoal {
		
		public function RegfileGoal() {
			var expectedOps:Vector.<OpcodeValue> = new Vector.<OpcodeValue>;
			expectedOps.push(OpcodeValue.OP_SET);
			expectedOps.push(OpcodeValue.OP_ADD);
			super("Execute all instructions and store all register values in memory at "+U.MIN_MEM+"+register index! TODO", RegfileTest, expectedOps, 6);
		}
	}

}