package Modules {
	import Components.Port;
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Demux extends Module {
		
		public var width:int;
		public function Demux(X:int, Y:int, Width:int = 4) {
			super(X, Y, "Demux", Width, 1, 1);
			width = Width;
			configuration = new Configuration(new Range(2, 8, Width));
			delay = Math.ceil(Math.log(Width) / Math.log(2));;
		}
		
		protected function resetPorts():void {
			inputs = new Vector.<Port>;
			for (var i:int = 0; i < width; i++)
				inputs.push(new Port(false, this));
		}
		
		override public function renderName():String {
			return "Demux\n\n" + controls[0].getValue()+": "+ drive(null);
		}
		
		override protected function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(width);
			return values;
		}
		
		override public function drive(port:Port):Value {
			var control:Value = controls[0].getValue();
			if (control.unknown || control.unpowered)
				return control;
			var index:int = control.toNumber();
			if (index < 0 || index >= width)
				return U.V_UNKNOWN;
			return inputs[index].getValue();
		}
		
	}

}