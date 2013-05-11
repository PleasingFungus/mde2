package Levels.ControlTutorials {
	import Controls.ControlSet;
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
			info = "To place modules, use the module menu in the top-left."
			info += " Choose a category and then a module; then click to place the module wherever you want. You can place an unlimited number of most modules.";
			info += "\n\nYou can click again to pick modules up after you've placed them; or, you can delete them (and wires) by mousing over them and pressing " + ControlSet.DELETE_KEY + ".";
			info += "\n\nAs before, once your machine is done, click 'test' in the top-center.";
		}
		
	}

}