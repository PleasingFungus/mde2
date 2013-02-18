package  {
	import Modules.*;
	import Testing.*;
	import Values.OpcodeValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Level {
		
		public var name:String;
		public var goal:LevelGoal;
		public var modules:Vector.<Module>;
		public var expectedOps:Vector.<OpcodeValue>
		public var allowedModules:Vector.<Class>
		public var delay:Boolean;
		
		public function Level(Name:String, Goal:LevelGoal, delay:Boolean = false, AllowedModules:Array = null, ExpectedOps:Array = null, Modules:Array = null) {
			name = Name;
			this.goal = Goal;
			
			modules = new Vector.<Module>;
			if (Modules)
				for each (var module:Module in Modules)
					modules.push(module);
			
			expectedOps = new Vector.<OpcodeValue>;
			if (ExpectedOps)
				for each (var op:OpcodeValue in ExpectedOps)
					expectedOps.push(op);
			
			allowedModules = new Vector.<Class>;
			if (AllowedModules)
				for each (var allowedModule:Class in AllowedModules)
					allowedModules.push(allowedModule);
			else
				allowedModules = Module.ALL_MODULES;
			
			this.delay = delay;
		}
		
		public static function list():Vector.<Level> {
			var levels:Vector.<Level> = new Vector.<Level>;
			levels.push(new Level("Sandbox",
								  new LevelGoal("Have fun!", false),
								  false,
								  [ConstIn, Adder, Clock, ASU, Latch, Mux, Demux], [],
								  [new ConstIn(8, 48, 1), new Regfile(40, 16), new Adder(24, 40)]),
						new Level("Add-CPU",
								  new GeneratedGoal("Set-Add-Save!", Test),
								  false,
								  [ConstIn, And, Adder, Clock, Latch, InstructionMemory, DataMemory, Regfile, InstructionMux, InstructionDemux],
								  [OpcodeValue.OP_SET, OpcodeValue.OP_ADD, OpcodeValue.OP_SAV]),
						new Level("Add-CPU Delay",
								  new GeneratedGoal("Set-Add-Save!", Test, 12, 10000),
								  true,
								  null,
								  [OpcodeValue.OP_SET, OpcodeValue.OP_ADD, OpcodeValue.OP_SAV]));
			return levels;
		}
	}

}