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
			super(NAME, new DoubleTutorialGoal, false, [ConstIn, Adder, BabyLatch, DataWriter, DataReader]);
			info = "Memory is an list of lines containing values, existing 'outside' the area where you place modules. Certain modules can interact with memory: data writers can set specified lines to new values, and data readers output the values specific lines contain."
			info += "\n\nOver the course of the game, you may want to re-use parts of your solutions to earlier levels. You can do this easily by copy-pasting blocs of modules & wires from one level to another. The 'bloc selection' and 'copy/paste' tutorials explain how."
			info += " If you don't want to bother with them: "+ControlSet.DRAG_MODIFY_KEY+"-drag, "+ControlSet.COPY_KEY+", switch levels, "+ControlSet.PASTE_KEY+"."
			writerLimit = 1;
			useModuleRecord = false;
		}
		
		public static const NAME:String = "Doubling";
		
	}

}