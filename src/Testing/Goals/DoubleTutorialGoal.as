package Testing.Goals {
	import LevelStates.LevelState;
	import Values.Value;
	import Values.IntegerValue;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DoubleTutorialGoal extends GeneratedGoal {
		
		private var currentValues:Vector.<Value>;
		private var expectedMem:Vector.<Value>;
		public function DoubleTutorialGoal() {
			super(null, null, 6, 2, 5);
			description = "Double the values in memory lines 0-4!";
		}
		
		override public function genMem():Vector.<Value> {
			currentValues = new Vector.<Value>;
			var baseMem:Vector.<Value> = generateBlankMemory();
			expectedMem = baseMem.slice();
			for (var i:int = 0; i < 5; i++) {
				currentValues.push(new IntegerValue(C.randomRange(U.MIN_INT, U.MAX_INT/* + 1*/)));
				baseMem[i] = currentValues[i];
				expectedMem[i] = new IntegerValue(currentValues[i].toNumber() * 2);
			}
			timeLimit = 10;
			
			return baseMem;
		}
		
		override public function genExpectedMem():Vector.<Value> {
			return expectedMem;
		}
		
		override protected function get executionCount():int {
			return 5
		}
		
	}

}