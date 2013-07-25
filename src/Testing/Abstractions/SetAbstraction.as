package Testing.Abstractions {
	import Testing.Types.InstructionType;
	import UI.HighlightFormat;
	import UI.ColorText;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SetAbstraction extends InstructionAbstraction {
		
		public function SetAbstraction(value:int) {
			super(InstructionType.SET, new Vector.<int>, value);
		}
		
		override public function toString():String {
			return type.name + " " + value;
		}
		
		override public function toFormat():HighlightFormat {
			return new HighlightFormat(type.name + " {}",
									   ColorText.singleVec(new ColorText(U.DESTINATION.color, value.toString())));
		}
		
	}

}