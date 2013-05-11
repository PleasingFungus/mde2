package Levels.ControlTutorials {
	import Levels.Level;
	import Modules.*;
	import Testing.Goals.WireTutorialGoal;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ModuleTutorial extends Level {
		
		public function ModuleTutorial() {
			super("Module Tutorial", new WireTutorialGoal, false, [Adder, DataWriter], [], [new ConstIn(12, 16, 1)])
		}
		
	}

}