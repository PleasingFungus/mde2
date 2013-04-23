package Testing.Tests {
	import Values.OpcodeValue;
	import Testing.Types.AbstractArg;
	import Testing.Instructions.Instruction;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InstructionSelectTest extends Test {
		
		public function InstructionSelectTest(ExpectedOps:Vector.<OpcodeValue>, ExpectedInstructions:int = 5, Seed:Number = NaN) {
			super(ExpectedOps, ExpectedInstructions, Seed);
		}
		
		override protected function genFirstValues():Vector.<AbstractArg> {
			var values:Vector.<AbstractArg> = new Vector.<AbstractArg>;
			for (var i:int = 0; i < expectedInstructions; i++) {
				do {
					var value:AbstractArg = genFirstValue();
				} while (AbstractArg.addrInVec(value.address, values));
				values.push(value);
			}
			return values;
		}
	}

}