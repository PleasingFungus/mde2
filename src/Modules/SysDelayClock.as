package Modules {
	import Components.Port;
	import Values.Value;
	import Values.NumericValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SysDelayClock extends Module {
		
		public var edgeLength:int;
		protected var clockPeriod:int;
		public function SysDelayClock(X:int, Y:int, EdgeLength:int = 1) {
			super(X, Y, "SysClock", Module.CAT_TIME, 0, 1, 0);
			configuration = getConfiguration();
			if (U.state)
				configuration.setValue(EdgeLength);
			setByConfig();
		}
		
		override public function getConfiguration():Configuration {
			if (!U.state)
				return configuration = new Configuration(new Range(1, 63, edgeLength));
			if (U.state.time.clockPeriod != clockPeriod) {
				clockPeriod = U.state.time.clockPeriod;
				configuration = new Configuration(new Range(1, clockPeriod - 1, Math.max(Math.min(edgeLength, clockPeriod - 1), 1)));
			}
			return configuration;
		}
		
		override public function setByConfig():void {
			edgeLength = configuration.value;
		}
		
		override public function renderDetails():String {
			return "SYSCLK" + "\n"+U.state.time.clockPeriod+"\n"+edgeLength+"-"+(U.state.time.clockPeriod - edgeLength)+"\n\n" + drive(null);
		}
		
		override public function getDescription():String {
			return "Outputs "+EDGE+" for "+edgeLength+" ticks every "+configuration.value+" ticks, and "+NO_EDGE+" the rest of the time."
		}
		
		override public function drive(port:Port):Value {
			if (U.state.time.clockPeriod - (U.state.time.moment % U.state.time.clockPeriod) <= edgeLength) //within e ticks of the end of the clock period
				return EDGE;
			return NO_EDGE;
		}
		
		override protected function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(edgeLength);
			return values;
		}
		
		public const EDGE:Value = new NumericValue(1);
		public const NO_EDGE:Value = new NumericValue(0);
		
	}

}