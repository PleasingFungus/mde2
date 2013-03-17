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
		public function SysDelayClock(X:int, Y:int, EdgeLength:int = 1) {
			super(X, Y, "SysClock", Module.CAT_TIME, 0, 1, 0);
			configuration = new Configuration(new Range(1, 63, EdgeLength));
			setByConfig();
		}
		
		override public function setByConfig():void {
			edgeLength = Math.min(configuration.value, U.state ? U.state.time.clockPeriod - 1 : int.MAX_VALUE);
		}
		
		override public function renderName():String {
			return "SYSCLK" + "\n"+U.state.time.clockPeriod+"\n"+edgeLength+"-"+(U.state.time.clockPeriod - edgeLength)+"\n\n" + drive(null);
		}
		
		override public function getDescription():String {
			return "Outputs "+EDGE+" for "+edgeLength+" ticks every "+configuration.value+" ticks, and "+NO_EDGE+" the rest of the time."
		}
		
		override public function drive(port:Port):Value {
			if ((U.state.time.moment + U.state.time.clockPeriod - 1) % U.state.time.clockPeriod < edgeLength)
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