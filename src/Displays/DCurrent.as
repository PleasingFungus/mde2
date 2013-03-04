package Displays {
	import Components.Carrier;
	import Components.Port;
	import org.flixel.*;
	import UI.FloatText;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DCurrent extends FloatText {
		
		private var dWires:Vector.<DWire>;
		private var dModules:Vector.<DModule>;
		private var lastMouse:FlxBasic;
		private var lastCarrier:Carrier;
		private var lastMoment:int;
		public function DCurrent(DWires:Vector.<DWire>, DModules:Vector.<DModule>) {
			super(U.LABEL_FONT.configureFlxText(new FlxText( -1, -1, FlxG.width / 4, " "), 0xffffff));
			
			dWires = DWires;
			dModules = DModules;
		}
		
		override public function update():void {
			checkMouse();
			super.update();
		}
		
		private function checkMouse():void {
			var moused:FlxBasic, carrier:Carrier;
			
			if (U.buttonManager.moused) {
				lastMouse = null;
				return;
			}
			
			for each (var dModule:DModule in dModules)
				for each (var dPort:DPort in dModule.displayPorts)
					if (dPort.nearPoint(U.mouseFlxLoc, U.GRID_DIM / 2 / U.state.zoom)) {
						buildDisplay(moused = dPort, carrier = dPort.port);
						break;
					}
			
			if (!moused)
				for each (var dWire:DWire in dWires)
					if (dWire.overlapsPoint(U.mouseFlxLoc)) {
						buildDisplay(moused = dWire, carrier = dWire.wire);
						break;
					}
			
			lastMouse = moused;
			lastCarrier = carrier;
		}
		
		private function buildDisplay(moused:FlxBasic, carrier:Carrier):void {
			if (moused == lastMouse && lastMoment == U.state.time.moment)
				return;
			
			lastMoment = U.state.time.moment;
			
			text.text = getDisplayText(carrier);
		}
		
		protected function getDisplayText(carrier:Carrier):String {
			var displayText:String = "";
			
			if (carrier is Port) {
				displayText += "Port";
				var port:Port = carrier as Port;
				
				if (port.name)
					displayText += " "+port.name
				displayText += ": " + port.getValue();
				
				if (port.isSource()) {
					if (port.getLastChanged() > -1)
						displayText += " since " + port.getLastChanged();
					return displayText;
				}
				
				if (port.source && !port.source.getValue().unknown && !port.stable)
					displayText += " D" + (port.remainingDelay() - 1);
				displayText += " <- ";
			} else
				displayText += "Wire: ";
			
			var source:Port = carrier.getSource();
			if (source) {
				displayText += source.getValue();
				if (source != carrier && source.name)
					displayText += " from " + source.name;
			} else
				displayText += "No source";
			
			return displayText;
		}
		
		override public function draw():void {
			if (!lastMouse)
				return;
			
			position();
			super.draw();
		}
		
		private function position():void {
			x = FlxG.mouse.x - FlxG.camera.scroll.x + PAD;
			y = FlxG.mouse.y - FlxG.camera.scroll.y + PAD;
			
			if (x + width > FlxG.width || y + height > FlxG.height) {
				x -= width + PAD;
				y -= height + PAD;
			}
		}
		
		private var PAD:int = 20;
	}

}