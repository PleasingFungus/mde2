package Modules {
	import Components.Port;
	import Values.BooleanValue;
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Comparator extends Module {
		
		public var compareValue:int;
		public function Comparator(X:int, Y:int, CompareValue:int = 0) {
			super(X, Y, "Comparator", 1, 1, 0);
			compareValue = CompareValue;
			
			configuration = new Configuration(new Range( -64, 63), function setValue(newValue:int):void {
				compareValue = newValue;
			});
			delay = 1;
		}
		
		override public function renderName():String {
			return "=" + "\n"+compareValue+"\n\n" + drive(null);
		}
		
		
		override public function drive(port:Port):Value {
			var input:Value = inputs[0].getValue();
			if (input.unknown || input.unpowered)
				return input;
			return input.toNumber() == compareValue ? BooleanValue.TRUE : BooleanValue.FALSE;
		}
		
		override protected function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(compareValue);
			return values;
		}
	}

}