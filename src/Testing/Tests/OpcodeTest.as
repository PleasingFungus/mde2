package Testing.Tests {
	import Values.*;
	import org.flixel.FlxG;
	import Testing.Instructions.Instruction;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class OpcodeTest extends Test {
		
		public var saves:Vector.<InstructionValue>;
		public function OpcodeTest(_:Vector.<OpcodeValue>, __:int = -1, Seed:Number = NaN) {
			super(_, -1, Seed); 
		}
		
		override protected function generate():void {
			var savesToGenerate:int = C.randomRange(3, 6);
			saves = new Vector.<InstructionValue>;
			for (var i:int = 0; i < savesToGenerate; i++) {
				var line:int = C.randomRange(8, U.MAX_MEM);
				if (line < 8)
					throw Error("!!!");
				var value:int = C.randomRange(U.MIN_INT, U.MAX_INT + 1);
				saves.push(new InstructionValue(OpcodeValue.OP_SAVI, value, line, C.INT_NULL));
			}
			
			instructions = new Vector.<Instruction>;
			expectedExecutions = saves.length;
		}
		
		override protected function genInitialMemory():Vector.<Value> {
			var memory:Vector.<Value> = generateBlankMemory();
			for (var i:int = 0; i < saves.length; i++)
				memory[i] = saves[i];
			return memory;
		}
		
		override protected function genExpectedMemory():Vector.<Value> {
			var memory:Vector.<Value> = initialMemory.slice();
			for each (var saveInstr:InstructionValue in saves)
				memory[saveInstr.targetArg.toNumber()] = saveInstr.sourceArg;
			return memory;
		}
	}

}