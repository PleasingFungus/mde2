package Testing.Abstractions {
	import Testing.Types.InstructionType;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class MulAbstraction extends InstructionAbstraction {
		
		public function MulAbstraction(depth:int, a1:int, a2:int) {
			super(InstructionType.MUL, depth, C.buildIntVector(a1, a2), a1 * a2);
		}
		
	}

}