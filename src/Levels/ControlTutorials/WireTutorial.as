package Levels.ControlTutorials {
	import Levels.Level;
	import Modules.*;
	import Testing.Goals.WireTutorialGoal;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class WireTutorial extends Level {
		
		public function WireTutorial() {
			super("Wire Tutorial", new WireTutorialGoal, false, [], [], [new ConstIn(12, 12, 1), new ConstIn(12, 20, 2), new DataWriter(22, 16)]);
		}
		
	}

}