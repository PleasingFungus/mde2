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
			super(X, Y, "Clock", 0, 1, 0);
			period = Period;
			configuration = new Configuration(new Range(2, 100, Period));
		}
		
		override public function renderName():String {
			return "CLK" + "\n"+period+"\n\n" + drive(null);
		}
		
		override public function drive(port:Port):Value {
			if ((U.state.time.moment + 1) % period == 0)
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