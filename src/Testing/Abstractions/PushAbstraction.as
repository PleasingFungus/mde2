package Testing.Abstractions {
	import Testing.Types.InstructionType;
	import UI.ColorText;
	import UI.HighlightFormat;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class PushAbstraction extends InstructionAbstraction {
		
		public function PushAbstraction(value:int) {
			super(InstructionType.PUSH, C.buildIntVector(value), C.INT_NULL);
			writesToStack = true;
		}
		
		override public function toString():String {
			return type.name + " " + args[0];
		}
		
		override public function toFormat():HighlightFormat {
			return new HighlightFormat(type.name +" {}", ColorText.singleVec(new ColorText(U.SOURCE.color, args[0].toString())));
		}
		
		override public function get stackValue():int { return args[0] }
	}

}