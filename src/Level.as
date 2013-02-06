package  {
	import Modules.*;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Level {
		
		public var name:String;
		public var goal:LevelGoal;
		public var modules:Vector.<Module>;
		public var delayEnabled:Boolean;
		
		public function Level(Name:String, Goal:LevelGoal, Modules:Array = null) {
			name = Name;
			this.goal = Goal;
			
			modules = new Vector.<Module>;
			if (Modules)
				for each (var module:Module in Modules)
					modules.push(module);
		}
		
		public static function list():Vector.<Level> {
			var levels:Vector.<Level> = new Vector.<Level>;
			levels.push(new Level("Sandbox",
								  new LevelGoal("Have fun!", function _(state:LevelState):Boolean { return false; } ),
								  [new ConstIn(8, 48, 1), new Regfile(40, 16), new Adder(24, 40), new Outport(40, 40)]));
			return levels;
		}
	}

}