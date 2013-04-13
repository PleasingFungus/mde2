package Testing.Abstractions {
	import Testing.Types.InstructionType
	import Testing.Types.AbstractArg;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SaveImmediateAbstraction extends InstructionAbstraction {
		
		public function SaveImmediateAbstraction(value:int, address:int) {
			super(InstructionType.SAVI, C.buildIntVector(value, address), C.INT_NULL);
			writesToMemory = true;
		}
		
		override public function toString():String {
			return type.name + " M[" + args[1] + "]=" + args[0];
		}
		
		override public function getAbstractArgs():Vector.<AbstractArg> {
			var abstractArgs:Vector.<AbstractArg> = new Vector.<AbstractArg>;
			for each (var arg:int in args)
				abstractArgs.push(new AbstractArg(arg, C.INT_NULL, true));
			return abstractArgs;
		}
		
		override public function get memoryAddress():int { return args[1]; }
		override public function get memoryValue():int { return args[0]; }
		
	}

}