package Testing.Tests {
	import flash.utils.Dictionary;
	import Modules.Module;
	import org.flixel.FlxG;
	import Testing.Abstractions.*;
	import Testing.Instructions.*;
	import Testing.Types.InstructionType;
	import Testing.Types.AbstractArg;
	import Testing.Types.OrderableInstructionType;
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
		protected var memValueToSet:int;
		
		protected var instructions:Vector.<Instruction>;
		protected var dataMemory:Vector.<AbstractArg>;
		protected var saveTargets:Vector.<AbstractArg>
		protected var expectedOps:Vector.<OpcodeValue>;
		
		public function Test(ExpectedOps:Vector.<OpcodeValue>, ExpectedInstructions:int = 12, seed:Number = NaN) {
			expectedOps = ExpectedOps;
			if (!isNaN(seed))
				FlxG.globalSeed = seed;
			this.seed = FlxG.globalSeed;
			expectedInstructions = ExpectedInstructions;
			
			generate();
			initialMemory = genInitialMemory();
			expectedMemory = genExpectedMemory();
		}
		
		protected function generate():void {
			var instructionTypes:Vector.<OrderableInstructionType> = getInstructionTypes();
			
			memValueToSet = C.randomRange(U.MIN_INT, U.MAX_INT);
			memAddressToSet = C.randomRange(U.MIN_MEM, U.MAX_MEM);
			
			var values:Vector.<AbstractArg> = new Vector.<AbstractArg>;
			values.push(new AbstractArg(memValueToSet, memAddressToSet));
			
			var registers:Vector.<int> = new Vector.<int>;
			for (var register:int = 0; i < NUM_REGISTERS; i++)
				registers.push(C.INT_NULL);
			
			log("\n\nSEED: " + seed);
			log("PROGRAM START");
			
			instructions = new Vector.<Instruction>;
			saveTargets = new Vector.<AbstractArg>;
			
			for (var abstractionsMade:int = 0; abstractionsMade + AbstractArg.instructionsToSet(values) < expectedInstructions; abstractionsMade++) {
				var value:AbstractArg = values[0];
				values.splice(0, 1); //values.shift()?
				var abstraction:InstructionAbstraction = genAbstraction(value, values, instructionTypes);
				
				if (abstraction is SaveAbstraction) {
					if (!value.inMemory || value.value != abstraction.args[0] || value.address != abstraction.args[1])
						throw new Error("!!");
				} else if (abstraction.value != value.value)
					throw new Error("!!!");
				
				for each (var arg:AbstractArg in abstraction.getAbstractArgs())
					if (!AbstractArg.argInVec(arg, values))
						values.push(arg);
				
				if (AbstractArg.instructionsToSet(values) > NUM_REGISTERS) {
					values.pop();
					values.pop(); //assuming max 2 args, error condition can only occur if both are added, not prev. present; so safe to pop
					values.push(value);
					log("Early termination due to register overflow");
					break;
				}
				
				if (abstraction is SaveAbstraction)
					saveTargets.push(new AbstractArg(abstraction.args[0], abstraction.args[1]));
				
				instructions.push(makeInstruction(abstraction, registers));
			}
			
			dataMemory = new Vector.<AbstractArg>;
			for each (value in values) {
				if (value.inMemory)
					dataMemory.push(value);
				else
					instructions.push(makeInstruction(new SetAbstraction(value.value), registers));
			}
			
			log("PROGRAM END\n\n");
			
			var orderedInstructions:Vector.<Instruction> = new Vector.<Instruction>;
			while (instructions.length)
				orderedInstructions.push(instructions.pop());
			instructions = orderedInstructions;
			
			instructions = postProcess(instructions);
			
			log("\n\nSEED: " + seed);
			log("PROGRAM START");
			for (var i:int = 0; i < instructions.length; i++)
				log(i + ": " + instructions[i]);
			log("PROGRAM END\n\n");
			
			testRun();
		}
		
		protected function testRun():void {
			var memory:Dictionary = new Dictionary;
			for each (var memorandum:AbstractArg in dataMemory)
				memory[memorandum.address] = memorandum.value;
			
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
				
				var potentialRegisters:Vector.<int> = new Vector.<int>;
				for (register = 0; register < registers.length; register++)
					if (registers[register] === C.INT_NULL)
						potentialRegisters.push(register);
				if (potentialRegisters.length == 0)
					throw new Error("!!!");
				register = C.randomIntChoice(potentialRegisters);
				registers[register] = arg;
				argRegisters.push(register);
			}
			
			var instructionClass:Class = Instruction.mapByType(abstraction.type);
			return new instructionClass(argRegisters, abstraction, noop);
		}
		
		
		
		protected function getInstructionTypes():Vector.<OrderableInstructionType> {
			var instructionTypes:Vector.<OrderableInstructionType> = new Vector.<OrderableInstructionType>;
			for each (var instructionType:InstructionType in [InstructionType.SAVE, InstructionType.ADD, InstructionType.SUB, 
															  InstructionType.MUL, InstructionType.DIV, InstructionType.LOAD])
				if (expectedOps.indexOf(instructionType.mapToOp()) != -1)
					instructionTypes.push(new OrderableInstructionType(instructionType, C.INT_NULL, 0));
			return instructionTypes;
		}
		
		
		
		protected function genAbstraction(value:AbstractArg, values:Vector.<AbstractArg>, instructionTypes:Vector.<OrderableInstructionType>):InstructionAbstraction {
			var optimalInstructionTypes:Vector.<OrderableInstructionType> = new Vector.<OrderableInstructionType>;
			for each (var orderableInstructionType:OrderableInstructionType in instructionTypes) {
				if (!orderableInstructionType.type.can_produce(value))
					continue;
				
				var produced:int = orderableInstructionType.numAlreadyProduced;
				var toProduce:int = orderableInstructionType.type.requiredArgsToProduce(value, values);
				var weightedValue:int = toProduce * 2 + produced;
				
				if (optimalInstructionTypes.length == 0) {
					optimalInstructionTypes.push(new OrderableInstructionType(orderableInstructionType.type, toProduce, produced));
					continue;
				}
				
				var currentValue:int = optimalInstructionTypes[0].argsNeeded * 2 + optimalInstructionTypes[0].numAlreadyProduced;
				if (weightedValue > currentValue)
					continue;
				
				if (weightedValue < currentValue)
					optimalInstructionTypes = new Vector.<OrderableInstructionType>;
				optimalInstructionTypes.push(new OrderableInstructionType(orderableInstructionType.type, toProduce, produced));
			}
			
			var typeIndex:int = FlxG.random() * optimalInstructionTypes.length;
			var type:InstructionType = optimalInstructionTypes[typeIndex].type;
			for each (orderableInstructionType in instructionTypes)
				if (orderableInstructionType.type == type) {
					orderableInstructionType.numAlreadyProduced += 1;
					break;
				}
			return type.produceMinimally(value, values);
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
			
			for each (var memorandum:AbstractArg in dataMemory)
				memory[memorandum.address] = new NumericValue(memorandum.value);
			
			return memory;
		}
		
		protected function genExpectedMemory():Vector.<Value> {
			var memory:Vector.<Value> = initialMemory.slice();
			for each (var saveTarget:AbstractArg in saveTargets)
				memory[saveTarget.address] = new NumericValue(saveTarget.value);
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