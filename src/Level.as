package  {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Level {
		
		public var name:String;
		public var goal:LevelGoal;
		
		public function Level(Name:String, Goal:LevelGoal) {
			name = Name;
			this.goal = Goal;
		}
		
		public static function list():Vector.<Level> {
			var levels:Vector.<Level> = new Vector.<Level>;
			levels.push(new Level("Sandbox", new LevelGoal("Have fun!", function _(state:LevelState):Boolean { return false; })));
			return levels;
		}
	}

}