package Modules {
	import Values.Value;
	import Values.NumericValue;
	import Values.Delta;
	import Components.Port;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Accumulator extends Module {
		
		public var initialValue:int;
		public var value:Value;
		protected var lastMomentStored:int = -1;
		public function Accumulator(X:int, Y:int, Initial:int = 0) {
			
			super(X, Y, "Accumulator", 0, 1, 1);
			//configuration = new Configuration(new Range(-16, 15), function setValue(newValue:int):void {
				//initialValue = newValue;
				//initialize();
			//});
			
			//delay = 8;
		}
		
		override public function initialize():void {
			value = new NumericValue(initialValue);
			lastMomentStored = -1;
		}
		
		override public function renderName():String {
			return "ACC" +"\n\n" + value;
		}
		
		override public function drive(port:Port):Value {
			return value;
		}
		
		override public function update():Boolean {
			if (U.state.time.moment == lastMomentStored) return false; //can only store at most once per cycle
			
			var control:Value = controls[0].getValue();
			if (control == U.V_UNKNOWN || control == U.V_UNPOWERED || control.toNumber() == 0)
				return false;
			
			if (value.unknown || value.unpowered)
				return false;
			
			U.state.time.deltas.push(new Delta(U.state.time.moment, this, value));
			value = new NumericValue(value.toNumber() + 1);
			lastMomentStored = U.state.time.moment;
			return true;
		}
		
		override public function revertTo(oldValue:Value):void {
			value = oldValue;
			lastMomentStored = -1;
		}
		
		override protected function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(initialValue);
			return values;
		}
	}

}