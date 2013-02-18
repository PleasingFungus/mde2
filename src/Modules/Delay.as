package Modules {
	import Components.Port;
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Delay extends Module {
		
		public function Delay(X:int, Y:int, delay:int = 1) {
			super(X, Y, "D", Module.CAT_TIME, 1, 1, 0);
			configuration = new Configuration(new Range(1, 32, delay));
			this.delay = delay;
		}
		
		override public function drive(port:Port):Value {
			return inputs[0].getValue();
		}
		
		override public function renderName():String {
			return name + "\n\n" + drive(outputs[0]);
		}
		
		override protected function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(delay);
			return values;
		}
		
	}

}