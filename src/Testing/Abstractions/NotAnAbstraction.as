package Testing.Abstractions {
	import Testing.Types.InstructionType;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class NotAnAbstraction extends InstructionAbstraction {
		
		public function NotAnAbstraction(depth:int, a:int) {
			super(InstructionType.NOT, depth, C.buildIntVector(a), int(!a));
		}
		
	}

}