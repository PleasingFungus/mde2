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
		public var minInstructions:int;
		public var timePerRun:Vector.<int>;
		
		protected var currentRun:int;
		public function GeneratedGoal(Description:String, TestClass:Class, ExpectedOps:Vector.<OpcodeValue>, TestRuns:int = 12, Timeout:int=100, MinInstructions:int = 10) {
			super(Description);
			
			testClass = TestClass;
			expectedOps = ExpectedOps;
			testRuns = TestRuns;
			minInstructions = MinInstructions;
			timeLimit = Timeout;
			dynamicallyTested = true;
			randomizedMemory = true;
		}
		
		override public function genMem():Vector.<Value> {
			currentTest = new testClass(expectedOps, minInstructions);
			return currentTest.initialMemory;
		}
		
		override public function genExpectedMem():Vector.<Value> {
			if (!currentTest) return null;
			return currentTest.expectedMemory;
		}
		
		override public function startRun():void {
			super.startRun();
			FlxG.globalSeed = 0.5;
			currentRun = 0;
			timePerRun = new Vector.<int>;
		}
		
		override public function runTestStep(levelState:LevelState):void {
			C.log("Run " + currentRun + " start");
			
			currentRun += 1;
			currentTest = new testClass(expectedOps, minInstructions);
			var mem:Vector.<Value> = currentTest.initialMemory;
			C.log("Memory generated");
			
			levelState.initialMemory = mem;
			super.runTestStep(levelState);
			if (succeeded)
				timePerRun.push(U.state.time.moment);
		}
		
		override public function getProgress():String {
			return currentRun + "/" + testRuns + '\n' + getTime();
		}
		
		override public function getTime():String {
			return 'Average ticks per test: '+averageTimePerRun();
		}
		
		override protected function done():Boolean {
			return currentRun >= testRuns;
		}
		
		public function averageTimePerRun():int {
			if (!timePerRun.length) return 0;
			
			var avg:int = 0;
			for each (var timeTaken:int in timePerRun)
				avg += timeTaken;
			return avg / timePerRun.length;
		}
		
	}

}