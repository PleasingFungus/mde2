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
			var loader:LevelLoader = LevelLoader.loadSimple("TU8xDsIwELtLAmnTUgQVAxIDGxsP5hl8jYEFKdjJpUolW3Z88aUishORN3C4gu5ApAHkARz75EJzA/Hg1BsPLN5Gztq74FofN6UWcWZitISc8497tQzCfSGGMgjzgRhLtIKeVhaAl3WKZ7ynCmpXa1vigpF2IiWezVTKIDorqv1xU0laOmv7g/qpQVxRJM/UbTd8ecYf");
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