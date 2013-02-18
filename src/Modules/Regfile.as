package Modules {
	import Values.IndexedValue;
	import Values.Value;
	import Components.Port;
	import Values.NumericValue;
	import Values.Delta;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Regfile extends Module {
		
		public var width:int;
		public var values:Vector.<Value>;
		protected var lastMomentStored:int = -1;
		public function Regfile(X:int, Y:int, Width:int = 8) {
			super(X, Y, "Regfile", Module.CAT_STORAGE, 1, 2, 4);
			
			inputs[0].name = "Write v";
			controls[0].name = "Out Reg i 1";
			controls[1].name = "Out Reg i 2";
			controls[2].name = "Write Reg i";
			controls[3].name = "Write";
			outputs[0].name = "Out Reg 1";
			outputs[1].name = "Out Reg 2";
			
			configuration = new Configuration(new Range(4, 32, Width));
			width = Width;
			configurableInPlace = false;
			delay = Math.ceil(Math.log(width) / Math.log(2)) * 2;
		}
		
		override public function initialize():void {
			super.initialize();
			values = new Vector.<Value>;
			for (var i:int = 0; i < width; i++)
				values.push(new NumericValue(0));
			lastMomentStored = -1;
		}
		
		override public function renderName():String {
			return "Registers" +"\n\n" + values;
		}
		
		override public function drive(port:Port):Value {
			var portIndex:int = outputs.indexOf(port);
			var selectValue:Value = controls[portIndex].getValue();
			if (selectValue.unknown)
				return U.V_UNKNOWN;
			if (selectValue.unpowered)
				return U.V_UNPOWERED;
			
			var regIndex:int = selectValue.toNumber();
			if (regIndex < 0 || regIndex >= width)
				return U.V_UNPOWERED;
			
			return values[regIndex];
		}
		
		override public function updateState():Boolean {
			if (U.state.time.moment == lastMomentStored) return false; //can only store at most once per cycle
			
			var control:Value = controls[3].getValue();
			if (control.unknown || control.unpowered || control.toNumber() == 0)
				return false;
			
			var selectControl:Value = controls[2].getValue();
			if (selectControl.unknown || selectControl.unpowered)
				return false;
			
			var selectIndex:int = selectControl.toNumber();
			if (selectIndex < 0 || selectIndex >= width)
				return false;
			
			var input:Value = inputs[0].getValue();
			U.state.time.deltas.push(new Delta(U.state.time.moment, this,
											   new IndexedValue(values[selectIndex], selectIndex)));
			values[selectIndex] = input;
			lastMomentStored = U.state.time.moment;
			return true;
		}
		
		override public function revertTo(oldValue:Value):void {
			var indexedOldValue:IndexedValue = oldValue as IndexedValue;
			values[indexedOldValue.index] = indexedOldValue.subValue;
			lastMomentStored = -1;
		}
		
		override protected function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(width);
			return values;
		}
	}

}