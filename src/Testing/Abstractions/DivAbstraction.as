package Testing.Abstractions {
	import Testing.Types.InstructionType;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DivAbstraction extends InstructionAbstraction {
		
		public function DivAbstraction(a1:int, a2:int) {
			super(InstructionType.DIV, C.buildIntVector(a1, a2), a1 != C.INT_NULL ? a1 / a2 : C.INT_NULL);
			if (!a2)
				throw new Error("Dividing by zero!");
		}
		
	}

}