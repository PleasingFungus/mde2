package Testing.Tests {
	import flash.utils.Dictionary;
	import Modules.Module;
	import org.flixel.FlxG;
	import Testing.Abstractions.InstructionAbstraction;
	import Testing.Abstractions.SaveAbstraction;
	import Testing.Abstractions.SetAbstraction;
	import Testing.Instructions.Instruction;
	import Testing.Instructions.JumpInstruction;
	import Testing.Types.InstructionType;
	import Values.*;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class RegfileTest extends Test {
		
		public function RegfileTest(ExpectedOps:Vector.<OpcodeValue>, seed:Number = NaN) {
			super(ExpectedOps, seed);
			instructions.pop(); //remove save instruction
		}
		
		override protected function genExpectedMemory():Vector.<Value> {
			var memory:Vector.<Value> = initialMemory.slice();
			var registers:Dictionary = new Dictionary;
			super.executeInEnvironment(new Dictionary, registers, instructions);
			for (var strIndex:String in registers) {
				var index:int = int(strIndex);
				var value:int = registers[strIndex];
				memory[index] = new NumericValue(value);
			}
			return memory;
		}
		
	}

}