package Testing.Goals {
	import Levels.LevelShard;
	import Testing.Tests.Test;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ShardGoal extends GeneratedGoal {
		
		public function ShardGoal(Description:String, Shard:LevelShard) {
			super(Description, Test, Shard.expectedOps, 50 / Shard.instructionFactor, int(100 * Shard.timeFactor), 10 * Shard.instructionFactor);
		}
		
		
		
	}

}