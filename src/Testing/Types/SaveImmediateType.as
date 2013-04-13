package Testing.Types {
	import Values.OpcodeValue;
	import Testing.Abstractions.InstructionAbstraction;
	import Testing.Abstractions.SaveImmediateAbstraction;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SaveImmediateType extends InstructionType {
		
		public function SaveImmediateType() {
			super("Save Immediate");
		}
		
		
		override public function mapToOp():OpcodeValue {
			return OpcodeValue.OP_SAVI;
		}
		
		override public function can_produce(value:AbstractArg):Boolean {
			return value.inMemory;
		}
		
		override public function requiredArgsToProduce(value:AbstractArg, args:Vector.<AbstractArg>):int {
			return 0;
		}
		
		override public function produceMinimally(value:AbstractArg, args:Vector.<AbstractArg>, argsToUse:int = C.INT_NULL):InstructionAbstraction {
			return new SaveImmediateAbstraction(value.value, value.address);
		}
		
	}

}