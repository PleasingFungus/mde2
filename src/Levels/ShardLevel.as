package Levels {
	import Testing.Goals.ShardGoal;
	import Testing.Tests.Test;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ShardLevel extends Level {
		
		public function ShardLevel(Name:String, Shard:LevelShard, Modules:Array = null) {
			super(Name, new ShardGoal(Shard), Shard.delay, [], [], Modules);
			expectedOps = Shard.expectedOps;
			allowedModules = Shard.allowedModules;
			writerLimit = 0;
			commentsEnabled = true;
			info = null;
		}
		
	}

}