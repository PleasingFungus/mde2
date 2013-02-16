package Modules {
	import Values.IndexedValue;
	import Values.NumericValue;
	import Values.Value;
	import Values.Delta;
	import Components.Port;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DataMemory extends Module {
		
		protected var lastMomentStored:int = -1;
		public function DataMemory(X:int, Y:int) {
			super(X, Y, "D-Mem", 1, 1, 2);
			delay = 10;
		}
		
		override public function initialize():void {
			super.initialize();
			lastMomentStored = -1;
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
			var line:Value = controls[0].getValue();
			if (line.unpowered || line.unknown) return line;
			
			var index:int = line.toNumber();
			if (index < 0 || index >= U.state.memory.length)
				return U.V_UNPOWERED;
			
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
		
		override public function updateState():Boolean {
			if (U.state.time.moment == lastMomentStored)
				return false; //can only store at most once per cycle
			
			var line:Value = controls[0].getValue();
			if (line.unpowered || line.unknown || line.toNumber() < 0 || line.toNumber() > U.state.memory.length) return false;
			
			var control:Value = controls[1].getValue();
			if (control == U.V_UNKNOWN || control == U.V_UNPOWERED || control.toNumber() == 0)
				return false;
			
			var input:Value = inputs[0].getValue();
			U.state.time.deltas.push(new Delta(U.state.time.moment, this,
											   new IndexedValue(U.state.memory[line.toNumber()], line.toNumber())));
			U.state.memory[line.toNumber()] = input;
			lastMomentStored = U.state.time.moment;
			return true;
		}
		
		override public function revertTo(oldValue:Value):void {
			var indexedOldValue:IndexedValue = oldValue as IndexedValue;
			U.state.memory[indexedOldValue.index] = indexedOldValue.subValue;
			lastMomentStored = -1;
		}
	}

}