package Modules {
	import Components.Port;
	import Values.Delta;
	import Values.FixedValue;
	import Values.NumericValue;
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Latch extends StatefulModule {
		
		public function Latch(X:int, Y:int, InitialValue:int = 0) {
			super(X, Y, "Latch", Module.CAT_STORAGE, 1, 1, 1, InitialValue);
			//configuration = new Configuration(new Range( -32, 31, InitialValue));
			delay = 2;
		}
		
		override public function renderName():String {
			return "LCH" +"\n\n" + value;
		}
		
		override public function drive(port:Port):Value {
			return value;
		}
		
		override protected function statefulUpdate():Boolean {
			var control:Value = controls[0].getValue();
			if (control == U.V_UNKNOWN || control == U.V_UNPOWERED || control.toNumber() == 0)
				return false;
			
			var input:Value = inputs[0].getValue();
			U.state.time.deltas.push(new Delta(U.state.time.moment, this, value));
			value = input;
			return true;
		}
		
	}

}