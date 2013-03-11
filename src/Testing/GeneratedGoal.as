package Testing {
	import Modules.Module;
	import Testing.Instructions.Instruction;
	import Values.FixedValue;
	import Values.OpcodeValue;
	import Values.Value;
	import LevelStates.LevelState;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class GeneratedGoal extends LevelGoal {
		
		protected var currentTest:Test;
		protected var expectedOps:Vector.<OpcodeValue>;
		public var testRuns:int;
		
		protected var currentRun:int;
		public function GeneratedGoal(Description:String, ExpectedOps:Vector.<OpcodeValue>, TestRuns:int = 12, Timeout:int=100) {
			super(Description);
			
			expectedOps = ExpectedOps;
			testRuns = TestRuns;
			timeLimit = Timeout;
			dynamicallyTested = true;
			randomizedMemory = true;
		}
		
		override public function genMem(Seed:Number = NaN):Vector.<Value> {
			return (new Test(expectedOps, Seed) as Test).initialMemory();
		}
		
		override public function startRun():void {
			super.startRun();
			currentRun = 0;
		}
		
		override public function runTestStep(levelState:LevelState):Boolean {
			C.log("Run " + currentRun + " start");
			
			currentRun += 1;
			currentTest = new Test(expectedOps, currentRun + 0.5);
			var mem:Vector.<Value> = currentTest.initialMemory();
			C.log("Memory generated");
			
			levelState.initialMemory = mem;
			return super.runTestStep(levelState);
		}
		
		override public function stateValid(levelState:LevelState, print:Boolean=false):Boolean {
			for (var line:int = 0; line < levelState.memory.length; line++) {
				var lineValue:Value = levelState.memory[line];
				if (line == currentTest.memAddressToSet) {
					if (lineValue.toNumber() != currentTest.memValueToSet) {
						if (print)
							C.log("Expected value not set correctly: " + line + " " + (lineValue.toNumber() == C.INT_NULL ? "NULL" : lineValue.toNumber()) + " instead of " + currentTest.memValueToSet);
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
		
		override public function getProgress():String {
			return currentRun+"/"+testRuns;
		}
		
		override protected function done():Boolean {
			return currentRun >= testRuns;
		}
		
	}

}