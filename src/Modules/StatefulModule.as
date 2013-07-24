package Modules {
	import Values.IntegerValue;
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class StatefulModule extends Module {
		
		protected var initialValue:int;
		protected var value:Value;
		protected var lastMomentStored:int;
		public function StatefulModule(X:int, Y:int, Name:String, Category:ModuleCategory, numInputs:int, numOutputs:int, numControls:int, InitialValue:int) {
			initialValue = InitialValue;
			super(X, Y, Name, Category, numInputs, numOutputs, numControls);
		}
		
		override public function initialize():void {
			super.initialize();
			value = IntegerValue.fromNumber(initialValue);
			lastMomentStored = -1;
		}
		
		override public function updateState():Boolean {
			if (U.state.time.moment == lastMomentStored) return false; //can only store at most once per cycle
			
			var stored:Boolean = statefulUpdate();
			if (stored)
				lastMomentStored = U.state.time.moment;
			return stored;
		}
		
		protected function statefulUpdate():Boolean { return false; }
		
		override public function revertTo(oldValue:Value):void {
			value = oldValue;
			lastMomentStored = -1;
		}
		
		override public function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(initialValue);
			return values;
		}
	}

}