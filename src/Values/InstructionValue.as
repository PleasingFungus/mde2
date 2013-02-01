package Values {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InstructionValue extends Value {
		
		public var operation:OpcodeValue;
		public var sourceArg:NumericValue;
		public var targetArg:NumericValue;
		public var destArg:NumericValue;
		public function InstructionValue(Operation:OpcodeValue, SourceArg:int, TargetArg:int, DestArg:int) {
			operation = Operation;
			sourceArg = new NumericValue(SourceArg);
			targetArg = new NumericValue(TargetArg);
			destArg = new NumericValue(DestArg);
		}
		
		override public function toString():String {
			return operation.getName() + "(" + sourceArg.toNumber() + "," + targetArg.toNumber() + "," + destArg.toNumber() + ")";
		}
		
		override public function toNumber():Number {
			return operation.toNumber(); //eh
		}
		
		public static function fromValue(v:Value):InstructionValue {
			if (v is InstructionValue)
				return v as InstructionValue;
			//alas, it is not to be
			return new InstructionValue(OpcodeValue.OP_NOOP, 0, 0, 0);
		}
	}

}