package Levels.ControlTutorials {
	import Levels.Level;
	import LevelStates.LevelLoader;
	import Testing.Goals.FibonacciGoal;
	import Levels.LevelHint;
	import org.flixel.FlxG;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class FibonacciTutorial extends Level {
		
		public function FibonacciTutorial() {
			super("Fibonacci", new FibonacciGoal);
			useModuleRecord = false;
			var loader:LevelLoader = LevelLoader.loadSimple("TZBJC8IwFIRf2op1i1vRFAL+/6u/xZuIl4J4EI8eROpMmEAOk8z3tixm1pjZGVr1WFrIEyBbQ4cyEwlcHBRKmLOvHsfxB9O7khZVmgd6wWxz6gmzY8o3oIHG5cK7Dk+FV5hNSu11nw66MIrsQxfmKyL4hn3Jy+t0+gl7wG/2SIwFxD5ik2/FNTTT3MxHcdDcqL6vPqFT3IvLM6ZF7Um1fEulWn548wc=");
			loader.loadIntoLevel(this);
			info = "This level is already set up for you. All you have to do is press the test button at the top, and watch!";
			
		}
		
		override public function makeHint():LevelHint {
			if (hintDone || !U.state.editEnabled)
				return null;
			return new LevelHint(FlxG.width / 2 - 12, 65, arrow_up);
		}
		
		[Embed(source = "../../../lib/art/help/uppointarrow.png")] private const arrow_up:Class;
		
	}

}