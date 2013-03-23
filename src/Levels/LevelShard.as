package Levels {
	import Values.OpcodeValue;
	import Modules.*;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class LevelShard {
		
		public var name:String;
		public var expectedOps:Vector.<OpcodeValue>;
		public var allowedModules:Vector.<Class>;
		public var timeFactor:Number;
		public var delay:Boolean;
		//public var prereqs:Vector.<LevelShard> //?
		public function LevelShard(Name:String, Ops:Array = null, Modules:Array = null, TimeFactor:Number = 1, delay:Boolean = false) {
			var ExpectedOps:Vector.<OpcodeValue> = new Vector.<OpcodeValue>;
			for each (var op:OpcodeValue in Ops ? Ops : [])
				ExpectedOps.push(op);
			
			var AllowedModules:Vector.<Class> = new Vector.<Class>;
			for each (var moduleType:Class in Modules ? Modules : [])
				AllowedModules.push(moduleType);
				
			init(Name, ExpectedOps, AllowedModules, TimeFactor, delay);
		}
		
		public function init(Name:String, ExpectedOps:Vector.<OpcodeValue>, AllowedModules:Vector.<Class>, TimeFactor:Number, delay:Boolean):LevelShard {
			name = Name;
			expectedOps = ExpectedOps;
			allowedModules = AllowedModules;
			timeFactor = TimeFactor;
			this.delay = delay;
			return this;
		}
		
		public function compositWith(...others):LevelShard {
			var newShard:LevelShard = new LevelShard(name).init(name, expectedOps.slice(), allowedModules.slice(), timeFactor, delay);
			
			for each (var other:LevelShard in others) {
				newShard.name += "+" + other.name;
				for each (var op:OpcodeValue in other.expectedOps)
					newShard.expectedOps.push(op);
				for each (var moduleType:Class in other.allowedModules)
					newShard.allowedModules.push(moduleType);
				newShard.timeFactor *= other.timeFactor;
				newShard.delay = newShard.delay || other.delay;
			}
			
			return newShard;
		}
		
		public static function init():void {
			ALL.push(CORE, JUMP, DELAY, ADV, SPD);
		}
		
		public static const CORE:LevelShard = new LevelShard("Core", [OpcodeValue.OP_SET, OpcodeValue.OP_ADD, OpcodeValue.OP_SAV],
															 [ConstIn, And, Adder, Latch, InstructionMemory, DataMemory, Regfile, InstructionDemux, InstructionComparator, Not]);
		public static const DELAY:LevelShard = new LevelShard("Delay", [], [SysDelayClock, Delay], 50, true);
		public static const JUMP:LevelShard = new LevelShard("Jump", [OpcodeValue.OP_JMP], [], 1.5);
		public static const ADV:LevelShard = new LevelShard("Adv.", [OpcodeValue.OP_SUB, OpcodeValue.OP_MUL, OpcodeValue.OP_DIV], [ASU, MDU], 1.1);
		public static const SPD:LevelShard = new LevelShard("Speed", [], [], 0.2);
		public static const ALL:Vector.<LevelShard> = new Vector.<LevelShard>;
		
	}

}