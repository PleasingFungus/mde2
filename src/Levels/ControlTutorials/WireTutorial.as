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
			info = "To place a wire, click & drag anywhere but on a module."
			info += " Wires are used to transmit values between modules"
			info += "\n\nModules have a limited number of connection points, arrow-shaped 'ports'.";
			info += " There are two types of ports: outputs, which are always on the right & point outwards, and inputs, which are on modules' other sides & point inward."
			info += " Outputs create values. Inputs determine what a module does."
			info += " You can mouse over ports & wires to see their present value & more information."
			info += "\n\nWires can be used to create circuits, connecting any number of inputs to a single output."
			//info += " You cannot connect more than one output to a circuit."
			info += "\n\nWhen you think you've built a solution, click the 'test' button at the top-center to see if your machine passes the test."
			info += "\n\nHave fun!";
		}
		
	}

}