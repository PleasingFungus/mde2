package Levels {
	import Levels.ControlTutorials.*;
	import Levels.BasicTutorials.*;
	import org.flixel.FlxSprite;
	
	import Testing.*;
	import Testing.Goals.*;
	import Modules.*;
	import Values.OpcodeValue;
	
	import org.flixel.FlxG;
	import Components.Wire;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Level {
		
		public var name:String;
		public var displayName:String;
		public var info:String;
		public var hints:Vector.<String>;
		
		public var goal:LevelGoal;
		public var modules:Vector.<Module>;
		public var wires:Vector.<Wire>;
		public var preplacesFixed:Boolean = true;
		public var canDrawWires:Boolean = true;
		public var canPlaceModules:Boolean = true;
		public var commentsEnabled:Boolean;
		public var expectedOps:Vector.<OpcodeValue>;
		public var allowedModules:Vector.<Class>
		public var predecessors:Vector.<Level>;
		public var delay:Boolean;
		public var writerLimit:int = 0;
		
		public function Level(Name:String, Goal:LevelGoal, delay:Boolean = false, AllowedModules:Array = null, ExpectedOps:Array = null, Modules:Array = null) {
			name = displayName = Name;
			info = "TODO";
			hints = new Vector.<String>;
			this.goal = Goal;
			
			modules = new Vector.<Module>;
			if (Modules)
				for each (var module:Module in Modules)
					modules.push(module);
			wires = new Vector.<Wire>;
			
			expectedOps = new Vector.<OpcodeValue>;
			if (ExpectedOps)
				for each (var op:OpcodeValue in ExpectedOps)
					expectedOps.push(op);
			
			allowedModules = new Vector.<Class>;
			if (AllowedModules)
				for each (var allowedModule:Class in AllowedModules)
					if (Module.ALL_MODULES.indexOf(allowedModule) != -1)
						allowedModules.push(allowedModule);
					else if (DEBUG.ON)
						throw new Error("Level " + name + " has unlisted module "+allowedModule+" in allowed list!");
			else
				allowedModules = Module.ALL_MODULES;
			
			this.delay = delay;
			
			predecessors = new Vector.<Level>;
		}
		
		public function setWires(Wires:Array):Level {
			wires = new Vector.<Wire>;
			for each (var wire:Wire in Wires)
				wires.push(wire);
			return this;
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
		
		public function specialInfo():Vector.<FlxSprite> {
			return null;
		}
		
		private const SUCCESS_SUFFIX:String = '-succ';
		
		
		
		
		public static function list():Vector.<Level> {
			var levels:Vector.<Level> = new Vector.<Level>;
			
			columns = new Vector.<Vector.<Level>>;
			
			var WIRE_TUT:Level = new WireTutorial;
			var MOD_TUT:Level = new ModuleTutorial;
			var SEL_TUT:Level = new DragSelectTutorial;
			var COPY_TUT:Level = new CopyingTutorial;
			
			MOD_TUT.predecessors.push(WIRE_TUT);
			SEL_TUT.predecessors.push(MOD_TUT);
			COPY_TUT.predecessors.push(SEL_TUT);
			levels.push(WIRE_TUT, MOD_TUT, SEL_TUT, COPY_TUT);
			
			
			var ACC_TUT:Level = new AccumTutorial;
			var INSTR_TUT:Level = new InstructionTutorial;
			var OP_TUT:Level = new OpTutorial;
			var ISEL_TUT:Level = new Op2Tutorial;
			
			ACC_TUT.predecessors.push(MOD_TUT);
			INSTR_TUT.predecessors.push(ACC_TUT);
			OP_TUT.predecessors.push(ACC_TUT);
			ISEL_TUT.predecessors.push(OP_TUT);
			levels.push(ACC_TUT, INSTR_TUT, OP_TUT, ISEL_TUT);
			
			var addCPU:Level = new ShardLevel("Add-CPU", LevelShard.CORE);
			addCPU.info = "CPU instructions reference 'registers'. These are a set of 8 values, numbered 0-7, stored however you like.";
			addCPU.info += " The only requirement is that you are able to store values to, and on later ticks retrieve values from, locations numbered 0 - 7.";
			addCPU.info += "\n\nExample: a hypothetical MOVE instruction, which tells you to 'Set the DESTINATION register to the SOURCE register.";
			addCPU.info += "\n\nThis means you must set the register at the number indicated by the DESTINATION of the instruction to the value of the register at the number indicated by the SOURCE of the instruction.";
			addCPU.info += "\n\nE.g., MOV R7 = R4: set the value held in register 7 to the value held in register 4."
			addCPU.info += "\n\nHave fun!";
			addCPU.predecessors.push(ACC_TUT);
			var cpuADV:Level = new ShardLevel("Advanced Ops", LevelShard.CORE.compositWith(LevelShard.ADV));
			cpuADV.predecessors.push(addCPU);
			var cpuLD:Level = new ShardLevel("Load", LevelShard.CORE.compositWith(LevelShard.LOAD));
			cpuLD.predecessors.push(addCPU);
			var cpuJMP:Level = new ShardLevel("Jump! Jump!", LevelShard.CORE.compositWith(LevelShard.JUMP));
			cpuJMP.predecessors.push(addCPU);
			var cpuBRANCH:Level = new ShardLevel("Branch!", LevelShard.CORE.compositWith(LevelShard.JUMP, LevelShard.BRANCH));
			cpuBRANCH.predecessors.push(cpuJMP);
			var cpuFULL:Level = new ShardLevel("Full!", LevelShard.CORE.compositWith(LevelShard.ADV, LevelShard.LOAD, LevelShard.JUMP, LevelShard.BRANCH));
			cpuFULL.predecessors.push(cpuADV, cpuLD, cpuBRANCH);
			
			levels.push(addCPU, cpuJMP, cpuBRANCH, cpuADV, cpuLD, cpuFULL);
			
			var D0_TUT:Level = new Level("Delay Tutorial", new WireTutorialGoal(15), true,
										 [Adder, DataWriter], [], [new ConstIn(12, 16, 1)]);
			D0_TUT.predecessors.push(ACC_TUT);
			var D1_TUT:Level = new Level("Delay Accum. 1", new MagicAccumDelayTutGoal, true,
										 [ConstIn, Adder, Latch, MagicWriter, SysDelayClock]);
			D1_TUT.predecessors.push(D0_TUT);
			var D2_TUT:Level = new Level("Delay Accum. 2", new AccumDelayTutGoal, true,
										 [ConstIn, Adder, Latch, DataWriter, SysDelayClock]);
			D2_TUT.predecessors.push(D1_TUT);
			
			levels.push(D0_TUT, D1_TUT, D2_TUT);
			
			var delayShard:LevelShard = LevelShard.CORE.compositWith(LevelShard.DELAY);
			var addCPU_D:Level = new ShardLevel("Add-CPU Delay", delayShard);
			addCPU_D.predecessors.push(addCPU, D2_TUT);
			var cpuADVLDD:Level = new ShardLevel("Adv/Load Delay", delayShard.compositWith(LevelShard.ADV, LevelShard.LOAD));
			cpuADVLDD.predecessors.push(addCPU_D, cpuADV, cpuLD);
			var cpuD_BRANCH:Level = new ShardLevel("Branch Delay", delayShard.compositWith(LevelShard.JUMP, LevelShard.BRANCH));
			cpuD_BRANCH.predecessors.push(addCPU_D, cpuBRANCH);
			var cpuD_FULL:Level = new ShardLevel("Full Delay", delayShard.compositWith(LevelShard.ADV, LevelShard.LOAD, LevelShard.JUMP, LevelShard.BRANCH));
			cpuD_FULL.predecessors.push(cpuADVLDD, cpuBRANCH);
			
			levels.push(addCPU_D, cpuADVLDD, cpuD_BRANCH, cpuD_FULL);
			
			var pipeTutorial:Level = new Level("Pipeline Tutorial", new PipelineTutorialGoal, true,
											   [ConstIn, Adder, Latch, DataWriterT, DataReader, InstructionDecoder, SysDelayClock, And], [OpcodeValue.OP_SAVI]);
			pipeTutorial.predecessors.push(OP_TUT, D2_TUT);
			
			levels.push(pipeTutorial);
			
			var pipeShard:LevelShard = delayShard.compositWith(LevelShard.SPD);
			var pipe:Level = new ShardLevel("Efficiency!", pipeShard);
			pipe.predecessors.push(addCPU_D); //dubious
			var pipeJMP:Level = new ShardLevel("Efficient Jump", pipeShard.compositWith( LevelShard.JUMP));
			pipeJMP.predecessors.push(pipe, cpuJMP);
			var pipeBranch:Level = new ShardLevel("Efficient Branch", pipeShard.compositWith( LevelShard.JUMP, LevelShard.BRANCH));
			pipeBranch.predecessors.push(pipeJMP);
			var pipeADV:Level = new ShardLevel("Efficient Adv Op", pipeShard.compositWith(LevelShard.ADV));
			pipeADV.predecessors.push(pipe, cpuADVLDD);
			var pipeLD:Level = new ShardLevel("Efficient Load", pipeShard.compositWith(LevelShard.LOAD));
			pipeLD.predecessors.push(pipe, cpuADVLDD);
			var pipeADVLDD:Level = new ShardLevel("Eff. Adv/Load", pipeShard.compositWith(LevelShard.ADV, LevelShard.LOAD));
			pipeADVLDD.predecessors.push(pipeLD, pipeADV);
			var pipeFull:Level = new ShardLevel("Full Efficient", pipeShard.compositWith(LevelShard.ADV, LevelShard.LOAD, LevelShard.JUMP, LevelShard.BRANCH));
			pipeFull.predecessors.push(pipeBranch, pipeADVLDD);
			
			levels.push(pipe, pipeJMP, pipeADV, pipeLD, pipeADVLDD, pipeBranch, pipeFull);
			
			columns.push(makeVec([WIRE_TUT, MOD_TUT, SEL_TUT, COPY_TUT]));
			columns.push(makeVec([ACC_TUT, INSTR_TUT, OP_TUT, ISEL_TUT]));
			columns.push(makeVec([addCPU, cpuJMP, cpuBRANCH, cpuADV, cpuLD, cpuFULL]));
			columns.push(makeVec([D0_TUT, D1_TUT, D2_TUT]));
			columns.push(makeVec([addCPU_D, cpuADVLDD, cpuD_BRANCH, cpuD_FULL]));
			columns.push(makeVec([pipeTutorial]));
			columns.push(makeVec([pipe, pipeJMP, pipeBranch, pipeADV, pipeLD, pipeADVLDD, pipeFull]));
			
			return levels;
		}
		
		public static function validate(levels:Vector.<Level>):void {
			for each (var level:Level in levels) {
				FlxG.globalSeed = 0.5;
				level.goal.genMem();
			}
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