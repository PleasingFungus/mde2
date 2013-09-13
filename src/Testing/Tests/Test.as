package Testing.Tests {
	import flash.utils.Dictionary;
	import Modules.Module;
	import org.flixel.FlxG;
	import Testing.Abstractions.*;
	import Testing.Instructions.*;
	import Testing.Types.InstructionType;
	import Testing.Types.AbstractArg;
	import Testing.Types.OrderableInstructionType;
	import UI.ColorText;
	import UI.HighlightFormat;
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
		public var expectedExecutions:int;
		
		protected var memAddressToSet:int;
		protected var memValueToSet:int;
		
		protected var instructions:Vector.<Instruction>;
		protected var dataMemory:Vector.<AbstractArg>;
		protected var saveTargets:Vector.<AbstractArg>
		protected var expectedOps:Vector.<OpcodeValue>;
		
		protected var loop:Vector.<Instruction>
		protected var loopExecutions:int;
		
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
			
			var values:Vector.<AbstractArg> = genFirstValues()
			var registers:Vector.<int> = initializeRegisters();
			var sidestack:Vector.<AbstractArg> = new Vector.<AbstractArg>;
			
			log("\n\nSEED: " + seed);
			log("PROGRAM START");
			
			instructions = new Vector.<Instruction>;
			saveTargets = new Vector.<AbstractArg>;
			
			for (var abstractionsMade:int = 0; remainingAbstractions(abstractionsMade, values) > 0; abstractionsMade++) {
				var value:AbstractArg = values[0];
				values.splice(0, 1); //values.shift()?
				
				if (value.inStack)
					value = sidestack.pop(); //LIFO, not FIFO
				
				if (!loop && canMakeLoop(value, values, instructionTypes, abstractionsMade) && FlxG.random() < 1 / 2) {
					loop = makeLoop(value, values, instructionTypes, registers, instructions);
					abstractionsMade += loop.length;
				} else {
					var abstraction:InstructionAbstraction = genAbstraction(value, values, sidestack, instructionTypes);
					
					if (AbstractArg.instructionsToSet(values) > NUM_REGISTERS) {
						values.pop();
						values.pop(); //assuming max 2 args, error condition can only occur if both are added, not prev. present; so safe to pop
						values.push(value);
						log("Early termination due to register overflow");
						break;
					}
					
					if (abstraction.writesToMemory)
						saveTargets.push(new AbstractArg(abstraction.memoryValue, abstraction.memoryAddress));
					
					instructions.push(makeInstruction(abstraction, registers));
				}
			}
			
			//cleanup sidestack
			while (sidestack.length) {
				value = sidestack.pop();
				instructions.push(makeInstruction(new PushAbstraction(value.value), registers));
				values.push(new AbstractArg(value.value));
			}
			
			//cleanup other values to be initialized
			dataMemory = new Vector.<AbstractArg>;
			provideInitialValues(values, instructions, registers);
			
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
			
			if (FlxG.debug)
				testRun();
		}
		
		protected function genFirstValues():Vector.<AbstractArg> {
			var values:Vector.<AbstractArg> = new Vector.<AbstractArg>;
			values.push(genFirstValue());
			return values;
		}
		
		protected function genFirstValue():AbstractArg {
			memValueToSet = C.randomRange(U.MIN_INT, U.MAX_INT);
			memAddressToSet = C.randomRange(U.MIN_MEM, U.MAX_MEM);
			return new AbstractArg(memValueToSet, memAddressToSet);
		}
		
		protected function initializeRegisters():Vector.<int> {
			var registers:Vector.<int> = new Vector.<int>;
			for (var register:int = 0; register < NUM_REGISTERS; register++)
				registers.push(C.INT_NULL);
			return registers;
		}
		
		protected function remainingAbstractions(abstractionsMade:int, values:Vector.<AbstractArg>):int {
			return expectedInstructions - (abstractionsMade + AbstractArg.instructionsToSet(values));
		}
		
		protected function testRun():void {
			var memory:Dictionary = new Dictionary;
			for each (var memorandum:AbstractArg in dataMemory)
				memory[memorandum.address] = memorandum.value;
			
			var registers:Dictionary = new Dictionary;
			for (var i:int = 0; i < NUM_REGISTERS; i++)
				registers[i] = NaN;
			var stack:Vector.<int> = new Vector.<int>;
			executeInEnvironment(memory, registers, stack, instructions);
			
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
			
			for each (var abstractArg:AbstractArg in abstraction.getAbstractArgs())
				if (!abstractArg.immediate && abstractArg.inRegisters)
					argRegisters.push(setRegisterFor(abstractArg.value, registers));
			
			var instructionClass:Class = Instruction.mapByType(abstraction.type);
			return new instructionClass(argRegisters, abstraction, noop);
		}
		
		protected function setRegisterFor(arg:int, registers:Vector.<int>):int {
			var register:int = registers.indexOf(arg);
			if (register != -1)
				return register;
			
			register = getFreeRegister(registers);
			if (register == -1)
				throw new Error("!!!");
			
			registers[register] = arg;
			return register;
		}
		
		protected function getFreeRegister(registers:Vector.<int>):int {
			var potentialRegisters:Vector.<int> = new Vector.<int>;
			for (var register:int = 0; register < registers.length; register++)
				if (registers[register] === C.INT_NULL)
					potentialRegisters.push(register);
			if (potentialRegisters.length == 0)
				return -1;
			
			return C.randomIntChoice(potentialRegisters);
		}
		
		
		
		protected function getInstructionTypes():Vector.<OrderableInstructionType> {
			var instructionTypes:Vector.<OrderableInstructionType> = new Vector.<OrderableInstructionType>;
			for each (var instructionType:InstructionType in [InstructionType.SAVE, InstructionType.ADD, InstructionType.SUB, 
															  InstructionType.MUL, InstructionType.DIV, InstructionType.LOAD,
															  InstructionType.SAVI, InstructionType.ADDM,
															  InstructionType.PUSH, InstructionType.POP])
				if (expectedOps.indexOf(instructionType.mapToOp()) != -1)
					instructionTypes.push(new OrderableInstructionType(instructionType, C.INT_NULL, 0));
			return instructionTypes;
		}
		
		
		
		protected function genAbstraction(value:AbstractArg, values:Vector.<AbstractArg>, sidestack:Vector.<AbstractArg>,
										  instructionTypes:Vector.<OrderableInstructionType>):InstructionAbstraction {
			var optimalInstructionTypes:Vector.<OrderableInstructionType> = new Vector.<OrderableInstructionType>;
			for each (var orderableInstructionType:OrderableInstructionType in instructionTypes) {
				if (!orderableInstructionType.type.can_produce_in_state(value, values))
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
			
			var abstraction:InstructionAbstraction = type.produceMinimally(value, values);
				
			if (abstraction.writesToMemory) {
				if (!value.inMemory || value.value != abstraction.memoryValue || value.address != abstraction.memoryAddress)
					throw new Error("!!");
			} else if (abstraction.writesToStack) {
				if (!value.inStack || value.value != abstraction.stackValue)
					throw new Error("!");
			} else if (abstraction.value != value.value)
				throw new Error("!!!");
			
			for each (var arg:AbstractArg in abstraction.getAbstractArgs())
				if (!arg.immediate && !AbstractArg.argInVec(arg, values)) {
					values.push(arg);
					if (arg.inStack)
						sidestack.push(arg);
				}
			
			return abstraction;
		}
		
		protected function randomTypeChoice(options:Vector.<InstructionType>):InstructionType {
			return options[int(FlxG.random() * options.length)];
		}
		
		
		protected function provideInitialValues(values:Vector.<AbstractArg>, instructions:Vector.<Instruction>, registers:Vector.<int>):void {
			for each (var value:AbstractArg in values) {
				if (value.inMemory)
					dataMemory.push(value);
				else if (value.inRegisters)
					instructions.push(makeInstruction(new SetAbstraction(value.value), registers));
			}
		}
		
		protected function canMakeLoop(value:AbstractArg, values:Vector.<AbstractArg>, instructionTypes:Vector.<OrderableInstructionType>, abstractionsMade:int):Boolean {
			return branchesEnabled && value.inRegisters && AbstractArg.instructionsToSet(values) + 4 <= NUM_REGISTERS && remainingAbstractions(abstractionsMade, values) >= 4;
		}
		
		protected function makeLoop(value:AbstractArg, values:Vector.<AbstractArg>,
									instructionTypes:Vector.<OrderableInstructionType>,
									registers:Vector.<int>, instructions:Vector.<Instruction>):Vector.<Instruction> {
			//choose
				//instruction type (add, sub, mul, div)
			var validInstructionTypes:Vector.<InstructionType> = new Vector.<InstructionType>;
			var allAcceptableTypes:Array = [InstructionType.ADD, InstructionType.SUB, InstructionType.DIV];
			for each (var orderableType:OrderableInstructionType in instructionTypes)
				if (allAcceptableTypes.indexOf(orderableType.type) != -1)
					validInstructionTypes.push(orderableType.type);
			var instructionType:InstructionType = validInstructionTypes[int(FlxG.random() * validInstructionTypes.length)];
				//# loops (2-4 mul-div, 3-6 add-sub)
				//applicand (can't be 0; must be between -256-255 for add-sub, -16-15 for mul-div)
			var loopCount:int, applicand:int;
			if (instructionType == InstructionType.ADD || instructionType == InstructionType.SUB) {
				loopCount = C.randomRange(3, 7);
				applicand = FlxG.random() < 0.5 ? C.randomRange( -256, 0) : C.randomRange(1, 256);
			} else {
				loopCount = C.randomRange(2, 5);
				if (instructionType == InstructionType.DIV)
					applicand = FlxG.random() < 0.5 ? C.randomRange( -16, -1) : C.randomRange(2, 16);
				else if (instructionType == InstructionType.MUL) {
					//applicand = C.randomIntChoice(C.factorsOf(value.value)); //TODO
					instructionType = InstructionType.ADD;
					loopCount = C.randomRange(3, 7);
					applicand = FlxG.random() < 0.5 ? C.randomRange( -256, -1) : C.randomRange(1, 256);
				} else
					throw new Error("Unexpected instruction type: " + instructionType);
			}
			loopExecutions = loopCount * 4 + 1;
			
				//incr loop (loopCount = 0; end if loopCount == loopLimit; loopCount++)
				//or decr loop (loopCount = loopLimit; end if loopCount == 0; loopCount--)
			var increment:int = C.randomRange(1, 4);
			var loopLimit:int = loopCount * increment;
			var loopBackwards:Boolean = expectedOps.indexOf(OpcodeValue.OP_SUB) != -1 && FlxG.random() < 0.5;
			
			//determine base value
			var base:int = value.value;
			for (var i:int = 0; i < loopCount; i++)
				switch (instructionType) {
					case InstructionType.ADD:
						base -= applicand; break;
					case InstructionType.SUB:
						base += applicand; break;
					case InstructionType.DIV:
						base *= applicand; break;
					default:
						throw new Error("Unexpected instruction type: " + instructionType);
				}
			//determine values to be set (loop #, applicand, base)
			var newValues:Vector.<int> = C.buildIntSet(loopLimit, applicand, base, increment, 0);
			for each (var newValue:int in newValues) {
				var v:AbstractArg = new AbstractArg(newValue);
				if (!AbstractArg.argInVec(v, values))
					values.push(v);
			}
			
			//find registers
			var destRegister:int = registers.indexOf(value.value);
			if (destRegister == -1)
				throw new Error("!!!");
			registers[destRegister] = C.INT_NULL + 1; //invalid value; won't be used to store other values below
			
			var applicandRegister:int = setRegisterFor(applicand, registers);
			var loopCountRegister:int = setRegisterFor(loopBackwards ? loopLimit : 0, registers);
			var loopLimitRegister:int = setRegisterFor(loopBackwards ? 0 : loopLimit, registers);
			var incrementRegister:int = setRegisterFor(increment, registers);
			
			//generate actual instructions
			//branch
			//operate
			//increment
			//jump
			//(but backwards)
			var loop:Vector.<Instruction> = new Vector.<Instruction>;
			var jumpback:Instruction = new JumpInstruction(C.INT_NULL);
			jumpback.abstract.comment = "Return to loop start";
			jumpback.abstract.commentFormat = new HighlightFormat("Return to {}", ColorText.singleVec(new ColorText(U.DESTINATION.color, "loop start")));
			loop.push(jumpback); //jump back to start
			
			//TODO: scramble source/target for increment?
			var incrementor:Instruction;
			if (loopBackwards)
				loop.push(incrementor = new SubInstruction(C.buildIntVector(loopCountRegister, loopCountRegister, incrementRegister),
														   new SubAbstraction(C.INT_NULL, C.INT_NULL), false)); //decrement
			else
				loop.push(incrementor = new AddInstruction(C.buildIntVector(loopCountRegister, loopCountRegister, incrementRegister),
														   new AddAbstraction(C.INT_NULL, C.INT_NULL), false)); //increment
			incrementor.abstract.comment = (loopBackwards ? "Decrement from " : "Increment to ") + loopLimit +" by " + increment;
			incrementor.abstract.commentFormat = new HighlightFormat((loopBackwards ? "Decrement from" : "Increment to") + " {} by {}",
																	 ColorText.vecFromArray([new ColorText(U.DESTINATION.color, loopLimit.toString()),
																							 new ColorText(U.TARGET.color, increment.toString())])); //double-check: might be source?
			
			var operator:Instruction = new (Instruction.mapByType(instructionType))(C.buildIntVector(destRegister, destRegister, applicandRegister), instructionType.produce(C.INT_NULL, C.INT_NULL), false);
			operator.abstract.comment = "(" + base + instructionType.symbol + applicand + ") x" + loopCount + " = " + value.value;
			operator.abstract.commentFormat = new HighlightFormat("({}"+instructionType.symbol+"{}) x"+loopCount+" = {}",
																  ColorText.vecFromArray([
																	new ColorText(U.SOURCE.color, base.toString()),
																	new ColorText(U.TARGET.color, applicand.toString()),
																	new ColorText(U.DESTINATION.color, value.value.toString())
																  ]));
			loop.push(operator); //operate
			
			var branchInstr:BranchInstruction = new BranchInstruction(C.buildIntVector(C.INT_NULL, loopCountRegister, loopLimitRegister));
			branchInstr.abstract.comment = "End loop after " +loopCount + " times.";
			branchInstr.abstract.commentFormat = new HighlightFormat(branchInstr.abstract.comment, new Vector.<ColorText>);
			loop.push(branchInstr);
			
			//final cleanup
			registers[destRegister] = base;
			
			for each (var instruction:Instruction in loop)
				instructions.push(instruction);
			
			return loop;
		}
		
		
		protected function postProcess(instructions:Vector.<Instruction>):Vector.<Instruction> {
			if (jumpsEnabled && (!branchesEnabled || FlxG.random() < 1/4))
				instructions = addJumpLoop(instructions);
			expectedExecutions = instructions.length;
			if (loop) {
				var jumpOverInstruction:Instruction = loop[loop.length - 1];
				var jumpBackInstruction:Instruction = loop[0];
				jumpOverInstruction.args[0] = new InstructionArg(InstructionArg.INT, instructions.indexOf(jumpBackInstruction));
				jumpBackInstruction.args[0] = new InstructionArg(InstructionArg.INT, instructions.indexOf(jumpOverInstruction) - 1);
				
				expectedExecutions += loopExecutions;
			}
			return instructions;
		}
		
		protected function get jumpsEnabled():Boolean { return expectedOps.indexOf(OpcodeValue.OP_JMP) != -1; }
		protected function get branchesEnabled():Boolean { return expectedOps.indexOf(OpcodeValue.OP_BEQ) != -1; }
		
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
		
		protected function executeInEnvironment(memory:Dictionary, registers:Dictionary, stack:Vector.<int>,
												instructions:Vector.<Instruction>):void {
			for (var line:int = 0; line < instructions.length; line ++) {
				var instruction:Instruction = instructions[line];
				var jump:int = instruction.execute(memory, registers, stack);
				if (jump != C.INT_NULL)
					line = jump;
				
				for (var k:* in registers)
					if (isNaN(k))
						throw new Error("!");
				if (stack.length > STACK_SIZE)
					throw new Error("!!!");
			}
		}
		
		
		
		protected function log(...args):void {
			if (DEBUG.PRINT_TESTS)
				C.log(args);
		}
		
		
		
		
		protected function genInitialMemory():Vector.<Value> {
			var memory:Vector.<Value> = generateBlankMemory();
			
			for (var i:int = 0; i < instructions.length; i++)
				memory[i] = instructions[i].toMemValue();
			
			for each (var memorandum:AbstractArg in dataMemory)
				memory[memorandum.address] = new IntegerValue(memorandum.value);
			
			return memory;
		}
		
		protected function genExpectedMemory():Vector.<Value> {
			var memory:Vector.<Value> = initialMemory.slice();
			for (var i:int = saveTargets.length - 1; i >= 0; i--)
				memory[saveTargets[i].address] = new IntegerValue(saveTargets[i].value);
			return memory;
		}
		
		protected function generateBlankMemory():Vector.<Value> {
			var memory:Vector.<Value> = new Vector.<Value>;
			for (var i:int = memory.length; i < U.MAX_INT - U.MIN_INT; i++)
				memory.push(FixedValue.NULL);
			return memory;
		}
		
		protected const NUM_REGISTERS:int = 8;
		public static const STACK_SIZE:int = 4;
	}

}