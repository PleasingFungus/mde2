package Levels {
	import Modules.*;
	import Testing.Goals.MagicAccumDelayTutGoal;
	import Levels.LevelHint;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DelayAccumTutorial extends Level {
		
		public function DelayAccumTutorial() {
			super("Delay Accum. 1", new MagicAccumDelayTutGoal, true,
				  [ConstIn, Adder, Latch, MagicWriter, SysDelayClock]);
			useModuleRecord = false;
		}
		
		override public function makeHint():LevelHint {
			if (hintDone || !U.state.editEnabled)
				return null;
			return new LevelHint(212, 65, arrow_up, function done():Boolean { return U.state.time.clockPeriod > 2; } );
		}
		
		[Embed(source = "../../lib/art/help/uppointarrow.png")] private const arrow_up:Class;
	}

}