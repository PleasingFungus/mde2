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
			switch (operation) {
				case OpcodeValue.OP_SET:
					return operation.getName()+" R" + destArg + "=" + sourceArg;
				case OpcodeValue.OP_ADD:
					return operation.getName()+" R" + destArg + "=R" + sourceArg + "+R" + targetArg;
				case OpcodeValue.OP_SAV:
					return operation.getName()+" M[R" + targetArg + "]=R" + sourceArg;
				case OpcodeValue.OP_JMP:
					return operation.getName()+" OVER "+ sourceArg;
			}
			
			var out:String = operation.getName() + "(" + sourceArg.toNumber();
			if (targetArg.toNumber() != C.INT_NULL)
				out += "," + targetArg.toNumber();
			if (destArg.toNumber() != C.INT_NULL)
				out += "," + destArg.toNumber();
			return out + ")";
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
		
		override public function eq(v:Value):Boolean {
			if (!v || !(v is InstructionValue))
				return false;
			var iv:InstructionValue = v as InstructionValue;
			return iv.operation == operation && iv.sourceArg.eq(sourceArg) && iv.targetArg.eq(targetArg) && iv.destArg.eq(destArg);
		}
	}

}