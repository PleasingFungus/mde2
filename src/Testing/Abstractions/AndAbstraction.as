package Testing.Abstractions {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class AndAbstraction extends InstructionAbstraction {
		
		public function AndAbstraction(depth:int, a1:int, a2:int) {
			super(InstructionType.AND, depth, C.buildIntVector(a1, a2), a1 && a2);
		}
		
	}

}