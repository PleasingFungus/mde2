package Testing.Goals {
	import Levels.LevelShard;
	import Testing.Tests.Test;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ShardGoal extends GeneratedGoal {
		
		public function ShardGoal(Description:String, Shard:LevelShard) {
			super(Description, Test, Shard.expectedOps, 12, int(100 * Shard.timeFactor));
		}
		
		
		
	}

}