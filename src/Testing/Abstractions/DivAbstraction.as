package Testing.Abstractions {
	import Testing.Types.InstructionType;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DivAbstraction extends InstructionAbstraction {
		
		public function DivAbstraction(a1:int, a2:int) {
			super(InstructionType.DIV, C.buildIntVector(a1, a2), a2 ? a1 / a2 : NaN);
			if (a2 == 0)
				throw new Error("!!!");
		}
		
	}

}