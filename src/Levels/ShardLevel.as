package Levels {
	import Testing.Goals.ShardGoal;
	import Testing.Tests.Test;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ShardLevel extends Level {
		
		public function ShardLevel(Name:String, Description:String, Shard:LevelShard, Modules:Array = null) {
			super(Name, new ShardGoal(Description, Shard), Shard.delay, [], [], Modules);
			expectedOps = Shard.expectedOps;
			allowedModules = Shard.allowedModules;
			writerLimit = 0;
		}
		
	}

}