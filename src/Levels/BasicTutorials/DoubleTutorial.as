package Levels.BasicTutorials {
	import Controls.ControlSet;
	import Levels.Level;
	import Modules.*;
	import Testing.Goals.DoubleTutorialGoal;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DoubleTutorial extends Level {
		
		public function DoubleTutorial() {
			super(NAME, new DoubleTutorialGoal, false, [ConstIn, Adder, Latch, DataWriter, DataReader]);
			info = "Memory is an list of lines containing values, existing 'outside' the area where you place modules. Certain modules can interact with memory: data writers can set specified lines to new values, and data readers output the values specific lines contain."
			writerLimit = 1;
			useModuleRecord = false;
		}
		
		public static const NAME:String = "Doubling";
		
	}

}