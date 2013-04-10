package Modules {
	import Values.BooleanValue;
	import Values.IndexedValue;
	import Values.Value;
	import Values.Delta;
	import Components.Port;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Edge extends Module {
		
		private var edgeLength:int;
		private var lastValue:Value;
		private var lastValueSeen:int;
		private var lastMomentStored:int;
		public function Edge(X:int, Y:int, EdgeLength:int = 2) {
			super(X, Y, "Edge", Module.CAT_TIME, 1, 1, 0);
			configuration = new Configuration(new Range(1, 32, EdgeLength));
			setByConfig();
		}
		
		override public function setByConfig():void {
			edgeLength = configuration.value;
		}
		
		override public function renderDetails():String {
			return "EDGE-"+edgeLength;
		}
		
		override public function getDescription():String {
			return "After recieving a non-"+BooleanValue.FALSE+" input, outputs that value for the next " + configuration.value + " ticks.";
		}
		
		override public function initialize():void {
			super.initialize();
			lastValue = null;
			lastValueSeen = -1;
		}
		
		override public function updateState():Boolean {
			if (U.state.time.moment == lastMomentStored) return false; //can only store at most once per cycle
			
			var input:Value = inputs[0].getValue();
			if (input.unknown || input.unpowered || !(BooleanValue.fromValue(input).true_))
				return false;
			
			U.state.time.deltas.push(new Delta(U.state.time.moment, this, new IndexedValue(lastValue, lastValueSeen)));
			lastValue = input;
			lastValueSeen = lastMomentStored = U.state.time.moment;
			return true;
		}
		
		override public function drive(port:Port):Value {
			if (lastValue && U.state.time.moment - lastValueSeen < edgeLength)
				return lastValue;
			return inputs[0].getValue();
		}
		
		
		override public function revertTo(oldValue:Value):void {
			var indexedValue:IndexedValue = oldValue as IndexedValue;
			lastValue = indexedValue.subValue;
			lastValueSeen = indexedValue.index;
			lastMomentStored = -1;
		}
		
		override public function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(edgeLength);
			return values;
		}
	}

}