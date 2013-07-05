package Levels.ControlTutorials {
	import Levels.Level;
	import Modules.*;
	import Testing.Goals.WireTutorialGoal;
	import Controls.ControlSet;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class CopyingTutorial extends Level {
		
		public function CopyingTutorial() {
			super(NAME, new WireTutorialGoal(), false, [ConstIn, Adder, DataWriter]);
			
			info = "Copy modules and wires by shift-dragging to select them, then pressing " + ControlSet.COPY_KEY + " to copy and " + ControlSet.PASTE_KEY + " to paste.";
			info += "\n\n\(You can copy within and between levels.)"
			
			canDrawWires = canPlaceModules = false;
			useModuleRecord = false;
		}
		
		public static const NAME:String = "Copying Tutorial";
		
	}

}