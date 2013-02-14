package Testing {
	import Modules.Module;
	import Testing.Instructions.Instruction;
	import Values.FixedValue;
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class GeneratedGoal extends LevelGoal {
		
		protected var testClass:Class;
		public var testRuns:int;
		public var timeout:int;
		public function GeneratedGoal(Description:String, TestClass:Class, TestRuns:int = 12, Timeout:int=100) {
			testClass = TestClass;
			testRuns = TestRuns;
			timeout = Timeout;
			
			super(Description);
		}
		
		override public function genMem(Seed:Number = NaN):Vector.<Value> {
			return memFromTest(new testClass(Seed));
		}
		
		protected function memFromTest(test:Test):Vector.<Value> {
			var instructions:Vector.<Instruction> = test.instructions;
			var memory:Vector.<Value> = new Vector.<Value>;
			for each (var instr:Instruction in instructions)
				memory.push(instr.toMemValue());
			for (var i:int = memory.length; i < U.MAX_INT - U.MIN_INT; i++)
				memory.push(FixedValue.NULL);
			return memory;
		}
		
		override public function runTest(levelState:LevelState):void {
			for (var run:int = 0; run < testRuns; run++) {
				C.log("Run " + run + " start");
				
				var test:Test = new testClass;
				var mem:Vector.<Value> = memFromTest(test);
				C.log("Memory generated");
				
				levelState.initialMemory = mem;
				levelState.time.reset();
				while (levelState.time.moment < timeout && !stateValid(levelState, test))
					levelState.time.step();
				
				if (!stateValid(levelState, test))
					break;
			}
			
			if (stateValid(levelState, test, true))
				C.log("Success!");
			else
				C.log("Failure!");
			
			levelState.time.reset();
			levelState.runTest();
		}
		
		protected function stateValid(levelState:LevelState, test:Test, print:Boolean=false):Boolean {
			for (var line:int = 0; line < levelState.memory.length; line++) {
				var lineValue:Value = levelState.memory[line];
				if (line == test.memAddressToSet) {
					if (lineValue.toNumber() != test.memValueToSet) {
						if (print)
							C.log("Expected value not set correctly: " + line+" " + lineValue.toNumber() + " instead of " + test.memValueToSet);
						return false;
					}
				} else if (line < test.instructions.length) {
					if (!lineValue.eq(test.instructions[line].toMemValue())) {
						if (print)
							C.log("Instruction @" + line+" mangled to " + lineValue+" instead of "+test.instructions[line].toMemValue());
						return false;
					}
				} else if (lineValue != FixedValue.NULL) {
					if (print)
						C.log("Line "+line+" "+lineValue+" instead of expected NULL");
					return false;
				}
			}
			return true;
		}
		
	}

}