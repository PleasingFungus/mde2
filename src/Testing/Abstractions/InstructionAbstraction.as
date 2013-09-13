package Testing.Abstractions {
	import Testing.Types.AbstractArg;
	import Testing.Types.InstructionType;
	import UI.ColorText;
	import UI.HighlightFormat;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InstructionAbstraction {
		
		public var type:InstructionType;
		public var args:Vector.<int>;
		public var value:int;
		public var writesToMemory:Boolean;
		public var writesToStack:Boolean;
		
		public var comment:String;
		public var commentFormat:HighlightFormat;
		public function InstructionAbstraction(type:InstructionType, args:Vector.<int>, value:int) {
			this.type = type;
			this.args = args ? args : new Vector.<int>;
			this.value = value;
		}
		
		public function toString():String {
			if (comment)
				return comment;
			
			var out:String = "";
			out += type.name + " ";
			for each (var arg:int in args)
				out += arg +" ";
			if (value != C.INT_NULL)
				out += "= " + value;
			return out;
		}
		
		public function toFormat():HighlightFormat {
			if (commentFormat)
				return commentFormat;
			
			var out:String = "";
			var colorTexts:Vector.<ColorText> = new Vector.<ColorText>;
			var colorOptions:Array = [U.SOURCE, U.TARGET, U.DESTINATION];
			
			out += type.name + " ";
			for each (var arg:int in args) {
				out += "{} ";
				colorTexts.push(new ColorText(colorOptions[colorTexts.length].color, arg.toString()));
			}
			if (value != C.INT_NULL) {
				out += "= {}";
				colorTexts.push(new ColorText(U.DESTINATION.color, value.toString()));
			}
			return new HighlightFormat(out, colorTexts);
		}
		
		public function getAbstractArgs():Vector.<AbstractArg> {
			var abstractArgs:Vector.<AbstractArg> = new Vector.<AbstractArg>;
			for each (var arg:int in args)
				abstractArgs.push(new AbstractArg(arg));
			return abstractArgs;
		}
		
		public function get memoryAddress():int { return C.INT_NULL }
		public function get memoryValue():int { return C.INT_NULL }
		public function get stackValue():int { return C.INT_NULL }
	}

}