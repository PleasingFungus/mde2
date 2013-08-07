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
			super(NAME, new AccumulatorTutorialGoal, false, [ConstIn, Adder, Latch, DataWriter]);
			info = "Time in MDE2 is broken up into 'ticks'. During testing, time progresses 1 tick at a time until memory reaches the specified state, or until the time limit is reached.";
			info += "\n\nSome modules have effects that occur at the end of each tick. Data Writers write to memory; Storage (a new module in this level) changes its value to its input.";
			info += "\n\nAll end-of-turn effects occur simultaneously; they are only based on state from the beginning of the tick.";
			writerLimit = 1;
			useModuleRecord = false;
		}
		
		public static const NAME:String = "Accumulation";
	}

}