package Modules {
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
		protected var lastMomentStored:int;
		public function Regfile(X:int, Y:int) {
			super(X, Y, "Regfile", 1, 2, 4);
			configuration = new Configuration(new Range(4, 32, 8), function setValue(newValue:int):void {
				width = newValue;
			});
			width = configuration.valueRange.initial;
			delay = 7;
		}
		
		override public function initialize():void {
			values = new Vector.<Value>;
			for (var i:int = 0; i < width; i++)
				values.push(new NumericValue(0));
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
				return U.V_UNKNOWN;
			
			return values[regIndex];
		}
		
		override public function update():Boolean {
			if (U.level.time.moment == lastMomentStored) return false; //can only store at most once per cycle
			
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
			U.level.time.deltas.push(new Delta(U.level.time.moment, this, values[selectIndex]));
			values[selectIndex] = input;
			lastMomentStored = U.level.time.moment;
			return true;
		}
		
		override public function revertTo(oldValue:Value):void {
			values[controls[2].getValue().toNumber()] = oldValue;
			lastMomentStored = -1;
		}
		
		override protected function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(width);
			return values;
		}
	}

}