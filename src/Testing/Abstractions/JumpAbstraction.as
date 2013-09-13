package Testing.Abstractions {
	import Testing.Types.InstructionType;
	import UI.HighlightFormat;
	import UI.ColorText;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class JumpAbstraction extends InstructionAbstraction {
		
		public function JumpAbstraction(t:int) {
			super(InstructionType.JUMP, new Vector.<int>, t);
		}
		
		override public function toString():String {
			if (comment)
				return comment;
			return null;
			//return type.name +" over " + value;
		}
		
		override public function toFormat():HighlightFormat {
			if (commentFormat)
				return commentFormat;
			return null;
			//return new HighlightFormat(type.name +" over {}", ColorText.singleVec(new ColorText(U.DESTINATION.color, value.toString())));
		}
		
	}

}