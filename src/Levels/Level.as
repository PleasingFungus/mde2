package Levels {
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
		public var predecessors:Vector.<Level>;
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
			
			predecessors = new Vector.<Level>;
		}
		
		public static function tutorials():Vector.<Level> {
			var levels:Vector.<Level> = new Vector.<Level>;
			
			levels.push(new Level("Tutorial 1A: Wires",
								  new WireTutorialGoal,
								  false,
								  [], [],
								  [new ConstIn(12, 12, 1), new ConstIn(12, 20, 2), new DataWriter(22, 16)]),
						new Level("Tutorial 1B: Modules",
								  new WireTutorialGoal,
								  false,
								  [Adder, DataWriter], [],
								  [new ConstIn(12, 16, 1)]),
						new Level("Tutorial 2: Acc.",
								  new AccumulatorTutorialGoal,
								  false,
								  [ConstIn, Adder, Latch, DataWriter], []));
			
			return levels;
		}
		
		public static function list():Vector.<Level> {
			var levels:Vector.<Level> = new Vector.<Level>;
			
			var addCPU:Level = new ShardLevel("Add-CPU", "Make a basic CPU!", LevelShard.CORE);
			var addCPU_D:Level = new ShardLevel("Add-CPU Delay", "Make a basic CPU... with propagation delay!", LevelShard.CORE.compositWith(LevelShard.DELAY));
			var cpuJMP:Level = new ShardLevel("Jump! Jump!", "Make a CPU that can jump!", LevelShard.CORE.compositWith(LevelShard.JUMP));
			var cpuADV:Level = new ShardLevel("Advanced Ops", "Make a CPU that do arithmetic!", LevelShard.CORE.compositWith(LevelShard.ADV));
			
			addCPU_D.predecessors.push(addCPU);
			cpuJMP.predecessors.push(addCPU);
			cpuADV.predecessors.push(addCPU);
			
			levels.push(addCPU, addCPU_D, cpuJMP, cpuADV);
			
			return levels;
		}
	}

}