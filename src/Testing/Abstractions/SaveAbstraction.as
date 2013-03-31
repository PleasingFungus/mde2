package Testing.Abstractions {
	import Testing.Types.InstructionType;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SaveAbstraction extends InstructionAbstraction {
		
		public function SaveAbstraction(value:int, address:int) {
			super(InstructionType.SAVE, C.buildIntVector(value, address), C.INT_NULL);
		}
		
		override public function toString():String {
			return type.name + " M[" + args[1] + "]=" + args[0];
		}
	}

}