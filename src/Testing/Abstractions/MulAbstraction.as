package Testing.Abstractions {
	import Testing.Types.InstructionType;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class MulAbstraction extends InstructionAbstraction {
		
		public function MulAbstraction(a1:int, a2:int) {
			super(InstructionType.MUL, C.buildIntVector(a1, a2), a1 != C.INT_NULL ? a1 * a2 : C.INT_NULL);
		}
		
	}

}