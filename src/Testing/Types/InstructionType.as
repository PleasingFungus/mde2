package Testing.Types {
	import Testing.Abstractions.InstructionAbstraction;
	import Values.OpcodeValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InstructionType {
		
		public var name:String;
		public function InstructionType(name:String) {
			this.name = name;
		}
		
		public function toString():String {
			return "<"+this.name+">";
		}
		
		public function mapToOp():OpcodeValue {
			return OpcodeValue.OP_NOOP;
		}
		
		public function can_produce(value:AbstractArg):Boolean {
			return false;
		}
		
		
		public function requiredArgsToProduce(value:AbstractArg, args:Vector.<AbstractArg>):int {
			if (can_produce_with(value, args))
				return 0;
			if (can_produce_with_one_of(value, args))
				return 1;
			return 2;
		}
		
		protected function can_produce_with(value:AbstractArg, args:Vector.<AbstractArg>):Boolean {
			return false;
		}
		
		protected function can_produce_with_one(value:AbstractArg, arg:AbstractArg):Boolean {
			return false;
		}
		
		protected function can_produce_with_one_of(valueAbstr:AbstractArg, args:Vector.<AbstractArg>):Boolean {
			for each (var arg:AbstractArg in args)
				if (can_produce_with_one(valueAbstr, arg))
					return true;
			return false;
		}
		
		
		public function produceMinimally(value:AbstractArg, args:Vector.<AbstractArg>, argsToUse:int = C.INT_NULL):InstructionAbstraction {
			if (argsToUse == C.INT_NULL)
				argsToUse = requiredArgsToProduce(value, args);
			switch (argsToUse) {
				case 0: return produce_with(value, args);
				case 1: 
					for each (var arg:AbstractArg in args)
						if (can_produce_with_one(value, arg))
							return produce_with_one(value, arg);
					throw new Error("!!");
				case 2: default: return produce_unrestrained(value);
			}
		}
		
		protected function produce_unrestrained(value:AbstractArg):InstructionAbstraction {
			return null;
		}
		
		protected function produce_with(value:AbstractArg, args:Vector.<AbstractArg>):InstructionAbstraction {
			return null;
		}
		
		protected function produce_with_one(value:AbstractArg, arg:AbstractArg):InstructionAbstraction {
			return null;
		}
		
		public function produce(...args):InstructionAbstraction { throw new Error("Not implemented!"); }
		
		public static var SET:SetType;
		public static var LOAD:LoadType;
		public static var ADD:AddType;
		public static var SUB:SubType;
		public static var MUL:MulType;
		public static var DIV:DivType;
		//public static var AND:AndType;
		public static var SAVE:SaveType;
		public static var JUMP:JumpType;
		public static var BEQ:InstructionType;
		
		public static var SAVI:SaveImmediateType;
		public static var ADDM:AddMemoryType;
		
		public static function init():void {
			SET = new SetType();
			LOAD = new LoadType();
			ADD = new AddType();
			SUB = new SubType();
			MUL = new MulType();
			DIV = new DivType();
			//AND = new AndType();
			SAVE = new SaveType();
			JUMP = new JumpType();
			BEQ = new InstructionType("Branch");
			
			SAVI = new SaveImmediateType();
			ADDM = new AddMemoryType();
		}
	}

}