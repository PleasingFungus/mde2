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
			super(X, Y, "In", Module.CAT_MISC, 0, 1, 0);
			configuration = new Configuration(new Range( -16, 15, InitialValue));
			setByConfig();
		}
		
		override public function setByConfig():void {
			initialValue = configuration.value;
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