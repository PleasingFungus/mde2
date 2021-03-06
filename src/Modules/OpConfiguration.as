package Modules {
	import Values.IntegerValue;
	import Values.OpcodeValue;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class OpConfiguration extends Configuration {
		
		public var opValue:OpcodeValue;
		public function OpConfiguration() {
			if (U.state && U.state.level.expectedOps && U.state.level.expectedOps.length) {
				var min:OpcodeValue, max:OpcodeValue;
				min = max = U.state.level.expectedOps[0];
				for each (var op:OpcodeValue in U.state.level.expectedOps.slice(1)) {
					var numeric:int = op.toNumber();
					if (numeric < min.toNumber())
						min = op;
					if (numeric > max.toNumber())
						max = op;
				}
				
				var range:Range = new OpRange(min, max);
				opValue = min;
			} else
				range = new Range;
			
			super(range);
		}
		
		override public function setValue(v:int):int {
			var closest:OpcodeValue = U.state.level.expectedOps[0];
			for each (var op:OpcodeValue in U.state.level.expectedOps)
				if (Math.abs(op.toNumber() - v) < Math.abs(closest.toNumber() - v))
					closest = op;
			opValue = closest;
			return value = opValue.toNumber();
		}
		
		override public function increment():int {
			for (var newValue:int = value + 1; newValue < OpcodeValue.OPS.length; newValue++) {
				var op:OpcodeValue = OpcodeValue.fromValue(new IntegerValue(newValue));
				if (op != OpcodeValue.OP_NOOP && U.state.level.expectedOps.indexOf(op) != -1)
					break;
			}
			
			if (newValue >= OpcodeValue.OPS.length)
				return value;
			
			opValue = op;
			return value = newValue;
		}
		
		override public function decrement():int {
			for (var newValue:int = value - 1; newValue; newValue--) {
				var op:OpcodeValue = OpcodeValue.fromValue(new IntegerValue(newValue));
				if (op != OpcodeValue.OP_NOOP && U.state.level.expectedOps.indexOf(op) != -1)
					break;
			}
			
			if (!newValue)
				return value;
			
			opValue = op;
			return value = newValue;
		}
	}

}