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
		public var hintDone:Boolean; //not related to 'hints' per se
		
		public var goal:LevelGoal;
		public var fewestModules:int;
		public var fewestTicks:int;
		public var modules:Vector.<Module>;
		
		public var canDrawWires:Boolean = true;
		public var canPlaceModules:Boolean = true;
		public var canPickupModules:Boolean = true;
		public var canEditModules:Boolean = true;
		
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
				if (level && level.predecessors.indexOf(this) != -1)
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
			if (DEBUG.UNLOCK_ALL)
				return true;
			if (U.DEMO && U.DEMO_PERMITTED.indexOf(this) == -1)
				return false;
			for each (var predecessor:Level in predecessors)
				if (!predecessor.beaten)
					return false;
			return true;
		}
		
		public function specialInfo():Vector.<FlxSprite> { return null;	}
		
		public function makeHint():LevelHint { return null }
		
		private const SUCCESS_SUFFIX:String = '-succ';
		private const MODULE_SUFFIX:String = "-modules";
		private const TICK_SUFFIX:String = "-ticks";
		
		
		public static var L_TutorialWire:Level;
		public static var L_TutorialModule:Level;
		public static var L_TutorialSelection:Level;
		public static var L_TutorialCopying:Level;
		
		public static var L_Accumulation:Level;
		public static var L_Double:Level;
		public static var L_SingleOp:Level;
		public static var L_DoubleOp:Level;
		
		public static var L_Square:Level;
		
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
		
		public static var L_PTutorial:Level;
		
		public static var L_PCPU_Basic:Level;
		public static var L_PCPU_Advanced:Level;
		public static var L_PCPU_Load:Level;
		public static var L_PCPU_LoadAdvanced:Level;
		public static var L_PCPU_Jump:Level;
		public static var L_PCPU_Branch:Level;
		public static var L_PCPU_Full:Level;
		
		public static function list():Vector.<Level> {
			var levels:Vector.<Level> = new Vector.<Level>;
			
			L_TutorialWire = new WireTutorial;
			(L_TutorialModule = new ModuleTutorial).predecessors.push(L_TutorialWire);
			(L_TutorialSelection = new DragSelectTutorial).predecessors.push(L_TutorialModule);
			(L_TutorialCopying = new CopyingTutorial).predecessors.push(L_TutorialSelection);
			
			(L_Accumulation = new AccumTutorial).predecessors.push(L_TutorialModule);
			(L_Double = new DoubleTutorial).predecessors.push(L_Accumulation);
			(L_SingleOp = new OpTutorial).predecessors.push(L_Accumulation);
			(L_DoubleOp = new Op2Tutorial).predecessors.push(L_SingleOp, L_Double);
			
			L_Square = new Level("Square", new SquareGoal, false, [ConstIn, Adder, Subtractor, Latch, DataReader, DataWriter, Equals, And, Or, Not, Demux]);
			L_Square.predecessors.push(L_Double);
			
			
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
			L_DTutorial_1 = new DelayAccumTutorial();
			L_DTutorial_1.predecessors.push(L_DTutorial_0);
			L_DTutorial_2 = new Level("Delay Accum. 2", new AccumDelayTutGoal, true,
										 [ConstIn, Adder, Latch, DataWriter]);
			L_DTutorial_2.predecessors.push(L_DTutorial_1);
			L_DTutorial_2.useModuleRecord = false;
			
			var delayShard:LevelShard = LevelShard.CORE.compositWith(LevelShard.DELAY);
			L_DCPU_Basic = new ShardLevel("Add-CPU Delay", delayShard);
			L_DCPU_Basic.predecessors.push(L_DTutorial_2);
			
			L_PTutorial = new Level("Pipeline Tutorial", new PipelineTutorialGoal, true,
											   [ConstIn, Adder, Latch, DataWriter, DataReader, InstructionDecoder, And], [OpcodeValue.OP_SAVI]);
			L_PTutorial.predecessors.push(L_DCPU_Basic);
			
			var pipeShard:LevelShard = delayShard.compositWith(LevelShard.SPD);
			L_PCPU_Basic = new ShardLevel("Efficiency!", pipeShard);
			L_PCPU_Basic.predecessors.push(L_PTutorial);
			L_PCPU_Jump = new ShardLevel("Efficient Jump", pipeShard.compositWith( LevelShard.JUMP));
			L_PCPU_Jump.predecessors.push(L_PCPU_Basic, L_CPU_Branch);
			L_PCPU_Branch = new ShardLevel("Efficient Branch", pipeShard.compositWith( LevelShard.JUMP, LevelShard.BRANCH));
			L_PCPU_Branch.predecessors.push(L_PCPU_Jump);
			L_PCPU_Advanced = new ShardLevel("Efficient Adv Op", pipeShard.compositWith(LevelShard.ADV));
			L_PCPU_Advanced.predecessors.push(L_PCPU_Basic, L_CPU_Advanced);
			L_PCPU_Load = new ShardLevel("Efficient Load", pipeShard.compositWith(LevelShard.LOAD));
			L_PCPU_Load.predecessors.push(L_PCPU_Basic, L_CPU_Load);
			L_PCPU_LoadAdvanced = new ShardLevel("Eff. Adv/Load", pipeShard.compositWith(LevelShard.ADV, LevelShard.LOAD));
			L_PCPU_LoadAdvanced.predecessors.push(L_PCPU_Load, L_PCPU_Advanced);
			L_PCPU_Full = new ShardLevel("Full Efficient", pipeShard.compositWith(LevelShard.ADV, LevelShard.LOAD, LevelShard.JUMP, LevelShard.BRANCH));
			L_PCPU_Full.predecessors.push(L_CPU_Full, L_PCPU_Branch, L_PCPU_LoadAdvanced);
			
			L_PTutorial.useTickRecord = L_PCPU_Basic.useTickRecord = L_PCPU_Jump.useTickRecord = L_PCPU_Branch.useTickRecord = true;
			L_PCPU_Advanced.useTickRecord = L_PCPU_Load.useTickRecord = L_PCPU_LoadAdvanced.useTickRecord = L_PCPU_Full.useTickRecord = true;
			
			levels.push(L_TutorialWire, L_TutorialModule, L_TutorialSelection, L_TutorialCopying,
					    L_Accumulation, L_SingleOp, L_DoubleOp,
						L_CPU_Basic, L_CPU_Jump, L_CPU_Branch, L_CPU_Advanced, L_CPU_Load, L_CPU_Full,
						L_DTutorial_0, L_DTutorial_1, L_DTutorial_2,
						L_DCPU_Basic, null, null, null,
						L_PTutorial,
						L_PCPU_Basic, L_PCPU_Jump, L_PCPU_Advanced, L_PCPU_Load, L_PCPU_LoadAdvanced, L_PCPU_Branch, L_PCPU_Full,
						L_Double, L_Square);
			
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
			for each (var level:Level in levels) 
				if (level) {
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
				if (level && level.name == lastLevelName) {
					last = level;
					C.log("Last level: " + level);
					break;
				}
		}
		
		public static var last:Level;
	}

}