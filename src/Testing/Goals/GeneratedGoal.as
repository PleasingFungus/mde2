package Testing.Goals {
	import Modules.Module;
	import Testing.Instructions.Instruction;
	import Values.FixedValue;
	import Values.NumericValue;
	import Values.OpcodeValue;
	import Values.Value;
	import LevelStates.LevelState;
	import Testing.Tests.Test;
	import org.flixel.FlxG;
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
		
		override public function genMem():Vector.<Value> {
			currentTest = new testClass(expectedOps);
			return currentTest.initialMemory;
		}
		
		override public function startRun():void {
			super.startRun();
			FlxG.globalSeed = 0.5;
			currentRun = 0;
		}
		
		override public function runTestStep(levelState:LevelState):void {
			C.log("Run " + currentRun + " start");
			
			currentRun += 1;
			currentTest = new testClass(expectedOps);
			var mem:Vector.<Value> = currentTest.initialMemory;
			C.log("Memory generated");
			
			levelState.initialMemory = mem;
			super.runTestStep(levelState);
		}
		
		override public function stateValid(levelState:LevelState, print:Boolean = false):Boolean {
			for (var line:int = 0; line < levelState.memory.length; line++)
				if (!levelState.memory[line].eq(currentTest.expectedMemory[line]))
					return false;
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