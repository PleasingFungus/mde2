package Testing {
	import Testing.Instructions.Instruction;
	import Values.FixedValue;
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class GeneratedGoal extends LevelGoal {
		
		protected var testClass:Class;
		public function GeneratedGoal(Description:String, TestClass:Class) {
			testClass = TestClass;
			super(Description, CheckWin, GenMem, OnWin, OnLose);
		}
		
		protected function CheckWin():Boolean {
			return false; //TODO
		}
		
		protected function GenMem(Seed:Number = NaN):Vector.<Value> {
			var instructions:Vector.<Instruction> = (new testClass(Seed) as Test).instructions;
			var memory:Vector.<Value> = new Vector.<Value>;
			for each (var instr:Instruction in instructions)
				memory.push(instr.toMemValue());
			for (var i:int = memory.length; i < U.MAX_INT - U.MIN_INT; i++)
				memory.push(FixedValue.NULL);
			return memory;
		}
		
		protected function OnWin():void {
			
		}
		
		protected function OnLose():void {
			
		}
	}

}