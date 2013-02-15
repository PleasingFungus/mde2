package Modules {
	import Values.Value;
	import Values.NumericValue;
	import Values.Delta;
	import Components.Port;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Accumulator extends StatefulModule {
		
		public function Accumulator(X:int, Y:int, Initial:int = 0) {
			super(X, Y, "Accumulator", 0, 1, 1, Initial);
			configuration = new Configuration(new Range(-16, 15, 0));
			delay = 8;
		}
		
		override public function renderName():String {
			return "ACC" +"\n\n" + value;
		}
		
		override public function drive(port:Port):Value {
			return value;
		}
		
		override protected function statefulUpdate():Boolean {
			var control:Value = controls[0].getValue();
			if (control == U.V_UNKNOWN || control == U.V_UNPOWERED || control.toNumber() == 0)
				return false;
			
			if (value.unknown || value.unpowered)
				return false;
			
			U.state.time.deltas.push(new Delta(U.state.time.moment, this, value));
			value = new NumericValue(value.toNumber() + 1);
			return true;
		}
	}

}