package Testing.Abstractions {
	import Testing.Types.InstructionType;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SetAbstraction extends InstructionAbstraction {
		
		public function SetAbstraction(depth:int, value:int) {
			super(InstructionType.SET, depth, new Vector.<int>, value);
		}
		
		override public function toString():String {
			return type.name + " " + value;
		}
		
	}

}