package Testing.Instructions {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InstructionArg {
		
		public var argType:int;
		public var value:int;
		public function InstructionArg(argType:int, value:int) {
			this.argType = argType;
			this.value = value;
		}

		public function toString():String {
			if (argType == INT)
				return value + '';
			else if (argType == REG)
				return 'R'+value
			return '???'
		}
	
		public static const INT:int = 0;
		public static const REG:int = 1;
	}

}