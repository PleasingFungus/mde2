package Testing.Goals {
	import Modules.Module;
	import Testing.Instructions.Instruction;
	import Values.FixedValue;
	import Values.NumericValue;
	import Values.OpcodeValue;
	import Values.Value;
	import LevelStates.LevelState;
	import Testing.Test;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class GeneratedGoal extends LevelGoal {
		
		protected var testClass:Class;
		protected var currentTest:Test;
		protected var expectedOps:Vector.<OpcodeValue>;
		public var testRuns:int;
		
		protected var currentRun:int;
		public function GeneratedGoal(Description:String, TestClass:Class, ExpectedOps:Vector.<OpcodeValue>, TestRuns:int = 12, Timeout:int=100) {
			super(Description);
			
			testClass = TestClass;
			expectedOps = ExpectedOps;
			testRuns = TestRuns;
			timeLimit = Timeout;
			dynamicallyTested = true;
			randomizedMemory = true;
		}
		
		override public function genMem(Seed:Number = NaN):Vector.<Value> {
			currentTest = new testClass(expectedOps, Seed);
			return currentTest.initialMemory;
		}
		
		override public function startRun():void {
			super.startRun();
			currentRun = 0;
		}
		
		override public function runTestStep(levelState:LevelState):Boolean {
			C.log("Run " + currentRun + " start");
			
			currentRun += 1;
			currentTest = new testClass(expectedOps, 1 / (currentRun + 1));
			var mem:Vector.<Value> = currentTest.initialMemory;
			C.log("Memory generated");
			
			levelState.initialMemory = mem;
			return super.runTestStep(levelState);
		}
		
		override public function stateValid(levelState:LevelState, print:Boolean = false):Boolean {
			for (var line:int = 0; line < levelState.memory.length; line++)
				if (!levelState.memory[line].eq(currentTest.expectedMemory[line])) {
					if (done())
						C.log("Discrepancy on line " + line + "; " + currentTest.expectedMemory[line] + " expected, " + levelState.memory[line] + " present");
					return false;
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