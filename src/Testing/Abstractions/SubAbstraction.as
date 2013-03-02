package Testing.Abstractions {
	import Testing.Types.InstructionType;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SubAbstraction extends InstructionAbstraction {
		
		public function SubAbstraction(depth:int, a1:int, a2:int) {
			super(InstructionType.SUB, depth, C.buildIntVector(a1, a2), a1 - a2);
		}
		
		
	}

}