package Modules {
	import Values.Value;
	import Values.NumericValue;
	import Values.Delta;
	import Components.Port;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ProgramCounter extends StatefulModule {
		
		public function ProgramCounter(X:int, Y:int, Initial:int = 0) {
			
			super(X, Y, "Program Counter", Module.CAT_STORAGE, 1, 1, 2, Initial);
			
			delay = 5;
		}
		
		override public function renderName():String {
			return "PC" +"\n\n" + value;
		}
		
		override public function drive(port:Port):Value {
			return value;
		}
		
		override protected function statefulUpdate():Boolean {
			var control:Value = controls[1].getValue();
			if (control == U.V_UNKNOWN || control == U.V_UNPOWERED || control.toNumber() == 0)
				return false;
			
			var forceSet:Value = controls[0].getValue();
			if (forceSet == U.V_UNKNOWN || forceSet == U.V_UNPOWERED || forceSet.toNumber() == 0) {
				if (value.unknown || value.unpowered)
					return false;
				
				U.state.time.deltas.push(new Delta(U.state.time.moment, this, value));
				value = new NumericValue(value.toNumber() + 1);
			} else {
				var input:Value = inputs[0].getValue();
				U.state.time.deltas.push(new Delta(U.state.time.moment, this, value));
				value = input;
			}
			
			return true;
		}
		
	}

}