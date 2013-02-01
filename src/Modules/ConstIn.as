package Modules {
	import Values.NumericValue;
	import Values.Value;
	import Components.Port;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ConstIn extends Module {
		
		public var initialValue:int;
		public var value:NumericValue;
		public function ConstIn(X:int, Y:int, InitialValue:int = 0) {
			super(X, Y, "In", 0, 1, 0);
			
			initialValue = InitialValue;
			
			configuration = new Configuration(new Range( -16, 15), function setValue(newValue:int):void {
				initialValue = newValue;
				initialize();
			});
		}
		
		override public function renderName():String {
			return name + "\n\n" + value;
		}
		
		override public function drive(port:Port):Value {
			return value;
		}
		
		override protected function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(initialValue);
			return values;
		}
		
		override public function initialize():void {
			value = new NumericValue(initialValue);
		}
	}

}