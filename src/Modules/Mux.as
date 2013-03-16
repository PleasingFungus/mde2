package Modules {
	import Components.Port;
	import Values.Value;
	import Layouts.ModuleLayout;
	import Layouts.DefaultLayout;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Mux extends Module {
		
		public var width:int;
		public function Mux(X:int, Y:int, Width:int = 4) {
			super(X, Y, "Mux", Module.CAT_LOGIC, 1, Width, 1);
			width = Width;
			configuration = new Configuration(new Range(2, 8, Width));
			configurableInPlace = false;
			delay = Math.ceil(Math.log(width) / Math.log(2));
		}
		override protected function generateLayout():ModuleLayout {
			var layout:ModuleLayout = new DefaultLayout(this, 2, 5);
			for (var i:int = 0; i < layout.ports.length; i++)
				if (i != 1)
					layout.ports[i].offset.y += 1;
			return layout;
		}
		
		protected function resetPorts():void {
			outputs = new Vector.<Port>;
			for (var i:int = 0; i < width; i++)
				outputs.push(new Port(true, this));
		}
		
		override public function renderName():String {
			return "Mux\n\n" + inputs[0].getValue()+"->"+ controls[0].getValue();
		}
		
		//override public function getDescription():String {
			//return "Outputs the input to the output port indicated by the control value.";
		//}
		
		override protected function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(width);
			return values;
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