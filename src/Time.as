package  {
	import Modules.Module;
	import Values.Delta;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Time {
		
		public var moment:int;
		public var deltas:Vector.<Delta>;
		public var updating:Boolean;
		public function Time() {
			init();
		}
		
		private function init():void {
			moment = 0;
			deltas = new Vector.<Delta>;
			if (U.state.level.goal.dynamicallyTested)
				U.state.memory = U.state.level.goal.genMem(0.5);
		}
		
		public function reset():void {
			init();
			for each (var module:Module in U.state.modules)
				module.initialize();
		}
		
		public function step():void {
			moment += 1;
			updating = true;
			var module:Module;
			
			var change:Boolean = true;
			while (change) {
				change = false;
				for each (module in U.state.modules)
					change = change || module.update();
			}
			
			for each (module in U.state.modules)
				module.finishUpdate();
			updating = false;
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