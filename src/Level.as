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
		
		public static function list():Vector.<Level> {
			var levels:Vector.<Level> = new Vector.<Level>;
			
			levels.push(new Level("Tutorial 1: Wires",
								  new WireTutorialGoal,
								  false,
								  [], [],
								  [new ConstIn(12, 16, 1), new Adder(20, 16), new DataWriter(28, 16)]),
						new Level("Tutorial 2: Acc.",
								  new AccumulatorTutorialGoal,
								  false,
								  [ConstIn, Adder, Latch, DataWriter], []));
			
			var addCPU:Level = new Level("Add-CPU",
										 new GeneratedGoal("Set-Add-Save!", Test),
										 false,
										 [ConstIn, And, Adder, Clock, Latch, InstructionMemory, DataMemory, Regfile, InstructionMux, InstructionDemux],
										 [OpcodeValue.OP_SET, OpcodeValue.OP_ADD, OpcodeValue.OP_SAV]);
			
			var addCPU_D:Level = new Level("Add-CPU Delay",
										   new GeneratedGoal("Set-Add-Save!", Test, 12, 10000),
										   true,
										   null,
										   [OpcodeValue.OP_SET, OpcodeValue.OP_ADD, OpcodeValue.OP_SAV]);
			
			var cpuJMP:Level = new Level("Jump! Jump!",
										 new GeneratedGoal("Jump!", JumpTest),
										 false,
										 [ConstIn, And, Adder, Clock, Latch, InstructionMemory, DataMemory, Regfile, InstructionMux, InstructionDemux],
										 [OpcodeValue.OP_SET, OpcodeValue.OP_ADD, OpcodeValue.OP_SAV, OpcodeValue.OP_JMP]);
			
			addCPU_D.predecessors.push(addCPU);
			cpuJMP.predecessors.push(addCPU);
			
			levels.push(addCPU, addCPU_D, cpuJMP);
			
			return levels;
		}
	}

}