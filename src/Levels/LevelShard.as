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
		public var instructionFactor:Number;
		public var delay:Boolean;
		public function LevelShard(Name:String, Ops:Array = null, Modules:Array = null, TimeFactor:Number = 1, InstructionFactor:Number = 1,
								   delay:Boolean = false) {
			var ExpectedOps:Vector.<OpcodeValue> = new Vector.<OpcodeValue>;
			for each (var op:OpcodeValue in Ops ? Ops : [])
				ExpectedOps.push(op);
			
			var AllowedModules:Vector.<Class> = new Vector.<Class>;
			for each (var moduleType:Class in Modules ? Modules : [])
				AllowedModules.push(moduleType);
			
			init(Name, ExpectedOps, AllowedModules, TimeFactor, InstructionFactor, delay);
		}
		
		public function init(Name:String, ExpectedOps:Vector.<OpcodeValue>, AllowedModules:Vector.<Class>,
							 TimeFactor:Number, InstructionFactor:Number, delay:Boolean):LevelShard {
			name = Name;
			expectedOps = ExpectedOps;
			allowedModules = AllowedModules;
			timeFactor = TimeFactor;
			instructionFactor = InstructionFactor;
			this.delay = delay;
			return this;
		}
		
		public function compositWith(...others):LevelShard {
			var newShard:LevelShard = new LevelShard(name).init(name, expectedOps.slice(), allowedModules.slice(), timeFactor, instructionFactor, delay);
			
			for each (var other:LevelShard in others) {
				newShard.name += "+" + other.name;
				for each (var op:OpcodeValue in other.expectedOps)
					if (newShard.expectedOps.indexOf(op) == -1)
						newShard.expectedOps.push(op);
				for each (var moduleType:Class in other.allowedModules)
					if (newShard.allowedModules.indexOf(moduleType) == -1)
						newShard.allowedModules.push(moduleType);
				newShard.timeFactor *= other.timeFactor;
				newShard.instructionFactor *= other.instructionFactor;
				newShard.delay = newShard.delay || other.delay;
			}
			
			return newShard;
		}
		
		public static function init():void {
			
		}
		
		public static const CORE:LevelShard = new LevelShard("Core", [OpcodeValue.OP_SET, OpcodeValue.OP_ADD, OpcodeValue.OP_SAV],
															 [ConstIn, And, Adder, InstructionDecoder, BabyLatch, DataWriterT, Mux, Demux,
															 InstructionDemux, InstructionComparator, Not, DataReader, Output], 3);
		public static const DELAY:LevelShard = new LevelShard("Delay", [], [SysDelayClock, Latch], 12, 1, true); //12*3 = 36 t/i
		public static const SPD:LevelShard = new LevelShard("Speed", [], [Demux, Equals], 1/2, 2); //12*3/2 = 18 t/i
		public static const JUMP:LevelShard = new LevelShard("Jump", [OpcodeValue.OP_JMP]);
		public static const BRANCH:LevelShard = new LevelShard("Branch", [OpcodeValue.OP_BEQ], [Equals], 1, 1.25);
		public static const ADV:LevelShard = new LevelShard("Adv.", [OpcodeValue.OP_SUB, OpcodeValue.OP_MUL, OpcodeValue.OP_DIV], [Subtractor, Multiplier, Divider]);
		public static const LOAD:LevelShard = new LevelShard("Load", [OpcodeValue.OP_LD]);
		
	}

}