package Testing.Types {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class AbstractArg {
		
		public var value:int;
		public var address:int;
		public function AbstractArg(Value:int, Address:int = C.INT_NULL) {
			value = Value;
			address = Address;
		}
		
		public function get inMemory():Boolean {
			return address != C.INT_NULL;
		}
		
		public function get inRegisters():Boolean {
			return address == C.INT_NULL;
		}
		
		public function toString():String {
			if (inRegisters)
				return value + "";
			return value +" (M" + address + ")";
		}
		
		public function eq(arg:AbstractArg):Boolean {
			return value == arg.value && address == arg.address;
		}
		
		
		public static function instructionsToSet(values:Vector.<AbstractArg>):int {
			var toSet:int = 0;
			for each (var arg:AbstractArg in values)
				toSet += arg.inMemory ? 0 : 1;
			return toSet;
		}
		
		public static function argInVec(arg:AbstractArg, vec:Vector.<AbstractArg>):Boolean {
			for each (var otherArg:AbstractArg in vec)
				if (arg.eq(otherArg))
					return true;
			return false;
		}
		
		public static function addrInVec(addr:int, vec:Vector.<AbstractArg>):Boolean {
			for each (var arg:AbstractArg in vec)
				if (arg.address == addr)
					return true;
			return false;
		}
	}

}