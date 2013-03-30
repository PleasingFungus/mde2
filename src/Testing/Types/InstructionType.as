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
		
		public function can_produce_with(value:AbstractArg, args:Vector.<AbstractArg>):Boolean {
			return false;
		}
		
		public function can_produce_with_one(value:AbstractArg, arg:AbstractArg):Boolean {
			return false;
		}
		
		public function can_produce_with_one_of(value:AbstractArg, args:Vector.<AbstractArg>):Boolean {
			return false;
		}
		
		public function produce_unrestrained(value:AbstractArg):InstructionAbstraction {
			return null;
		}
		
		public function produce_with(value:AbstractArg, args:Vector.<AbstractArg>):InstructionAbstraction {
			return null;
		}
		
		public function produce_with_one(value:AbstractArg, arg:AbstractArg):InstructionAbstraction {
			return null;
		}
		
		public static var SET:SetType;
		public static var LOAD:LoadType;
		public static var ADD:AddType;
		public static var SUB:SubType;
		public static var MUL:MulType;
		public static var DIV:DivType;
		//public static var AND:AndType;
		public static var NOT:NotAType;
		public static var SAVE:SaveType;
		
		public static function init():void {
			SET = new SetType();
			LOAD = new LoadType();
			ADD = new AddType();
			SUB = new SubType();
			MUL = new MulType();
			DIV = new DivType();
			//AND = new AndType();
			NOT = new NotAType();
			SAVE = new SaveType();
		}
	}

}