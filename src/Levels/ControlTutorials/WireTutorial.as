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
			info = "Modules are little blocky machines that do things. You interact with them by connecting their input & output 'ports' together with wires."
			info += "\n\nOutput ports are on the right of modules & point out. They output values."
			info += "\n\nInput ports are on the left & top of modules & point in. The values that you hook into these (with wires) determines what the module does & outputs."
			//info = "To place a wire, click & drag anywhere but on a module."
			//info += "\n\nModules have a limited number of connection points, arrow-shaped 'ports'.";
			//info += " There are two types of ports: outputs, which are always on the right & point outwards, and inputs, which are on modules' other sides & point inward."
			//info += " Outputs create values. Inputs determine what a module does."
			//info += " You can mouse over ports & wires to see their present value & more information."
			//info += "\n\nWires can be used to create circuits, connecting any number of inputs to a single output."
			//info += " You cannot connect more than one output to a circuit."
			info += "\n\nDraw wires to connect ports (by clicking & dragging anywhere but on a module) & experiment."
			info += " When you think you've built a solution, click the 'test' button at the top-center to see if your machine passes the test."
			info += "\n\nHave fun!";
		}
		
	}

}