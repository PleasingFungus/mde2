package  {
	import Components.Port;
	import Modules.Module;
	import Values.Delta;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Time {
		
		public var moment:int;
		public var deltas:Vector.<Delta>;
		public function Time() {
			init();
		}
		
		private function init():void {
			moment = 0;
			deltas = new Vector.<Delta>;
			if (U.state.initialMemory)
				U.state.memory = U.state.initialMemory.slice(); //clone
		}
		
		public function reset():void {
			init();
			for each (var module:Module in U.state.modules)
				module.initialize();
		}
		
		public function step():void {
			moment += 1;
			var module:Module, port:Port;
			
			for each (module in U.state.modules)
				for each (port in module.outputs)
					port.cacheValue();
			
			var change:Boolean = true;
			while (change) {
				change = false;
				for each (module in U.state.modules)
					change = change || module.update();
			}
			
			for each (module in U.state.modules)
				for each (port in module.outputs)
					port.clearCachedValue();
		}
		
		public function backstep():Boolean {
			if (!moment)
				return false;
			
			moment -= 1;
			var ll:int = deltas.length;
			while (deltas.length && deltas[deltas.length - 1].moment > moment)
				deltas.pop().revert();
			
			return true;
		}
		
		public function toString():String {
			return moment.toString();
		}
	}

}