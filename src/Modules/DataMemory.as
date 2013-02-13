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
			super(X, Y, "D-Mem", 1, 1, 2);
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
			if (U.state.time.updating && lastValue)
				return lastValue;
			
			var line:Value = controls[0].getValue();
			if (line.unpowered || line.unknown) return line;
			
			var index:int = line.toNumber();
			if (index < 0 || index >= U.state.memory.length)
				return U.V_UNKNOWN;
			
			var memoryValue:Value = U.state.memory[index];
			if (!memoryValue)
				return U.V_UNKNOWN;
			
			return NumericValue.fromValue(memoryValue);
		}
		
		protected function get data():NumericValue { 
			var line:Value = controls[0].getValue();
			if (line.unpowered || line.unknown) return null;
			
			var index:int = line.toNumber();
			if (index < 0 || index >= U.state.memory.length)
				return null;
			
			var memoryValue:Value = U.state.memory[index];
			if (!memoryValue)
				return null;
			
			return NumericValue.fromValue(memoryValue);
		}
		
		override public function update():Boolean {
			if (U.state.time.moment == lastMomentStored) return false; //can only store at most once per cycle
			
			lastValue = drive(null);
			
			var line:Value = controls[0].getValue();
			if (line.unpowered || line.unknown || line.toNumber() < 0 || line.toNumber() > U.state.memory.length) return false;
			
			var control:Value = controls[1].getValue();
			if (control == U.V_UNKNOWN || control == U.V_UNPOWERED || control.toNumber() == 0)
				return false;
			
			var input:Value = inputs[0].getValue();
			U.state.time.deltas.push(new Delta(U.state.time.moment, this, input));
			U.state.memory[line.toNumber()] = input;
			lastMomentStored = U.state.time.moment;
			return true;
		}
		
		override public function finishUpdate():void {
			lastValue = null;
		}
		
		override public function revertTo(oldValue:Value):void {
			U.state.memory[controls[1].getValue().toNumber()] = oldValue;
			lastMomentStored = -1;
		}
	}

}