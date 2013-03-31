package Testing.Abstractions {
	import Testing.Types.AbstractArg;
	import Testing.Types.InstructionType;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class LoadAbstraction extends InstructionAbstraction {
		
		public function LoadAbstraction(address:int, value:int) {
			super(InstructionType.LOAD, C.buildIntVector(address), value);
		}
		
		override public function getAbstractArgs():Vector.<AbstractArg> {
			var abstractArgs:Vector.<AbstractArg> = new Vector.<AbstractArg>;
			abstractArgs.push(new AbstractArg(value, args[0]),
							  new AbstractArg(args[0]));
			return abstractArgs;
		}
	}

}