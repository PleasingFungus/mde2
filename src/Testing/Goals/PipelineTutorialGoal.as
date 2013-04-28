package Testing.Goals {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class PipelineTutorialGoal extends OpcodeTutorialGoal {
		
		public function PipelineTutorialGoal() {
			super(10);
			description = "Execute all instructions from memory!";
			description += "\n\n...except the time limit's pretty tight, now, and you don't have the time to wait for one instruction to finish before you start the next."
			description += "\n\n...what if you don't have to...?";
			allowedTimePerInstr = 20;
		}
		
	}

}