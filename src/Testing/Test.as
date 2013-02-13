package Testing {
	import flash.utils.Dictionary;
	import Modules.Module;
	import org.flixel.FlxG;
	import Testing.Abstractions.InstructionAbstraction;
	import Testing.Abstractions.SaveAbstraction;
	import Testing.Abstractions.SetAbstraction;
	import Testing.Instructions.Instruction;
	import Values.BooleanValue;
	import Testing.Types.InstructionType;
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Test {
		
		public var memAddressToSet:int;
		public var memValueToSet:int
		public var instructions:Vector.<Instruction>;
		
		public function Test(seed:Number) {
			FlxG.globalSeed = seed = Math.random(); //FIXME
			
			memAddressToSet = C.randomRange(0, U.MAX_INT - U.MIN_INT);
			memValueToSet = C.randomRange(U.MIN_INT, U.MAX_INT);
			var values:Vector.<int> = C.buildIntVector(memAddressToSet, memValueToSet);
			
			var abstractions:Vector.<InstructionAbstraction> = new Vector.<InstructionAbstraction>;
			abstractions.push(new SaveAbstraction( -1, memValueToSet, memAddressToSet));
			
			var minInstructions:int = 10;
			
			for (var depth:int = 0; abstractions.length + values.length < minInstructions; depth++)
				genAbstractions(abstractions, values, depth);
			
			genInitializationAbstractions(abstractions, values, depth);
			
			var orderedAbstractions:Vector.<InstructionAbstraction> = new Vector.<InstructionAbstraction>;
			while (abstractions.length)
				orderedAbstractions.push(abstractions.pop());
			
			log("\n\nSEED: " + seed);
			log("PROGRAM START");
			for (var i:int = 0; i < orderedAbstractions.length; i++)
				log(i + ": " + orderedAbstractions[i]);
			log("PROGRAM END\n\n");
			
			var virtualRegisters:Vector.<int> = new Vector.<int>;
			instructions = new Vector.<Instruction>;
			for (var line:int = 0; line < orderedAbstractions.length; line++) {
				var abstraction:InstructionAbstraction = orderedAbstractions[line];
				log(line, abstraction);
				instructions.push(genInstruction(line, abstraction, virtualRegisters, orderedAbstractions));
				log("Virtual registers: " + virtualRegisters);
			}
			
			//TODO: scramble registers
			
			log("\n\nSEED: " + seed);
			log("PROGRAM START");
			for (i = 0; i < instructions.length; i++)
				log(i + ": " + instructions[i]);
			log("PROGRAM END\n\n");
			
			var regCount:int = 8;
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
		
		protected function executeInEnvironment(memory:Dictionary, registers:Dictionary, instructions:Vector.<Instruction>):void {
			for each (var instruction:Instruction in instructions)
				instruction.execute(memory, registers);
		}
		
		protected function genAbstractions(abstractions:Vector.<InstructionAbstraction>, values:Vector.<int>, depth:int):void {
			log("Instructions: " + abstractions);
			log("Values: " + values);
			
			while (values.length)
				abstractions.push(genAbstraction(values.pop(), depth, getArgs(abstractions, depth)));
			
			for each (var abstraction:InstructionAbstraction in abstractions)
				if (abstraction.depth == depth)
					for each (var arg:int in abstraction.args)
						if (values.indexOf(arg) == -1)
							values.push(arg);
		}
		
		protected function genAbstraction(value:int, depth:int, args:Vector.<int>):InstructionAbstraction {
			var type:InstructionType;
			var abstraction:InstructionAbstraction;
			var arg:int;
			
			log("Attempting to produce " +value);
			log("Args: " + args);
			var fullReuseInstrs:Vector.<InstructionType> = new Vector.<InstructionType>;
			for each (type in InstructionType.TYPES)
				if (type.can_produce_with(value, args))
					fullReuseInstrs.push(type);
			if (fullReuseInstrs.length) {
				log("Full re-use instrs: " + fullReuseInstrs);
				abstraction = randomTypeChoice(fullReuseInstrs).produce_with(value, depth, args);
				log("Added " + abstraction + " with full re-use");
				return abstraction;
			}
			log("No full re-use instrs")
			
			var partialReuseInstrs:Vector.<InstructionType> = new Vector.<InstructionType>;
			for each (type in InstructionType.TYPES)
				if (type.can_produce_with_one_of(value, args))
					partialReuseInstrs.push(type);
			if (partialReuseInstrs.length) {
				log("Partial re-use instrs: " + partialReuseInstrs);
				
				type = randomTypeChoice(partialReuseInstrs);
				var validArgs:Vector.<int> = new Vector.<int>;
				for each (arg in args)
					if (type.can_produce_with_one(value, arg))
						validArgs.push(arg);
				log("Valid args for " + type.name + ": " + validArgs);
				
				arg = C.randomIntChoice(validArgs);
				abstraction = type.produce_with_one(value, depth, arg);
				log("Added " + abstraction + ", re-using " + arg);
				return abstraction;
			}
			log("No partial re-use instrs")
			
			type = C.randomChoice(InstructionType.TYPES);
			abstraction = type.produce_unrestrained(value, depth);
			log("Added " + abstraction);
			return abstraction;
		}
		
		protected function genInitializationAbstractions(abstractions:Vector.<InstructionAbstraction>, values:Vector.<int>, depth:int):void {
			for each (var value:int in values)
				abstractions.push(new SetAbstraction(depth, value));
		}
		
		protected function genInstruction(line:int, abstraction:InstructionAbstraction, virtualRegisters:Vector.<int>,
										   abstractions:Vector.<InstructionAbstraction>):Instruction {
			var registers:Vector.<int> = new Vector.<int>;
			for each (var arg:int in abstraction.args)
				registers.push(virtualRegisters.indexOf(arg));
			
			if (abstraction.value != C.INT_NULL) {
				var destination:int = findRegisterFor(abstraction.depth, line, abstraction.value, virtualRegisters, abstractions);
				var noop:Boolean = destination < virtualRegisters.length && virtualRegisters[destination] == abstraction.value;
				registers.splice(0, 0, destination);
				if (destination < virtualRegisters.length)
					virtualRegisters[destination] = abstraction.value;
				else
					virtualRegisters.push(abstraction.value);
			}
			
			var instructionClass:Class = Instruction.mapByType(abstraction.type);
			return new instructionClass(registers, abstraction, noop);
		}
		
		protected function findRegisterFor(depth:int, line:int, value:int,
										   virtualRegisters:Vector.<int>,
										   abstractions:Vector.<InstructionAbstraction>):int {
			if (virtualRegisters.indexOf(value) != -1) {
				log("Storing " + value + " is a no-op");
				return virtualRegisters.indexOf(value);
			}
			
			
			var abstraction:InstructionAbstraction;
			
			var successors:Vector.<InstructionAbstraction> = abstractions.slice(line + 1);
			var predependents:Vector.<InstructionAbstraction> = abstractions.slice(0, line + 1);
			
			var blockingInstructions:Vector.<InstructionAbstraction> = new Vector.<InstructionAbstraction>;
			for each (abstraction in successors)
				if (abstraction.depth <= depth + 1)
					blockingInstructions.push(abstraction);
			
			var freeRegValues:Vector.<int> = new Vector.<int>;
			for each (var rv:int in virtualRegisters) {
				var blocked:Boolean = false;
				for each (abstraction in blockingInstructions)
					if (abstraction.args.indexOf(rv) != -1) {
						blocked = true;
						break;
					}
				
				if (!blocked)
					freeRegValues.push(rv);
			}
			
			//var allArgs:Vector.<int> = getArgs(predependents, C.INT_NULL);
			//free_reg_values.sort(key=lambda rv: -all_args.index(rv)) #TODO
			log("Free register values: " + freeRegValues);
			
			if (freeRegValues.length) {
				log("Storing " + value + " in existing slot " + virtualRegisters.indexOf(freeRegValues[0])+" currently holding "+freeRegValues[0]);
				return virtualRegisters.indexOf(freeRegValues[0]);
			}
			log("Storing " + value + " in previously unallocated register " + virtualRegisters.length);
			return virtualRegisters.length;
		}
		
		protected function getArgs(abstractions:Vector.<InstructionAbstraction>, depth:int):Vector.<int> {
			var args:Vector.<int> = new Vector.<int>;
			
			for each (var abstraction:InstructionAbstraction in abstractions)
				if (abstraction.depth == depth || depth == C.INT_NULL)
					for each (var arg:int in abstraction.args)
						if (args.indexOf(arg) == -1)
							args.push(arg);
			
			return args;
		}
		
		protected function randomTypeChoice(options:Vector.<InstructionType>):InstructionType {
			return options[int(FlxG.random() * options.length)];
		}
		
		protected function log(...args):void {
			if (U.DEBUG && U.DEBUG_PRINT_TESTS)
				log(args);
		}
		
		
		
		
		public function initialMemory():Vector.<Value> {
			var mem:Vector.<Value> = new Vector.<Value>;
			for each (var instr:Instruction in instructions)
				mem.push(instr.toMemValue());
			return mem;
		}
		
		public function validate(_:Module):Boolean {
			if (U.state.memory[memAddressToSet].toNumber() == memValueToSet)
				return true;
			return false;
		}
	}

}