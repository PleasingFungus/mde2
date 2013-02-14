package Modules {
	import Components.Port;
	import Values.Delta;
	import Values.FixedValue;
	import Values.NumericValue;
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Latch extends Module {
		
		public var initialValue:int;
		public var value:Value;
		protected var lastMomentStored:int = -1;
		public function Latch(X:int, Y:int, InitialValue:int = 0) {
			super(X, Y, "Latch", 1, 1, 1);
			
			delay = 5;
		}
		
		override public function initialize():void {
			value = new NumericValue(initialValue);
			lastMomentStored = -1;
		}
		
		override public function renderName():String {
			return "LCH" +"\n\n" + value;
		}
		
		override public function drive(port:Port):Value {
			return value;
		}
		
		override public function update():Boolean {
			if (U.state.time.moment == lastMomentStored) return false; //can only store at most once per cycle
			
			var control:Value = controls[0].getValue();
			if (control == U.V_UNKNOWN || control == U.V_UNPOWERED || control.toNumber() == 0)
				return false;
			
			var input:Value = inputs[0].getValue();
			U.state.time.deltas.push(new Delta(U.state.time.moment, this, value));
			value = input;
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