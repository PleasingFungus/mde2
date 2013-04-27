package Testing.Goals {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class MagicAccumDelayTutGoal extends AccumulatorTutorialGoal {
		
		public function MagicAccumDelayTutGoal() {
			super();
			timeLimit = 40;
			description = "Set memory lines 0-4 to 0-4!"
			description += "\n\n...except now, some modules have 'propagation delay' values, meaning that they take some number of ticks of constant input before they settle down & output a result. (In the meantime, they'll output garbage 'unknown' data.)"
			description += "\n\nTo deal with the new problem, set up a clock so that you only update the latch once everything's done thinking."
		}
		
	}

}