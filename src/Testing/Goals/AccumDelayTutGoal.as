package Testing.Goals {
	import Values.Value;
	import Values.NumericValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class AccumDelayTutGoal extends AccumulatorTutorialGoal {
		
		public function AccumDelayTutGoal() {
			super();
			timeLimit = 80;
			description = "Set memory lines 1-5 to 1-5!"
			description += "\n\nSame as the last one, but now you'll have to use the full-featured DataMemory module, which has a delay of 10 ticks."
			
			expectedMemory = generateBlankMemory();
			for (var i:int = 1; i <= 5; i++)
				expectedMemory[i] = new NumericValue(i);
		}
	}

}