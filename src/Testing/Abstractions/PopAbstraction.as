package Testing.Abstractions {
	import Testing.Types.InstructionType;
	import UI.ColorText;
	import UI.HighlightFormat;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class PopAbstraction extends InstructionAbstraction {
		
		public function PopAbstraction(value:int) {
			super(InstructionType.POP, new Vector.<int>, value);
		}
		
		override public function toString():String {
			return type.name + " " + value;
		}
		
		override public function toFormat():HighlightFormat {
			return new HighlightFormat(type.name +" {}", ColorText.singleVec(new ColorText(U.DESTINATION.color, value.toString())));
		}
	}

}