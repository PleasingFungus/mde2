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
		public var allowedTimePerInstr:int;
		public var timePerInstr:Vector.<Number>;
		
		protected var currentRun:int;
		public function GeneratedGoal(TestClass:Class, ExpectedOps:Vector.<OpcodeValue>, TestRuns:int = 12, AllowedTimePerInstr:int=3, MinInstructions:int = 10) {
			super();
			description = "Execute all instructions!";
			
			testClass = TestClass;
			expectedOps = ExpectedOps;
			testRuns = TestRuns;
			minInstructions = MinInstructions;
			allowedTimePerInstr = AllowedTimePerInstr;
			dynamicallyTested = true;
			randomizedMemory = true;
		}
		
		override public function genMem():Vector.<Value> {
			currentTest = new testClass(expectedOps, minInstructions);
			timeLimit = currentTest.expectedExecutions * allowedTimePerInstr;
			if (!timeLimit) throw new Error("Time limit must be > 0!");
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
			timePerInstr = new Vector.<Number>;
		}
		
		override public function runTestStep(levelState:LevelState):void {
			C.log("Run " + currentRun + " start");
			
			currentRun += 1;
			currentTest = new testClass(expectedOps, minInstructions);
			timeLimit = currentTest.expectedExecutions * allowedTimePerInstr;
			if (!timeLimit) throw new Error("Time limit must be > 0!");
			var mem:Vector.<Value> = currentTest.initialMemory;
			C.log("Memory generated");
			
			levelState.initialMemory = mem;
			super.runTestStep(levelState);
			if (succeeded)
				timePerInstr.push(U.state.time.moment / currentTest.expectedExecutions);
		}
		
		override public function getProgress():String {
			return currentRun + "/" + testRuns + '\n' + getTime();
		}
		
		override public function getTime():String {
			return 'Average ticks per instruction: '+averageTimePerInstruction();
		}
		
		override protected function done():Boolean {
			return currentRun >= testRuns;
		}
		
		public function averageTimePerInstruction():Number {
			if (!timePerInstr.length) return 0;
			
			var avg:Number = 0;
			for each (var timeTaken:Number in timePerInstr)
				avg += timeTaken;
			return int(avg * 10 / timePerInstr.length) / 10;
		}
		
	}

}