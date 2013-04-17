package Modules {
	import Components.Port;
	import Values.Value;
	import Values.BooleanValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Or extends Module {
		
		private var width:int;
		public function Or(X:int, Y:int, Width:int = 2) {
			super(X, Y, "Or", Module.CAT_LOGIC, Width, 1, 0);
			abbrev = "Or";
			width = Width;
			configuration = new Configuration(new Range(2, 8, Width));
			configurableInPlace = false;
			delay = Math.ceil(Math.log(Width) / Math.log(2));
		}
		
		protected function resetPorts():void {
			outputs = new Vector.<Port>;
			outputs.push(new Port(true, this));
		}
		
		override public function renderDetails():String {
			var out:String = "Or\n\n";
			for each (var input:Port in inputs)
				out += input.getValue() + ',';
			return out.slice(0, out.length - 1);
		}
		
		override public function getDescription():String {
			return "Outputs "+BooleanValue.NUMERIC_TRUE+" if any input is "+BooleanValue.TRUE+", else "+BooleanValue.NUMERIC_FALSE+"."
		}
		
		override public function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(width);
			return values;
		}
		
		override public function drive(port:Port):Value {
			for each (var inputPort:Port in inputs) {
				var inputValue:Value = inputPort.getValue();
				if (inputValue.unknown || inputValue.unpowered)
					return inputValue;
				if (BooleanValue.fromValue(inputValue).boolValue)
					return BooleanValue.NUMERIC_TRUE;
			}
			return BooleanValue.NUMERIC_FALSE;
		}
		
	}

}