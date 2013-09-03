package Displays {
	import Layouts.Nodes.InternalNode;
	import Modules.Clockable;
	import Modules.Module;
	import Modules.SysDelayClock;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DClockModule extends DModule {
		
		public var clockModule:Clockable;
		private var clock:Clock;
		public function DClockModule(module:Module, clockable:Clockable) {
			clockModule = clockable;
			clock = new Clock( -1, -1, 0.5);
			super(module);
		}
		
		override public function update():void {
			super.update();
			updateClock();
		}
		
		private function updateClock():void {
			clock.fraction = clockModule.getClockFraction();
			clock.handFraction = ((U.state.time.moment % U.state.time.clockPeriod) + 0.5) / U.state.time.clockPeriod;
		}
		
		override protected function drawInternals():void {
			super.drawInternals();
			if (U.zoom >= 0.5) {
				var displayNode:DNode = findClockNode();
				
				clock.x = displayNode.x - displayNode.offset.x;
				clock.y = displayNode.y - displayNode.offset.y;
				clock.draw();
				
				var color:uint = clock.on ? 0x0 : 0xffffff;
				var shadow:uint = clock.on ? 0xffffff : 0x1;
				if (displayNode.label.color != color || displayNode.label.shadow != shadow)
					displayNode.label.setFormat(displayNode.label.font, displayNode.label.size, color, displayNode.label.alignment, shadow);
				if (!U.UPPER_NODE_TEXT || U.zoom >= 1)
					displayNode.drawLabel();
			}
		}
		
		private function findClockNode():DNode {
			var node:InternalNode = clockModule.getClockNode();
			for each (var dNode:DNode in displayNodes)
				if (dNode.node == node)
					return dNode;
			return null;
		}
		
		override protected function drawLabel():void {
			if (U.zoom < 0.5)
				largeSymbol.draw();
		}
	}

}