package Modules {
	import Values.NumericValue;
	import Values.Value;
	import Values.Delta;
	import Components.Port;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DataMemory extends Module {
		
		protected var lastMomentStored:int;
		protected var lastValue:Value;	
		public function DataMemory(X:int, Y:int) {
			super(X, Y, "Data Memory", 1, 1, 3);
			delay = 30;
		}
		
		override public function renderName():String {
			var out:String = "DMEM\n\n" + controls[0].getValue()+": ";
			
			var dataValue:NumericValue = data;
			if (dataValue)
				out += dataValue;
			else
				out += new NumericValue(0);
			
			return out;
		}
		
		override public function drive(port:Port):Value {
			if (U.level.time.updating && lastValue)
				return lastValue;
			
			var line:Value = controls[0].getValue();
			if (line.unpowered || line.unknown) return line;
			
			var memoryValue:Value = U.level.memory[line.toNumber()];
			if (!memoryValue)
				return U.V_UNKNOWN;
			
			return NumericValue.fromValue(memoryValue);
		}
		
		protected function get data():NumericValue { 
			var line:Value = controls[0].getValue();
			if (line.unpowered || line.unknown) return null;
			
			var memoryValue:Value = U.level.memory[line.toNumber()];
			if (!memoryValue)
				return null;
			
			return NumericValue.fromValue(memoryValue);
		}
		
		override public function update():Boolean {
			if (U.level.time.moment == lastMomentStored) return false; //can only store at most once per cycle
			
			lastValue = drive(null);
			
			var line:Value = controls[1].getValue();
			if (line.unpowered || line.unknown || line.toNumber() < 0) return false;
			
			var control:Value = controls[2].getValue();
			if (control == U.V_UNKNOWN || control == U.V_UNPOWERED || control.toNumber() == 0)
				return false;
			
			var input:Value = inputs[0].getValue();
			U.level.time.deltas.push(new Delta(U.level.time.moment, this, input));
			U.level.memory[line.toNumber()] = input;
			lastMomentStored = U.level.time.moment;
			return true;
		}
		
		override public function finishUpdate():void {
			lastValue = null;
		}
		
		override public function revertTo(oldValue:Value):void {
			U.level.memory[controls[1].getValue().toNumber()] = oldValue;
			lastMomentStored = -1;
		}
	}

}