package Testing.Types {
	import Values.OpcodeValue;
	import Testing.Abstractions.InstructionAbstraction;
	import Testing.Abstractions.AddMemoryAbstraction;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class AddMemoryType extends InstructionType {
		
		public function AddMemoryType() {
			super("Add Memory");
		}
		
		
		override public function mapToOp():OpcodeValue {
			return OpcodeValue.OP_ADDM;
		}
		
		override protected function can_produce(value:AbstractArg):Boolean {
			return value.inMemory;
		}
		
		override public function requiredArgsToProduce(value:AbstractArg, args:Vector.<AbstractArg>):int {
			return 0;
		}
		
		override public function produceMinimally(valueAbstr:AbstractArg, args:Vector.<AbstractArg>, argsToUse:int = C.INT_NULL):InstructionAbstraction {
			var value:int = valueAbstr.value;
			
			var minAddend:int = Math.max(U.MIN_INT, value - U.MAX_INT);
			var maxAddend:int = Math.min(U.MAX_INT, value - U.MIN_INT);
        
            var a1:int = C.randomRange(minAddend, maxAddend+1);
            var a2:int = value - a1;
			
			return new AddMemoryAbstraction(a1, a2, valueAbstr.address);
		}
		
	}

}