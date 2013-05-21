package Values {
	import UI.ColorText;
	import UI.HighlightFormat;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InstructionValue extends Value {
		
		public var operation:OpcodeValue;
		public var sourceArg:NumericValue;
		public var targetArg:NumericValue;
		public var destArg:NumericValue;
		public var comment:String;
		public var commentFormat:HighlightFormat;
		public function InstructionValue(Operation:OpcodeValue, SourceArg:int, TargetArg:int, DestArg:int,
										 Comment:String = null, CommentFormat:HighlightFormat = null) {
			operation = Operation;
			sourceArg = new NumericValue(SourceArg);
			targetArg = new NumericValue(TargetArg);
			destArg = new NumericValue(DestArg);
			
			comment = Comment;
			commentFormat = CommentFormat;
		}
		
		override public function toString():String {
			switch (operation) {
				case OpcodeValue.OP_SET:
					return operation.getName()+" R" + destArg + " = " + sourceArg;
				case OpcodeValue.OP_ADD:
					return operation.getName()+" R" + destArg + " = R" + sourceArg + "+R" + targetArg;
				case OpcodeValue.OP_SUB:
					return operation.getName()+" R" + destArg + " = R" + sourceArg + "-R" + targetArg;
				case OpcodeValue.OP_MUL:
					return operation.getName()+" R" + destArg + " = R" + sourceArg + "*R" + targetArg;
				case OpcodeValue.OP_DIV:
					return operation.getName()+" R" + destArg + " = R" + sourceArg + "/R" + targetArg;
				case OpcodeValue.OP_SAV:
					return operation.getName()+" M[R" + targetArg + "] = R" + sourceArg;
				case OpcodeValue.OP_LD:
					return operation.getName()+ " R" + destArg +" = M[R" + targetArg + "]";
				case OpcodeValue.OP_JMP:
					return operation.getName() + " OVER " + destArg;
				case OpcodeValue.OP_BEQ:
					return operation.getName() + " R" + sourceArg +"=R"+targetArg + " OVER " + destArg;
				
				case OpcodeValue.OP_SAVI:
					return operation.getName() + " M[" + targetArg + "]=" + sourceArg;
				case OpcodeValue.OP_ADDM:
					return operation.getName() + " M[" + targetArg + "]=" + sourceArg + "+" + destArg;
			}
			
			var out:String = operation.getName() + "(" + sourceArg.toNumber();
			if (targetArg.toNumber() != C.INT_NULL)
				out += "," + targetArg.toNumber();
			if (destArg.toNumber() != C.INT_NULL)
				out += "," + destArg.toNumber();
			return out + ")";
		}
		
		override public function toFormat():HighlightFormat {
			switch (operation) {
				case OpcodeValue.OP_SET:
					return formatFrom("R{} = {}", [U.DESTINATION, U.SOURCE]);
				case OpcodeValue.OP_ADD:
					return formatFrom("R{} = R{}+R{}", [U.DESTINATION, U.SOURCE, U.TARGET]);
				case OpcodeValue.OP_SUB:
					return formatFrom("R{} = R{}-R{}", [U.DESTINATION, U.SOURCE, U.TARGET]);
				case OpcodeValue.OP_MUL:
					return formatFrom("R{} = R{}*R{}", [U.DESTINATION, U.SOURCE, U.TARGET]);
				case OpcodeValue.OP_DIV:
					return formatFrom("R{} = R{}/R{}", [U.DESTINATION, U.SOURCE, U.TARGET]);
				case OpcodeValue.OP_SAV:
					return formatFrom("M[R{}] = R{}", [U.TARGET, U.SOURCE]);
				case OpcodeValue.OP_LD:
					return formatFrom("R{} = M[R{}]", [U.DESTINATION, U.TARGET]);
				case OpcodeValue.OP_JMP:
					return formatFrom("OVER {}", [U.DESTINATION]);
				case OpcodeValue.OP_BEQ:
					return formatFrom("R{}=R{} OVER {}", [U.SOURCE, U.TARGET, U.DESTINATION]);
				
				case OpcodeValue.OP_SAVI:
					return formatFrom("M[{}] = {}", [U.TARGET, U.SOURCE]);
				case OpcodeValue.OP_ADDM:
					return formatFrom("M[{}] = {}+{}", [U.TARGET, U.SOURCE, U.DESTINATION]);
			}
			
			return null;
		}
		
		private function formatFrom(baseStr:String, keys:Array):HighlightFormat {
			var colorTexts:Vector.<ColorText> = new Vector.<ColorText>;
			colorTexts.push(new ColorText(U.OPCODE_COLOR, operation.getName()));
			for each (var color:ColorText in keys)
				colorTexts.push(new ColorText(color.color, (color == U.SOURCE ? sourceArg : color == U.TARGET ? targetArg : destArg).toString()));
			return new HighlightFormat("{} " + baseStr, colorTexts);
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
			if (this == v)
				return true;
			if (!v || !(v is InstructionValue))
				return false;
			var iv:InstructionValue = v as InstructionValue;
			return iv.operation == operation && iv.sourceArg.eq(sourceArg) && iv.targetArg.eq(targetArg) && iv.destArg.eq(destArg);
		}
	}

}