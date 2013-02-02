package Modules {
	import Values.Value;
	import Values.NumericValue;
	import Values.Delta;
	import Components.Port;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ProgramCounter extends Module {
		
		public var initialValue:int;
		public var value:Value;
		protected var lastMomentStored:int;
		protected var lastValue:Value;
		public function ProgramCounter(X:int, Y:int, Initial:int = 0) {
			
			super(X, Y, "Program Counter", 1, 1, 2);
			//configuration = new Configuration(new Range(0, 31), function setValue(newValue:int):void {
				//initialValue = newValue;
				//initialize();
			//});
			
			//delay = 8;
		}
		
		override public function initialize():void {
			value = new NumericValue(initialValue);
		}
		
		override public function renderName():String {
			return "PC" +"\n\n" + value;
		}
		
		override public function drive(port:Port):Value {
			if (U.state.time.updating && lastValue)
				return lastValue;
			return value;
		}
		
		override public function update():Boolean {
			if (U.state.time.moment == lastMomentStored) return false; //can only store at most once per cycle
			
			lastValue = value;
			
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
			
			lastMomentStored = U.state.time.moment;
			return true;
		}
		
		override public function finishUpdate():void {
			lastValue = null;
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