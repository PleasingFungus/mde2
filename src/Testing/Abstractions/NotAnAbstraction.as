package Testing.Abstractions {
	import Testing.Types.InstructionType;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class NotAnAbstraction extends InstructionAbstraction {
		
		public function NotAnAbstraction(a:int) {
			super(InstructionType.NOT, C.buildIntVector(a), int(!a));
		}
		
	}

}