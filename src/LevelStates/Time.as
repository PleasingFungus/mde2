package LevelStates {
	import Components.Port;
	import Layouts.PortLayout;
	import Modules.Module;
	import Values.Delta;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Time {
		
		public var moment:int;
		public var deltas:Vector.<Delta>;
		public var clockPeriod:int = 1;
		public function Time() {
			init();
		}
		
		private function init():void {
			moment = 0;
			deltas = new Vector.<Delta>;
			if (U.state.initialMemory)
				U.state.memory = U.state.initialMemory.slice(); //clone
			U.state.calculateModuleState(); //probably not necessary, but makes me happier
		}
		
		public function reset():void {
			init();
			for each (var module:Module in U.state.modules)
				module.initialize();
			U.state.calculateModuleState();
		}
		
		public function step():void {
			for each (var module:Module in U.state.modules)
				module.updateState();
			
			moment += 1;
			
			U.state.calculateModuleState();
		}
		
		public function backstep():Boolean {
			if (!moment)
				return false;
			
			moment -= 1;
			var ll:int = deltas.length;
			while (deltas.length && deltas[deltas.length - 1].moment >= moment)
				deltas.pop().revert();
			
			U.state.calculateModuleState();
			
			return true;
		}
		
		public function toString():String {
			return moment.toString();
		}
	}

}