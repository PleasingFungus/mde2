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
	import Testing.Types.AbstractArg;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class RegfileTest extends Test {
		
		private var firstValue:int;
		public function RegfileTest(ExpectedOps:Vector.<OpcodeValue>, seed:Number = NaN) {
			super(ExpectedOps, seed);
		}
		
		override protected function genFirstValue():AbstractArg {
			firstValue = C.randomRange(U.MIN_INT, U.MAX_INT);
			return new AbstractArg(firstValue);
		}
		
		override protected function initializeRegisters():Vector.<int> {
			var registers:Vector.<int> = super.initializeRegisters();
			registers[C.randomRange(0, NUM_REGISTERS)] = firstValue;
			return registers;
		}
		
		override protected function testRun():void {
			//pass
		}
		
		override protected function genExpectedMemory():Vector.<Value> {
			var memory:Vector.<Value> = initialMemory.slice();
			var registers:Dictionary = new Dictionary;
			super.executeInEnvironment(new Dictionary, registers, instructions);
			for (var strIndex:String in registers) {
				var index:int = int(strIndex);
				var value:int = registers[strIndex];
				memory[index + U.MIN_MEM] = new NumericValue(value);
			}
			return memory;
		}
		
	}

}