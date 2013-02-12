package Modules {
	import Components.Port;
	import Values.Value;
	import Values.OpcodeValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InstructionDemux extends Module {
		
		public var width:int;
		public function InstructionDemux(X:int, Y:int) {
			width = U.state ? U.state.level.expectedOps.length : 1;
			super(X, Y, "I-Demux", width, 1, 1);
			delay = 2;
		}
		
		protected function resetPorts():void {
			inputs = new Vector.<Port>;
			for (var i:int = 0; i < width; i++)
				inputs.push(new Port(false, this));
		}
		
		override public function renderName():String {
			return "I-Demux\n\n" + controls[0].getValue()+": "+ drive(null);
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
			var op:OpcodeValue = OpcodeValue.fromValue(control);
			var index:int = U.state.level.expectedOps.indexOf(op);
			if (index < 0 || index >= width)
				return U.V_UNKNOWN;
			return inputs[index].getValue();
		}
		
	}

}