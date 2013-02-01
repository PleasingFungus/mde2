package Testing.Abstractions {
	import Testing.Types.InstructionType;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class AddAbstraction extends InstructionAbstraction {
		
		public function AddAbstraction(depth:int, a1:int, a2:int) {
			super(InstructionType.ADD, depth, C.buildIntVector(a1, a2), a1 + a2);
		}
		
	}

}