package Testing.Abstractions {
	import Testing.Types.InstructionType;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SaveAbstraction extends InstructionAbstraction {
		
		public function SaveAbstraction(a1:int, a2:int) {
			super(InstructionType.SAVE, C.buildIntVector(a1, a2), C.INT_NULL);
		}
		
		override public function toString():String {
			return type.name + " " + args[0] + " -> " + args[1];
		}
	}

}