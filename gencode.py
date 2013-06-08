import math
import itertools
import random
random.seed(0)

min_int = -128
max_int = 127

def randrange(min_, max_):
    center = (min_ + max_) / 2
    halfmin = (min_ + center) / 2
    halfmax = (max_ + center) / 2
    a1 = random.randrange(math.ceil(halfmin), math.ceil(halfmax))
    a2 = random.randrange(math.floor(halfmin), math.floor(halfmax))
    return a1 + a2
    #return random.randrange(min_, max_)

class InstrType:
    def __init__(self, name):
        self.name = name

    def __str__(self):
        return "<{}>".format(self.name)

    def can_produce(self, value):
        return False

    def can_produce_with(self, value, args):
        return False

    def can_produce_with_one(self, value, args):
        return False

    def produce(self, value, depth, args=None):
        return None

class AddType(InstrType):
    def __init__(self):
        super().__init__("Add")

    def can_produce(self, value):
        return True

    def can_produce_with(self, value, args):
        for i, a1 in enumerate(args):
            for a2 in args[:i] + args[i+1:]:
                if a1 + a2 == value:
                    return True
        return False

    def can_produce_with_one_of(self, value, args):
        for arg in args:
            a2 = value - arg
            if a2 >= min_int and a2 <= max_int:
                return True
        return False

    def can_produce_with_one(self, value, arg):
        a2 = value - arg
        return a2 >= min_int and a2 <= max_int

    def produce(self, value, depth, args=None):
        if not args:
            min_addend = max((min_int, value - max_int))
            max_addend = min((max_int, value - min_int))
        
            a1 = randrange(min_addend, max_addend)
            a2 = value - a1
        elif len(args) == 1:
            a1 = args[0]
            a2 = value - a1
        else:
            pairs = []
            for i, a1 in enumerate(args):
                for a2 in args[:i] + args[i+1:]:
                    if a1 + a2 == value:
                        pairs.append((a1, a2))
            a1, a2 = random.choice(pairs)
        
        return AddAbstr(depth, a1, a2, value)

class SaveType(InstrType):
    def __init__(self):
        super().__init__("Save")
    #TODO

class SetType(InstrType):
    def __init__(self):
        super().__init__("Set")
    #TODO

ADD = AddType();
SAVE = SaveType();
SET = SetType();
instr_types = [ADD]

class InstrAbstr:
    def __init__(self, type_, depth, args=[], v=None):
        self.type_ = type_
        self.depth = depth
        self.args = args
        self.value = v

    def __str__(self):
        return "{} {} = {}".format(self.type_.name,
                                   ' '.join(str(a) for a in self.args),
                                   self.value)

class AddAbstr(InstrAbstr):
    def __init__(self, depth, a1, a2, v):
        super().__init__(ADD, depth, (a1, a2), v)

class SaveAbstr(InstrAbstr):
    def __init__(self, depth, target, value):
        super().__init__(SAVE, depth, (target, value))

    def __str__(self):
        return "{} {} -> {}".format(self.type_.name, *self.args)

class SetAbstr(InstrAbstr):
    def __init__(self, depth, value):
        super().__init__(SET, depth, v=value)

    def __str__(self):
        return "{} {}".format(self.type_.name, self.value)


mem_addr_to_set = randrange(min_int, max_int)
mem_val_to_set = randrange(min_int, max_int)
values = [mem_addr_to_set, mem_val_to_set]
#values_to_gen = 2
#values = [randrange(min_int, max_int) for i in range(values_to_gen)]
instructions = [SaveAbstr(-1, mem_addr_to_set, mem_val_to_set)]
min_instructions = 10

def get_args(instructions, depth=None):
    return list(set(itertools.chain.from_iterable(instr.args for instr in instructions if instr.depth == depth or depth == None)))

for depth in itertools.count():
    print("Instructions: {}".format(instructions))
    print("Values: {}".format(values))
    for value in values:
        print("Attempting to produce {}".format(value))
        args = get_args(instructions, depth)
        print("Args: {}".format(args))
        full_reuse_instrs = list(filter(lambda it: it.can_produce_with(value, args), instr_types))
        if len(full_reuse_instrs):
            print("Full re-use instrs: {}".format(full_reuse_instrs))
            instructions.append(random.choice(full_reuse_instrs).produce(value, depth, args))
            print("Added {} with full re-use".format(instructions[-1]))
            continue
        print("No full re-use instrs")

        partial_reuse_instrs = list(filter(lambda it: it.can_produce_with_one_of(value, args), instr_types))
        if len(partial_reuse_instrs):
            print("Partial re-use instrs: {}".format(partial_reuse_instrs))
            instr = random.choice(partial_reuse_instrs)
            valid_args = list(filter(lambda arg: instr.can_produce_with_one(value, arg), args))
            print("Valid args for {}: {}".format(instr, valid_args))
            arg = random.choice(valid_args)
            instructions.append(instr.produce(value, depth, [arg]))
            print("Added {}, re-using {}".format(instructions[-1], arg))
            continue
        print("No partial re-use instrs")

        instr = random.choice(instr_types)
        instructions.append(instr.produce(value, depth))
        print("Added {}".format(instructions[-1]))

    values = get_args(instructions, depth)

    if len(instructions) >= min_instructions:
        break

