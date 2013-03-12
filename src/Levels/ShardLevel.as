package Levels {
	import Testing.Goals.GeneratedGoal;
	import Testing.Goals.ShardGoal;
	import Testing.Test;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ShardLevel extends Level {
		
		public function ShardLevel(Name:String, Description:String, Shard:LevelShard, Modules:Array = null) {
			super(Name, new ShardGoal(Description, Shard), Shard.delay, [], [], Modules);
			expectedOps = Shard.expectedOps;
			allowedModules = Shard.allowedModules;
		}
		
	}

}