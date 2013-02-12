package Modules {
	import Components.Port;
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Mux extends Module {
		
		public var width:int;
		public function Mux(X:int, Y:int, Width:int = 4) {
			super(X, Y, "Mux", 1, Width, 1);
			width = Width;
			configuration = new Configuration(new Range(2, 8, Width));
			//configuration = new Configuration(new Range(2, 8, Width/2), function setValue(newValue:int):void {
				//width = newValue;
				//resetPorts();
				//dirty = true;
			//});
			delay = 2;
		}
		
		protected function resetPorts():void {
			outputs = new Vector.<Port>;
			for (var i:int = 0; i < width; i++)
				outputs.push(new Port(true, this));
		}
		
		override public function renderName():String {
			return "Mux\n\n" + inputs[0].getValue()+"->"+ controls[0].getValue();
		}
		
		override public function drive(port:Port):Value {
			var index:int = outputs.indexOf(port);
			var control:Value = controls[0].getValue();
			if (control.unknown || control.unpowered)
				return control;
			if (control.toNumber() == index)
				return inputs[0].getValue();
			return U.V_UNPOWERED;
		}
		
	}

}