package Testing.Abstractions {
	import Testing.Types.AbstractArg;
	import Testing.Types.InstructionType;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InstructionAbstraction {
		
		public var type:InstructionType;
		public var args:Vector.<int>;
		public var value:int;
		public function InstructionAbstraction(type:InstructionType, args:Vector.<int>, value:int) {
			this.type = type;
			this.args = args ? args : new Vector.<int>;
			this.value = value; 
		}
		
		public function toString():String {
			var out:String = "";
			out += type.name + " ";
			for each (var arg:int in args)
				out += arg +" ";
			if (value != C.INT_NULL)
				out += "= " + value;
			return out;
		}
		
		public function getAbstractArgs():Vector.<AbstractArg> {
			var abstractArgs:Vector.<AbstractArg> = new Vector.<AbstractArg>;
			for each (var arg:int in args)
				abstractArgs.push(new AbstractArg(arg));
			return abstractArgs;
		}
	}

}