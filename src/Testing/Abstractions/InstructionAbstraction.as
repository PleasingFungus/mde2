package Testing.Abstractions {
	import Testing.Types.InstructionType;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InstructionAbstraction {
		
		public var type:InstructionType;
		public var depth:int;
		public var args:Vector.<int>;
		public var value:int;
		public function InstructionAbstraction(type:InstructionType, depth:int, args:Vector.<int>, value:int) {
			this.type = type;
			this.depth = depth;
			this.args = args ? args : new Vector.<int>;
			this.value = value; 
		}
		
		public function toString():String {
			var out:String = "";
			out += type.name + " ";
			for each (var arg:int in args)
				out += arg +" ";
			out += "= " + value;
			return out;
		}
	}

}