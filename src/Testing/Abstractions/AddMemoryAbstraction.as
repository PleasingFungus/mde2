package Testing.Abstractions {
	import Testing.Types.InstructionType
	import Testing.Types.AbstractArg;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class AddMemoryAbstraction extends InstructionAbstraction {
		
		public function AddMemoryAbstraction(a1:int, a2:int, address:int) {
			super(InstructionType.ADDM, C.buildIntVector(a1, a2, address), C.INT_NULL);
			writesToMemory = true;
		}
		
		override public function toString():String {
			return type.name + " M[" + args[2] + "]=" + args[0]+"+"+args[1];
		}
		
		override public function getAbstractArgs():Vector.<AbstractArg> {
			var abstractArgs:Vector.<AbstractArg> = new Vector.<AbstractArg>;
			for each (var arg:int in args)
				abstractArgs.push(new AbstractArg(arg, C.INT_NULL, true));
			return abstractArgs;
		}
		
		override public function get memoryAddress():int { return args[2]; }
		override public function get memoryValue():int { return args[0]+args[1]; }
		
	}

}