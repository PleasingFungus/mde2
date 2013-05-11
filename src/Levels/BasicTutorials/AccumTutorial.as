package Levels.BasicTutorials {
	import Levels.Level;
	import Modules.*;
	import Testing.Goals.AccumulatorTutorialGoal;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class AccumTutorial extends Level {
		
		public function AccumTutorial() {
			super("Accumulation", new AccumulatorTutorialGoal, false, [ConstIn, Adder, BabyLatch, DataWriter]);
			writerLimit = 1;
		}
		
	}

}