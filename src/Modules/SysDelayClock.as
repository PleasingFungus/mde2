package Modules {
	import Components.Port;
	import Values.Value;
	import Values.NumericValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SysDelayClock extends Module {
		
		public var edgeLength:int = 1;
		public function SysDelayClock(X:int, Y:int, EdgeLength:int = 1) {
			super(X, Y, "SysClock", Module.CAT_TIME, 0, 1, 0);
			configuration = getConfiguration();
			if (U.state)
				configuration.setValue(EdgeLength);
			setByConfig();
		}
		
		override public function getConfiguration():Configuration {
			var maxEdge:int = U.state ? U.state.time.clockPeriod - 1 : 64;
			if (!configuration)
				configuration = new Configuration(new Range(1, maxEdge, edgeLength));
			if (U.state && configuration.valueRange.max != maxEdge) {
				var initial:int = Math.max(Math.min(edgeLength, maxEdge), 1);
				configuration.valueRange.max = maxEdge;
				configuration.value = initial;
			}
			return configuration;
		}
		
		override public function setByConfig():void {
			edgeLength = configuration.value;
		}
		
		override public function renderDetails():String {
			return "SYSCLK" + "\n"+U.state.time.clockPeriod+"\n"+edgeLength+"-"+delayLength+"\n\n" + drive(null);
		}
		
		override public function getDescription():String {
			var edgeLength:int = configuration.value;
			return "Outputs "+EDGE+" for "+edgeLength+" ticks every "+(U.state.time.clockPeriod - edgeLength)+" ticks, and "+NO_EDGE+" the rest of the time."
		}
		
		protected function get delayLength():int {
			return Math.max(1, U.state.time.clockPeriod - edgeLength);
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