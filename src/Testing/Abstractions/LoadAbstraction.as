package Testing.Abstractions {
	import Testing.Types.AbstractArg;
	import Testing.Types.InstructionType;
	import UI.ColorText;
	import UI.HighlightFormat;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class LoadAbstraction extends InstructionAbstraction {
		
		public function LoadAbstraction(address:int, value:int) {
			super(InstructionType.LOAD, C.buildIntVector(address), value);
		}
		
		override public function toString():String {
			return type.name + " M[" + args[0] + "] ("+value+")";
		}
		
		override public function toFormat():HighlightFormat {
			return new HighlightFormat(type.name +" M[{}] ({})", ColorText.vecFromArray([new ColorText(U.TARGET.color, args[0].toString()),
																					     new ColorText(U.DESTINATION.color, value.toString())]));
		}
		
		override public function getAbstractArgs():Vector.<AbstractArg> {
			var abstractArgs:Vector.<AbstractArg> = new Vector.<AbstractArg>;
			abstractArgs.push(new AbstractArg(value, args[0]),
							  new AbstractArg(args[0]));
			return abstractArgs;
		}
	}

}