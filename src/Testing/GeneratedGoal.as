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
		protected var currentTest:Test;
		public var testRuns:int;
		public function GeneratedGoal(Description:String, TestClass:Class, TestRuns:int = 12, Timeout:int=100) {
			super(Description);
			
			testClass = TestClass;
			testRuns = TestRuns;
			timeLimit = Timeout;
		}
		
		override public function genMem(Seed:Number = NaN):Vector.<Value> {
			return memFromTest(new testClass(Seed));
		}
		
		protected function memFromTest(test:Test = null):Vector.<Value> {
			if (!test) test = currentTest;
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
				
				currentTest = new testClass;
				var mem:Vector.<Value> = memFromTest(currentTest);
				C.log("Memory generated");
				
				levelState.initialMemory = mem;
				levelState.time.reset();
				while (levelState.time.moment < timeLimit && !stateValid(levelState))
					levelState.time.step();
				
				if (!stateValid(levelState))
					break;
			}
			
			if (stateValid(levelState, true))
				C.log("Success!");
			else
				C.log("Failure!");
			
			levelState.time.reset();
			levelState.runTest();
		}
		
		override public function stateValid(levelState:LevelState, print:Boolean=false):Boolean {
			for (var line:int = 0; line < levelState.memory.length; line++) {
				var lineValue:Value = levelState.memory[line];
				if (line == currentTest.memAddressToSet) {
					if (lineValue.toNumber() != currentTest.memValueToSet) {
						if (print)
							C.log("Expected value not set correctly: " + line+" " + lineValue.toNumber() + " instead of " + currentTest.memValueToSet);
						return false;
					}
				} else if (line < currentTest.instructions.length) {
					if (!lineValue.eq(currentTest.instructions[line].toMemValue())) {
						if (print)
							C.log("Instruction @" + line+" mangled to " + lineValue+" instead of "+currentTest.instructions[line].toMemValue());
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