depth = max(instr.depth for instr in instructions) + 1
for value in values:
    instructions.append(SetAbstr(depth, value))
instructions = list(reversed(instructions))

print("PROGRAM START")
for i, instr in enumerate(instructions):
    print(i, instr)
print("PROGRAM END\n\n")

INT = 0
REG = 1

class InstructionArg:
    def __init__(self, atype, value):
        self.atype = atype
        self.value = value

    def __str__(self):
        if self.atype == INT:
            return str(self.value)
        elif self.atype == REG:
            return 'R{}'.format(self.value)
        return '???'

class Instruction:
    def __init__(self, regs, abstract, noop=False):
        self.type_ = abstract.type_
        self.args = self.find_args(regs, abstract)
        self.noop = noop
        self.comment = str(abstract)
        if self.noop:
            self.comment += ' (NOOP)'

    def __str__(self):
        return "{} {} #{}".format(self.type_.name,
                                   ' '.join(map(str, self.args)),
                                   self.comment)

    def find_args(self, regs, abstract):
        return []

    def execute(memory, registers):
        pass

class RegInstruction(Instruction):
    def find_args(self, regs, abstract):
        return [InstructionArg(REG, r) for r in regs]

class AddInstruction(RegInstruction):
    def execute(self, memory, registers):
        registers[self.args[0].value] = registers[self.args[1].value] + registers[self.args[2].value]

class SaveInstruction(RegInstruction):
    def execute(self, memory, registers):
        memory[registers[self.args[1].value]] = registers[self.args[0].value]

class SetInstruction(Instruction):
    def find_args(self, regs, abstract):
        return [InstructionArg(REG, regs[0])] + [InstructionArg(INT, abstract.value)]

    def execute(self, memory, registers):
        registers[self.args[0].value] = self.args[1].value

abstr_to_instr_map = {
    ADD : AddInstruction,
    SAVE : SaveInstruction,
    SET : SetInstruction,
}


virtual_registers = []
def find_register_for(depth, i, value):
    if value in virtual_registers:
        return virtual_registers.index(value)

    successors = instructions[i+1:]
    predependents = instructions[:i+1]

    blocking_instructions = list(filter(lambda instr: instr.depth <= depth + 1,
                                       successors))
    free_reg_values = list(filter(lambda rv: not any(rv in instr.args for instr in blocking_instructions),
                                  virtual_registers))
    all_args = list(reversed(get_args(predependents)))
    free_reg_values.sort(key=lambda rv: -all_args.index(rv)) #TESTME
    if free_reg_values:
        return virtual_registers.index(free_reg_values[0])

    return len(virtual_registers)

real_instructions = []
for i, instruction in enumerate(instructions):                             
    print(i, instruction)
    regs = [virtual_registers.index(arg) for arg in instruction.args]
    print("Arg registers: {}".format(
        ' '.join("R{}: {}".format(
            r, virtual_registers[r])
        for r in regs)
    ))

    if instruction.value != None:
        destination = find_register_for(instruction.depth, i, instruction.value)
        noop = destination < len(virtual_registers) and virtual_registers[destination] == instruction.value
        regs = [destination] + regs
        if destination < len(virtual_registers):
            virtual_registers[destination] = instruction.value
        else:
            virtual_registers.append(instruction.value)

    instr_class = abstr_to_instr_map[instruction.type_]
    real_instruction = instr_class(regs, instruction, noop)
    real_instructions.append(real_instruction)

#TODO: scramble registers

print("PROGRAM START")
for i, instr in enumerate(real_instructions):
    print(i, instr)


def execute_in_environment(memory, registers, instructions):
    for instruction in instructions:
        instruction.execute(memory, registers)

reg_count = 8
memory = {}
execute_in_environment(memory, [None]*reg_count, real_instructions)
print("Memory: {}".format(memory))
