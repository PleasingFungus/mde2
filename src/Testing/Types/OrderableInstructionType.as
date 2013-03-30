package Testing.Types {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class OrderableInstructionType {

		public var type:InstructionType;
		public var argsNeeded:int;
		public var numAlreadyProduced:int;
		public function OrderableInstructionType(Type:InstructionType, ArgsNeeded:int, NumAlreadyProduced:int) {
			type = Type;
			argsNeeded = ArgsNeeded;
			numAlreadyProduced = NumAlreadyProduced;
		}
		
	}

}