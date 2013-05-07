package Displays {
	import Modules.SysDelayClock;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DClockModule extends DModule {
		
		public var clockModule:SysDelayClock;
		private var clock:Clock;
		public function DClockModule(module:SysDelayClock) {
			clockModule = module;
			clock = new Clock( -1, -1, 0.5);
			super(module);
		}
		
		override public function update():void {
			super.update();
			updateClock();
		}
		
		private function updateClock():void {
			clock.fraction = clockModule.edgeLength / U.state.time.clockPeriod;
			clock.handFraction = ((U.state.time.moment % U.state.time.clockPeriod) + 0.5) / U.state.time.clockPeriod;
		}
		
		override public function draw():void {
			super.draw();
			clock.x = displayNodes[0].x - displayNodes[0].offset.x;
			clock.y = displayNodes[0].y - displayNodes[0].offset.y;
			clock.draw();
			displayNodes[0].drawLabel(); //?
		}
	}

}