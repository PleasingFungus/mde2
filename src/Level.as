package  {
	import Modules.*;
	import Testing.*;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Level {
		
		public var name:String;
		public var goal:LevelGoal;
		public var modules:Vector.<Module>;
		public var allowedModules:Vector.<Class>
		public var delayEnabled:Boolean;
		
		public function Level(Name:String, Goal:LevelGoal, AllowedModules:Array = null, Modules:Array = null) {
			name = Name;
			this.goal = Goal;
			
			modules = new Vector.<Module>;
			if (Modules)
				for each (var module:Module in Modules)
					modules.push(module);
			
			allowedModules = new Vector.<Class>;
			if (AllowedModules)
				for each (var allowedModule:Class in AllowedModules)
					allowedModules.push(allowedModule);
		}
		
		public static function list():Vector.<Level> {
			var levels:Vector.<Level> = new Vector.<Level>;
			levels.push(new Level("Sandbox",
								  new LevelGoal("Have fun!", function _(state:LevelState):Boolean { return false; } ),
								  [ConstIn, Adder, Clock, ASU, Latch, Mux, Demux],
								  [new ConstIn(8, 48, 1), new Regfile(40, 16), new Adder(24, 40), new Outport(40, 40)]),
						new Level("Add-CPU",
								  new GeneratedGoal("Set-Add-Save!", Test),
								  [ConstIn, Adder, Clock, Latch, InstructionMemory, DataMemory, Regfile, Mux, Demux]));
			return levels;
		}
	}

}