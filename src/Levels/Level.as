package Levels {
	import Levels.ControlTutorials.*;
	import Levels.BasicTutorials.*;
	import LevelStates.LevelState;
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
		public var fewestModules:int;
		public var fewestTicks:int;
		public var modules:Vector.<Module>;
		public var canDrawWires:Boolean = true;
		public var canPlaceModules:Boolean = true;
		public var useModuleRecord:Boolean = true;
		public var useTickRecord:Boolean = false;
		public var configurableLatchesEnabled:Boolean = false;
		public var commentsEnabled:Boolean;
		public var expectedOps:Vector.<OpcodeValue>;
		public var allowedModules:Vector.<Class>
		public var predecessors:Vector.<Level>;
		public var delay:Boolean;
		public var writerLimit:int = 0;
		
		public function Level(Name:String, Goal:LevelGoal, delay:Boolean = false, AllowedModules:Array = null, ExpectedOps:Array = null, Modules:Array = null) {
			name = displayName = Name;
			info = DEBUG.ON ? "TODO" : "";
			hints = new Vector.<String>;
			this.goal = Goal;
			
			fewestModules = U.save.data[name + MODULE_SUFFIX];
			fewestTicks = U.save.data[name + TICK_SUFFIX];
			
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
					else if (DEBUG.ON)
						throw new Error("Level " + name + " has unlisted module "+allowedModule+" in allowed list!");
			else
				allowedModules = Module.ALL_MODULES;
			
			this.delay = delay;
			
			predecessors = new Vector.<Level>;
		}
		
		public function get index():int {
			return Level.ALL.indexOf(this);
		}
		
		public function get successors():Vector.<Level> {
			var successors:Vector.<Level> = new Vector.<Level>;
			for each (var level:Level in Level.ALL)
				if (level.predecessors.indexOf(this) != -1)
					successors.push(level);
			return successors;
		}
		
		public function setHighScore(modules:int):void {
			if (modules < fewestModules || !fewestModules) {
				fewestModules = modules;
				U.save.data[name + MODULE_SUFFIX] = fewestModules;
			}
			if (goal.totalTicks < fewestTicks || !fewestTicks) {
				fewestTicks = goal.totalTicks;
				U.save.data[name + TICK_SUFFIX] = fewestTicks;
			}
		}
		
		public function setLast():void {
			last = this;
			U.save.data['lastLevel'] = name;
		}
		
		public function get successSave():String {
			return U.save.data[name + SUCCESS_SUFFIX];
		}
		
		public function get beaten():Boolean {
			return successSave != null;
		}
		
		public function set successSave(save:String):void {
			U.save.data[name + SUCCESS_SUFFIX] = save;
		}
		
		public function unlocked():Boolean {
			for each (var predecessor:Level in predecessors)
				if (!predecessor.beaten)
					return false;
			return true;
		}
		
		public function specialInfo():Vector.<FlxSprite> {
			return null;
		}
		
		private const SUCCESS_SUFFIX:String = '-succ';
		private const MODULE_SUFFIX:String = "-modules";
		private const TICK_SUFFIX:String = "-ticks";
		
		
		public static var L_TutorialWire:Level;
		public static var L_TutorialModule:Level;
		public static var L_TutorialSelection:Level;
		public static var L_TutorialCopying:Level;
		
		public static var L_Accumulation:Level;
		public static var L_SingleOp:Level;
		public static var L_DoubleOp:Level;
		
		public static var L_CPU_Basic:Level;
		public static var L_CPU_Advanced:Level;
		public static var L_CPU_Load:Level;
		public static var L_CPU_Jump:Level;
		public static var L_CPU_Branch:Level;
		public static var L_CPU_Full:Level;
		
		public static var L_DTutorial_0:Level;
		public static var L_DTutorial_1:Level;
		public static var L_DTutorial_2:Level;
		
		public static var L_DCPU_Basic:Level;
		public static var L_DCPU_LoadAdvanced:Level;
		public static var L_DCPU_Branch:Level;
		public static var L_DCPU_Full:Level;
		
		public static function list():Vector.<Level> {
			var levels:Vector.<Level> = new Vector.<Level>;
			
			L_TutorialWire = new WireTutorial;
			(L_TutorialModule = new ModuleTutorial).predecessors.push(L_TutorialWire);
			(L_TutorialSelection = new DragSelectTutorial).predecessors.push(L_TutorialModule);
			(L_TutorialCopying = new CopyingTutorial).predecessors.push(L_TutorialSelection);
			
			(L_Accumulation = new AccumTutorial).predecessors.push(L_TutorialModule);
			(L_SingleOp = new OpTutorial).predecessors.push(L_Accumulation);
			(L_DoubleOp = new Op2Tutorial).predecessors.push(L_SingleOp);
			
			
			L_CPU_Basic = new ShardLevel("Add-CPU", LevelShard.CORE);
			L_CPU_Basic.info = "CPU instructions reference 'registers'. These are a set of 8 values, numbered 0-7, stored however you like.";
			L_CPU_Basic.info += " The only requirement is that you are able to store values to, and on later ticks retrieve values from, locations numbered 0 - 7.";
			L_CPU_Basic.info += "\n\nExample: a hypothetical MOVE instruction, which tells you to 'Set the DESTINATION register to the SOURCE register.";
			L_CPU_Basic.info += "\n\nThis means you must set the register at the number indicated by the DESTINATION of the instruction to the value of the register at the number indicated by the SOURCE of the instruction.";
			L_CPU_Basic.info += "\n\nE.g., MOV R7 = R4: set the value held in register 7 to the value held in register 4."
			L_CPU_Basic.info += "\n\nHave fun!";
			L_CPU_Basic.predecessors.push(L_DoubleOp);
			L_CPU_Advanced = new ShardLevel("Advanced Ops", LevelShard.CORE.compositWith(LevelShard.ADV));
			L_CPU_Advanced.predecessors.push(L_CPU_Basic);
			L_CPU_Load = new ShardLevel("Load", LevelShard.CORE.compositWith(LevelShard.LOAD));
			L_CPU_Load.predecessors.push(L_CPU_Basic);
			L_CPU_Jump = new ShardLevel("Jump! Jump!", LevelShard.CORE.compositWith(LevelShard.JUMP));
			L_CPU_Jump.predecessors.push(L_CPU_Basic);
			L_CPU_Branch = new ShardLevel("Branch!", LevelShard.CORE.compositWith(LevelShard.JUMP, LevelShard.BRANCH));
			L_CPU_Branch.predecessors.push(L_CPU_Jump);
			L_CPU_Full = new ShardLevel("Full!", LevelShard.CORE.compositWith(LevelShard.ADV, LevelShard.LOAD, LevelShard.JUMP, LevelShard.BRANCH));
			L_CPU_Full.predecessors.push(L_CPU_Advanced, L_CPU_Load, L_CPU_Branch);
			
			
			
			L_DTutorial_0 = new Level("Delay Tutorial", new WireTutorialGoal(15), true,
										 [Adder, DataWriter], [], [new ConstIn(12, 16, 1)]);
			L_DTutorial_0.useModuleRecord = false;
			L_DTutorial_0.predecessors.push(L_CPU_Basic);
			L_DTutorial_1 = new Level("Delay Accum. 1", new MagicAccumDelayTutGoal, true,
										 [ConstIn, Adder, Latch, MagicWriter, SysDelayClock]);
			L_DTutorial_1.predecessors.push(L_DTutorial_0);
			L_DTutorial_2 = new Level("Delay Accum. 2", new AccumDelayTutGoal, true,
										 [ConstIn, Adder, Latch, DataWriter, SysDelayClock]);
			L_DTutorial_2.predecessors.push(L_DTutorial_1);
			
			var delayShard:LevelShard = LevelShard.CORE.compositWith(LevelShard.DELAY);
			L_DCPU_Basic = new ShardLevel("Add-CPU Delay", delayShard);
			L_DCPU_Basic.predecessors.push(L_DTutorial_2);
			L_DCPU_LoadAdvanced = new ShardLevel("Adv/Load Delay", delayShard.compositWith(LevelShard.ADV, LevelShard.LOAD));
			L_DCPU_LoadAdvanced.predecessors.push(L_DCPU_Basic, L_CPU_Advanced, L_CPU_Load);
			L_DCPU_Branch = new ShardLevel("Branch Delay", delayShard.compositWith(LevelShard.JUMP, LevelShard.BRANCH));
			L_DCPU_Branch.predecessors.push(L_DCPU_Basic, L_CPU_Branch);
			L_DCPU_Full = new ShardLevel("Full Delay", delayShard.compositWith(LevelShard.ADV, LevelShard.LOAD, LevelShard.JUMP, LevelShard.BRANCH));
			L_DCPU_Full.predecessors.push(L_CPU_Full, L_DCPU_LoadAdvanced, L_DCPU_Branch);
			
			var pipeTutorial:Level = new Level("Pipeline Tutorial", new PipelineTutorialGoal, true,
											   [ConstIn, Adder, Latch, DataWriterT, DataReader, InstructionDecoder, SysDelayClock, And], [OpcodeValue.OP_SAVI]);
			pipeTutorial.predecessors.push(L_DCPU_Basic);
			
			var pipeShard:LevelShard = delayShard.compositWith(LevelShard.SPD);
			var pipe:Level = new ShardLevel("Efficiency!", pipeShard);
			pipe.predecessors.push(pipeTutorial, L_DCPU_Basic);
			var pipeJMP:Level = new ShardLevel("Efficient Jump", pipeShard.compositWith( LevelShard.JUMP));
			pipeJMP.predecessors.push(pipe, L_DCPU_Branch);
			var pipeBranch:Level = new ShardLevel("Efficient Branch", pipeShard.compositWith( LevelShard.JUMP, LevelShard.BRANCH));
			pipeBranch.predecessors.push(pipeJMP);
			var pipeADV:Level = new ShardLevel("Efficient Adv Op", pipeShard.compositWith(LevelShard.ADV));
			pipeADV.predecessors.push(pipe, L_DCPU_LoadAdvanced);
			var pipeLD:Level = new ShardLevel("Efficient Load", pipeShard.compositWith(LevelShard.LOAD));
			pipeLD.predecessors.push(pipe, L_DCPU_LoadAdvanced);
			var pipeADVLDD:Level = new ShardLevel("Eff. Adv/Load", pipeShard.compositWith(LevelShard.ADV, LevelShard.LOAD));
			pipeADVLDD.predecessors.push(pipeLD, pipeADV);
			var pipeFull:Level = new ShardLevel("Full Efficient", pipeShard.compositWith(LevelShard.ADV, LevelShard.LOAD, LevelShard.JUMP, LevelShard.BRANCH));
			pipeFull.predecessors.push(L_DCPU_Full, pipeBranch, pipeADVLDD);
			
			pipeTutorial.useTickRecord = pipe.useTickRecord = pipeJMP.useTickRecord = pipeBranch.useTickRecord = true;
			pipeLD.useTickRecord = pipeADVLDD.useTickRecord = pipeFull.useTickRecord = pipeADV.useTickRecord = true;
			
			levels.push(L_TutorialWire, L_TutorialModule, L_TutorialSelection, L_TutorialCopying,
					    L_Accumulation, L_SingleOp, L_DoubleOp,
						L_CPU_Basic, L_CPU_Jump, L_CPU_Branch, L_CPU_Advanced, L_CPU_Load, L_CPU_Full,
						L_DTutorial_0, L_DTutorial_1, L_DTutorial_2,
						L_DCPU_Basic, L_DCPU_LoadAdvanced, L_DCPU_Branch, L_DCPU_Full,
						pipeTutorial,
						pipe, pipeJMP, pipeADV, pipeLD, pipeADVLDD, pipeBranch, pipeFull);
			
			return levels;
		}
		
		public static var ALL:Vector.<Level>;
		
		public function loadIntoState(levelState:LevelState, loadFresh:Boolean = false):void {
			for each (var module:Module in modules) {
				module.cleanup();
				levelState.addModule(module);
			}
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
			for each (var level:Level in Level.ALL)
				if (level.name == lastLevelName) {
					last = level;
					C.log("Last level: " + level);
					break;
				}
		}
		
		public static var last:Level;
	}

}