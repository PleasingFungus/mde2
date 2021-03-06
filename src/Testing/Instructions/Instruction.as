package Testing.Instructions {
	import flash.utils.Dictionary;
	import Testing.Abstractions.InstructionAbstraction;
	import Testing.Types.InstructionType;
	import Values.InstructionValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Instruction {
		
		public var abstract:InstructionAbstraction;
		public var args:Vector.<InstructionArg>;
		public var type:InstructionType;
		public var noop:Boolean;
		public var comment:String;
		public var validValues:Vector.<int>;
		public function Instruction(registers:Vector.<int>, abstract:InstructionAbstraction, noop:Boolean) {
			this.abstract = abstract;
			this.type = abstract.type;
			this.args = findArgs(registers, abstract);
			this.noop = noop;
			this.comment = abstract.toString();
			if (noop)
				this.comment += " (NOOP)";
		}
		
		public function toString():String {
			var out:String = "";
			out += type.name + " ";
			for each (var arg:InstructionArg in args)
				out += arg +" ";
			out += "#" + comment;
			return out;
		}
		
		protected function findArgs(registers:Vector.<int>, abstract:InstructionAbstraction):Vector.<InstructionArg> {
			return null;
		}
		
		public function execute(memory:Dictionary, registers:Dictionary, stack:Vector.<int>):int {
			return C.INT_NULL;
		}
		
		public function toMemValue():InstructionValue {
			return null;
		}
		
		public static function mapByType(type:InstructionType):Class {
			switch (type) {
				case InstructionType.ADD:
					return AddInstruction;
				case InstructionType.SUB:
					return SubInstruction;
				case InstructionType.MUL:
					return MulInstruction;
				case InstructionType.DIV:
					return DivInstruction;
				case InstructionType.SAVE:
					return SaveInstruction;
				case InstructionType.LOAD:
					return LoadInstruction;
				case InstructionType.SET:
					return SetInstruction;
				
				case InstructionType.SAVI:
					return SaveImmediateInstruction;
				case InstructionType.ADDM:
					return AddMemoryInstruction;
				
				case InstructionType.PUSH:
					return PushInstruction;
				case InstructionType.POP:
					return PopInstruction;
			}
			return null;
		}
	}

}