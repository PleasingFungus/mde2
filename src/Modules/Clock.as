package Modules {
	import Components.Port;
	import Values.FixedValue;
	import Values.NumericValue;
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Clock extends Module {
		
		public var period:int;
		public function Clock(X:int, Y:int, Period:int = 2) {
			super(X, Y, "Clock", Module.CAT_TIME, 0, 1, 0);
			configuration = new Configuration(new Range(2, 100, Period));
			setByConfig();
		}
		
		override public function setByConfig():void {
			period = configuration.value;
		}
		
		override public function renderDetails():String {
			return "CLK" + "\n"+period+"\n\n" + drive(null);
		}
		
		override public function getDescription():String {
			return "Outputs "+EDGE+" once every "+configuration.value+" ticks, and "+NO_EDGE+" the rest of the time."
		}
		
		override public function drive(port:Port):Value {
			if ((U.state.time.moment - 1) % period == 0)
				return EDGE;
			return NO_EDGE;
		}
		
		override protected function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(period);
			return values;
		}
		
		public const EDGE:Value = new NumericValue(1);
		public const NO_EDGE:Value = new NumericValue(0);
		
	}

}