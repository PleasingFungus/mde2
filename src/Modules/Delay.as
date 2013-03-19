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
			setByConfig();
		}
		
		override public function setByConfig():void {
			delay = configuration.value;
		}
		
		override public function drive(port:Port):Value {
			return inputs[0].getValue();
		}
		
		override public function renderDetails():String {
			return name + "\n\n" + drive(outputs[0]);
		}
		
		override public function getDescription():String {
			return "Outputs the input value. (Has a propagation delay of " + configuration.value + " ticks.)";
		}
		
		override protected function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(delay);
			return values;
		}
		
	}

}