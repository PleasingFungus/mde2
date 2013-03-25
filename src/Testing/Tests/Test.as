package Testing.Tests {
	import flash.utils.Dictionary;
	import Modules.Module;
	import org.flixel.FlxG;
	import Testing.Abstractions.InstructionAbstraction;
	import Testing.Abstractions.SaveAbstraction;
	import Testing.Abstractions.SetAbstraction;
	import Testing.Instructions.Instruction;
	import Testing.Instructions.JumpInstruction;
	import Testing.Instructions.SetInstruction;
	import Testing.Types.InstructionType;
	import Values.*;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Test {
		
		public var seed:Number;
		public var expectedInstructions:int;
		
		public var initialMemory:Vector.<Value>;
		public var expectedMemory:Vector.<Value>;
		
		protected var memAddressToSet:int;
		protected var memValueToSet:int
		protected var instructions:Vector.<Instruction>;
		protected var expectedOps:Vector.<OpcodeValue>;
		
		public function Test(ExpectedOps:Vector.<OpcodeValue>, ExpectedInstructions:int = 12, seed:Number = NaN) {
			expectedOps = ExpectedOps;
			if (isNaN(seed))
				seed = FlxG.random();
			FlxG.globalSeed = this.seed = seed;
			expectedInstructions = ExpectedInstructions;
			
			generate();
			initialMemory = genInitialMemory();
			expectedMemory = genExpectedMemory();
		}
		
		protected function generate():void {
			var instructionTypes:Vector.<InstructionType> = getInstructionTypes();
			
			memAddressToSet = C.randomRange(U.MAX_INT, U.MAX_INT - U.MIN_INT);
			memValueToSet = C.randomRange(U.MIN_INT, U.MAX_INT+1);
			var values:Vector.<int> = new Vector.<int>;
			values.push(memAddressToSet, memValueToSet);
			var registers:Vector.<int> = new Vector.<int>;
			for (var register:int = 0; i < NUM_REGISTERS; i++)
				registers.push(C.INT_NULL);
			
			log("\n\nSEED: " + seed);
			log("PROGRAM START");
			
			instructions = new Vector.<Instruction>;
			instructions.push(makeInstruction(new SaveAbstraction(memValueToSet, memAddressToSet), registers));
			
			for (var abstractionsMade:int = 1; abstractionsMade + values.length < expectedInstructions; abstractionsMade++) {
				var value:int = values[0];
				values.splice(0, 1); //values.shift()?
				var abstraction:InstructionAbstraction = genAbstraction(value, values, instructionTypes);
				if (abstraction.value != value)
					throw new Error("!!!");
				
				for each (var arg:int in abstraction.args)
					if (values.indexOf(arg) == -1)
						values.push(arg);
				
				if (values.length > NUM_REGISTERS) {
					values.pop();
					values.pop(); //assuming max 2 args, error condition can only occur if both are added, not prev. present; so safe to pop
					values.push(value);
					log("Early termination due to register overflow");
					break;
				}
				
				instructions.push(makeInstruction(abstraction, registers));
			}
			
			for each (value in values)
				instructions.push(makeInstruction(new SetAbstraction(value), registers));
			
			log("PROGRAM END\n\n");
			
			var orderedInstructions:Vector.<Instruction> = new Vector.<Instruction>;
			while (instructions.length)
				orderedInstructions.push(instructions.pop());
			instructions = orderedInstructions;
			
			instructions = postProcess(instructions);
			
			//TODO: scramble registers
			
			log("\n\nSEED: " + seed);
			log("PROGRAM START");
			for (var i:int = 0; i < instructions.length; i++)
				log(i + ": " + instructions[i]);
			log("PROGRAM END\n\n");
			
			testRun();
		}
		
		protected function testRun():void {
			var memory:Dictionary = new Dictionary;
			var registers:Dictionary = new Dictionary;
			executeInEnvironment(memory, registers, instructions);
			
			var mem:String = "Memory: ";
			for (var memAddrStr:String in memory)
				mem += memAddrStr + ":" + memory[memAddrStr] + ", ";
			log(mem);
			if (memory[memAddressToSet+""] != memValueToSet)
				throw new Error("Memory at " + memAddressToSet + " is " + memory[memAddressToSet+""] + " at end of run, not " + memValueToSet + " as expected!");
			else
				log("Mem test success");
		}
		
		protected function makeInstruction(abstraction:InstructionAbstraction, registers:Vector.<int>):Instruction {
			log(instructions.length + ": " + abstraction);
			
			var argRegisters:Vector.<int> = new Vector.<int>;
			var noop:Boolean = false;
			
			if (abstraction.value != C.INT_NULL) {
				var destination:int = registers.indexOf(abstraction.value);
				if (destination == -1)
					throw new Error("!!!");
				
				argRegisters.push(destination);
				if (abstraction.args.indexOf(abstraction.value) == -1) //not a noop
					registers[destination] = C.INT_NULL;
				else
					noop = true;
			}
			
			for each (var arg:int in abstraction.args) {
				var register:int = registers.indexOf(arg);
				if (register != -1) {
					argRegisters.push(register);
					continue;
				}
				
				register = registers.indexOf(C.INT_NULL)
				if (register == -1)
					throw new Error("!!!");
				registers[register] = arg;
				argRegisters.push(register);
			}
			
			var instructionClass:Class = Instruction.mapByType(abstraction.type);
			return new instructionClass(argRegisters, abstraction, noop);
		}
		
		
		
		protected function getInstructionTypes():Vector.<InstructionType> {
			var instructionTypes:Vector.<InstructionType> = new Vector.<InstructionType>;
			for each (var instructionType:InstructionType in [InstructionType.ADD, InstructionType.SUB, InstructionType.MUL, InstructionType.DIV])
				if (expectedOps.indexOf(instructionType.mapToOp()) != -1)
					instructionTypes.push(instructionType);
			return instructionTypes;
		}
		
		
		
		protected function genAbstraction(value:int, values:Vector.<int>, instructionTypes:Vector.<InstructionType>):InstructionAbstraction {
			var type:InstructionType;
			var abstraction:InstructionAbstraction;
			var arg:int;
			
			log("Attempting to produce " +value);
			var fullReuseInstrs:Vector.<InstructionType> = new Vector.<InstructionType>;
			for each (type in instructionTypes)
				if (type.can_produce_with(value, values))
					fullReuseInstrs.push(type);
			if (fullReuseInstrs.length) {
				log("Full re-use instrs: " + fullReuseInstrs);
				abstraction = randomTypeChoice(fullReuseInstrs).produce_with(value, values);
				log("Added " + abstraction + " with full re-use");
				return abstraction;
			}
			log("No full re-use instrs")
			
			var partialReuseInstrs:Vector.<InstructionType> = new Vector.<InstructionType>;
			for each (type in instructionTypes)
				if (type.can_produce_with_one_of(value, values))
					partialReuseInstrs.push(type);
			if (partialReuseInstrs.length) {
				log("Partial re-use instrs: " + partialReuseInstrs);
				
				type = randomTypeChoice(partialReuseInstrs);
				var validArgs:Vector.<int> = new Vector.<int>;
				for each (arg in values)
					if (type.can_produce_with_one(value, arg))
						validArgs.push(arg);
				log("Valid args for " + type.name + ": " + validArgs);
				
				arg = C.randomIntChoice(validArgs);
				abstraction = type.produce_with_one(value, arg);
				log("Added " + abstraction + ", re-using " + arg);
				return abstraction;
			}
			log("No partial re-use instrs")
			
			type = instructionTypes[C.randomRange(0, instructionTypes.length)];
			abstraction = type.produce_unrestrained(value);
			log("Added " + abstraction);
			return abstraction;
		}
		
		protected function randomTypeChoice(options:Vector.<InstructionType>):InstructionType {
			return options[int(FlxG.random() * options.length)];
		}
		
		protected function postProcess(instructions:Vector.<Instruction>):Vector.<Instruction> {
			if (expectedOps.indexOf(OpcodeValue.OP_JMP) == -1)
				return instructions;
			return addJumpLoop(instructions);
		}
		
		protected function addJumpLoop(instructions:Vector.<Instruction>):Vector.<Instruction> {
			var nums:Array = [];
			for (var i:int = 0; i <= 2; i++)
				nums.push(int(FlxG.random() * instructions.length));
			while (nums[0] == nums[1] && nums[1] == nums[2] && instructions.length)
				nums[0] = int(FlxG.random() * instructions.length);
			
			
			var blockStart:int = Math.min(nums[0], nums[1], nums[2]);
			nums.splice(nums.indexOf(blockStart), 1);
			var blockEnd:int = Math.max(nums[0], nums[1]);
			nums.splice(nums.indexOf(blockEnd), 1);
			var midBlock:int = nums[0];
			
			var preBlock:Vector.<Instruction> = instructions.slice(0, blockStart);
			var blockA:Vector.<Instruction> = instructions.slice(blockStart, midBlock);
			var blockB:Vector.<Instruction> = instructions.slice(midBlock, blockEnd);
			var postBlock:Vector.<Instruction> = instructions.slice(blockEnd);
			
			var instruction:Instruction;
			instructions = new Vector.<Instruction>;
			for each (instruction in preBlock)
				instructions.push(instruction);
			instructions.push(new JumpInstruction(instructions.length + blockB.length + 1)); //jump over block B
			for each (instruction in blockB)
				instructions.push(instruction);
			instructions.push(new JumpInstruction(instructions.length + blockA.length + 1)); //jump over block A
			for each (instruction in blockA)
				instructions.push(instruction);
			instructions.push(new JumpInstruction(preBlock.length)); //jump to start of block B
			for each (instruction in postBlock)
				instructions.push(instruction);
			
			return instructions;
		}
		
		protected function executeInEnvironment(memory:Dictionary, registers:Dictionary, instructions:Vector.<Instruction>):void {
			for (var line:int = 0; line < instructions.length; line ++) {
				var instruction:Instruction = instructions[line];
				var jump:int = instruction.execute(memory, registers);
				if (jump != C.INT_NULL)
					line = jump;
			}
		}
		
		
		
		protected function log(...args):void {
			if (U.DEBUG && U.DEBUG_PRINT_TESTS)
				C.log(args);
		}
		
		
		
		
		protected function genInitialMemory():Vector.<Value> {
			var memory:Vector.<Value> = generateBlankMemory();
			for (var i:int = 0; i < instructions.length; i++)
				memory[i] = instructions[i].toMemValue();
			return memory;
		}
		
		protected function genExpectedMemory():Vector.<Value> {
			var memory:Vector.<Value> = initialMemory.slice();
			memory[memAddressToSet] = new NumericValue(memValueToSet);
			return memory;
		}
		
		protected function generateBlankMemory():Vector.<Value> {
			var memory:Vector.<Value> = new Vector.<Value>;
			for (var i:int = memory.length; i < U.MAX_INT - U.MIN_INT; i++)
				memory.push(FixedValue.NULL);
			return memory;
		}
		
		protected const NUM_REGISTERS:int = 8;
	}

}