package Levels {
	import Modules.*;
	import Testing.*;
	import Values.OpcodeValue;
	import Testing.Goals.*;
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
		public var writerLimit:int = 1;
		
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
					if (Module.ALL_MODULES.indexOf(allowedModule) != -1)
						allowedModules.push(allowedModule);
					else if (U.DEBUG)
						throw new Error("Level " + name + " has unlisted module "+allowedModule+" in allowed list!");
			else
				allowedModules = Module.ALL_MODULES;
			
			this.delay = delay;
			
			predecessors = new Vector.<Level>;
		}
		
		public function setLast():void {
			last = this;
			U.save.data['lastLevel'] = name;
		}
		
		public function get successSave():String {
			return U.save.data[name + SUCCESS_SUFFIX];
		}
		
		public function set successSave(save:String):void {
			U.save.data[name + SUCCESS_SUFFIX] = save;
		}
		
		public function unlocked():Boolean {
			for each (var predecessor:Level in predecessors)
				if (!predecessor.successSave)
					return false;
			return true;
		}
		
		private const SUCCESS_SUFFIX:String = '-succ';
		
		public static function list():Vector.<Level> {
			var levels:Vector.<Level> = new Vector.<Level>;
			
			columns = new Vector.<Vector.<Level>>;
			
			var WIRE_TUT:Level = new Level("Wire Tutorial", new WireTutorialGoal, false,
										   [], [], [new ConstIn(12, 12, 1), new ConstIn(12, 20, 2), new DataWriter(22, 16)]);
			var MOD_TUT:Level = new Level("Module Tutorial", new WireTutorialGoal, false,
										  [Adder, DataWriter], [], [new ConstIn(12, 16, 1)]);
			MOD_TUT.predecessors.push(WIRE_TUT);
			var ACC_TUT:Level = new Level("Accumulation", new AccumulatorTutorialGoal, false,
										  [ConstIn, Adder, BabyLatch, DataWriter]);
			ACC_TUT.predecessors.push(MOD_TUT);
			var INSTR_TUT:Level = new Level("Instructions", new InstructionTutorialGoal, false,
											[ConstIn, Adder, BabyLatch, DataWriter, DataReader, InstructionDecoder]);
			INSTR_TUT.predecessors.push(ACC_TUT);
			INSTR_TUT.writerLimit = 4;
			var OP_TUT:Level = new Level("Opcodes", new OpcodeTutorialGoal, false,
										 [ConstIn, Adder, BabyLatch, DataWriter, DataReader, InstructionDecoder], [OpcodeValue.OP_SAVI]);
			OP_TUT.predecessors.push(ACC_TUT);
			
			levels.push(WIRE_TUT, MOD_TUT, ACC_TUT, INSTR_TUT);
			
			var D0_TUT:Level = new Level("Delay Tutorial", new WireTutorialGoal(15), true,
										 [Adder, DataWriter], [], [new ConstIn(12, 16, 1)]);
			D0_TUT.predecessors.push(ACC_TUT);
			var D1_TUT:Level = new Level("Delay Accum. 1", new MagicAccumDelayTutGoal, true,
										 [ConstIn, Adder, Latch, MagicWriter, SysDelayClock]);
			D1_TUT.predecessors.push(D0_TUT);
			var D2_TUT:Level = new Level("Delay Accum. 2", new AccumDelayTutGoal, true,
										 [ConstIn, Adder, Latch, DataMemory, SysDelayClock]);
			D2_TUT.predecessors.push(D1_TUT);
			
			levels.push(D0_TUT, D1_TUT, D2_TUT);
			
			var addCPU:Level = new ShardLevel("Add-CPU", "Make a basic CPU!", LevelShard.CORE);
			addCPU.predecessors.push(ACC_TUT);
			var cpuJMP:Level = new ShardLevel("Jump! Jump!", "Make a CPU that can jump!", LevelShard.CORE.compositWith(LevelShard.JUMP));
			cpuJMP.predecessors.push(addCPU);
			var cpuADV:Level = new ShardLevel("Advanced Ops", "Make a CPU that does arithmetic!", LevelShard.CORE.compositWith(LevelShard.ADV));
			cpuADV.predecessors.push(addCPU);
			var cpuLD:Level = new ShardLevel("Load", "Make a CPU that can load from memory!", LevelShard.CORE.compositWith(LevelShard.LOAD));
			cpuLD.predecessors.push(addCPU);
			
			levels.push(addCPU, cpuJMP, cpuADV, cpuLD);
			
			var delayShard:LevelShard = LevelShard.CORE.compositWith(LevelShard.DELAY);
			var addCPU_D:Level = new ShardLevel("Add-CPU Delay", "Make a basic CPU... with propagation delay!", delayShard);
			addCPU_D.predecessors.push(addCPU, D2_TUT);
			var cpuADVLDD:Level = new ShardLevel("Adv/Load Delay", " ", delayShard.compositWith(LevelShard.ADV, LevelShard.LOAD));
			cpuADVLDD.predecessors.push(addCPU_D, cpuADV, cpuLD);
			
			levels.push(addCPU_D, cpuADVLDD);
			
			var pipeShard:LevelShard = delayShard.compositWith(LevelShard.SPD);
			var pipe:Level = new ShardLevel("Efficiency!", "Make a CPU that runs fast!", pipeShard);
			pipe.predecessors.push(addCPU_D); //dubious
			var pipeJMP:Level = new ShardLevel("Efficient Jump", " ", pipeShard.compositWith( LevelShard.JUMP));
			pipeJMP.predecessors.push(pipe, cpuJMP);
			var pipeADV:Level = new ShardLevel("Efficient Adv Op", " ", pipeShard.compositWith(LevelShard.ADV));
			pipeADV.predecessors.push(pipe, cpuADVLDD);
			var pipeLD:Level = new ShardLevel("Efficient Load", " ", pipeShard.compositWith(LevelShard.LOAD));
			pipeLD.predecessors.push(pipe, cpuADVLDD);
			var pipeADVLDD:Level = new ShardLevel("Eff. Adv/Load", " ", pipeShard.compositWith(LevelShard.ADV, LevelShard.LOAD));
			pipeADVLDD.predecessors.push(pipeLD, pipeADV);
			
			levels.push(pipe, pipeJMP, pipeADV, pipeLD, pipeADVLDD);
			
			columns.push(makeVec([WIRE_TUT]));
			columns.push(makeVec([MOD_TUT]));
			columns.push(makeVec([ACC_TUT]));
			columns.push(makeVec([INSTR_TUT, OP_TUT]));
			columns.push(makeVec([addCPU, cpuJMP, cpuADV, cpuLD]));
			columns.push(makeVec([D0_TUT]));
			columns.push(makeVec([D1_TUT]));
			columns.push(makeVec([D2_TUT]));
			columns.push(makeVec([addCPU_D, cpuADVLDD]));
			columns.push(makeVec([pipe, pipeJMP, pipeADV, pipeLD, pipeADVLDD]));
			
			return levels;
		}
		
		private static function makeVec(levels:Array):Vector.<Level> {
			var vec:Vector.<Level> = new Vector.<Level>;
			for each (var level:Level in levels)
				vec.push(level);
			return vec;
		}
		
		public static function load():void {
			var lastLevelName:String = U.save.data['lastLevel'];
			C.log("Loading last level " + lastLevelName);
			for each (var level:Level in U.levels)
				if (level.name == lastLevelName) {
					last = level;
					C.log("Last level: " + level);
					break;
				}
		}
		
		public static var columns:Vector.<Vector.<Level>>;
		public static var last:Level;
	}

}