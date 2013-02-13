package Displays {
	import Components.Carrier;
	import Components.Port;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DCurrent extends FlxGroup {
		
		private var dWires:Vector.<DWire>;
		private var dModules:Vector.<DModule>;
		private var text:FlxText;
		private var bg:FlxSprite;
		private var lastMouse:FlxBasic;
		private var lastCarrier:Carrier;
		public function DCurrent(DWires:Vector.<DWire>, DModules:Vector.<DModule>) {
			super()
			
			dWires = DWires;
			dModules = DModules;
			
			add(text = new FlxText( -1, -1, FlxG.width / 4, " ").setFormat(U.FONT, U.FONT_SIZE, 0xff000000));
			//text.scrollFactor.x = text.scrollFactor.y = 0;
		}
		
		override public function update():void {
			checkMouse();
			super.update();
		}
		
		private function checkMouse():void {
			var moused:FlxBasic, carrier:Carrier;
			
			for each (var dModule:DModule in dModules)
				for each (var dPort:DPort in dModule.displayPorts)
					if (dPort.nearPoint(FlxG.mouse, 3)) {
						buildDisplay(moused = dPort, carrier = dPort.port);
						break;
					}
			
			if (!moused)
				for each (var dWire:DWire in dWires)
					if (dWire.overlapsPoint(FlxG.mouse)) {
						buildDisplay(moused = dWire, carrier = dWire.wire);
						break;
					}
			
			lastMouse = moused;
			lastCarrier = carrier;
		}
		
		private function buildDisplay(moused:FlxBasic, carrier:Carrier):void {
			if (moused == lastMouse)
				return;
			
			var displayText:String = "";
			
			if (carrier is Port) {
				displayText += "Port";
				if ((carrier as Port).name)
					displayText += " "+(carrier as Port).name
				displayText += ": ";
			} else
				displayText += "Wire: ";
			
			var source:Port = carrier.getSource();
			if (source) {
				displayText += source.getValue();
				if (source.name)
					displayText += " from " + source.name;
			} else
				displayText += "No source";
			
			text.text = displayText;
			
			//TODO: set up bg
		}
		
		override public function draw():void {
			if (!lastMouse)
				return;
			
			position();
			super.draw();
		}
		
		private function position():void {
			text.x = FlxG.mouse.x - FlxG.camera.scroll.x + PAD;
			text.y = FlxG.mouse.y - FlxG.camera.scroll.y + PAD;
			
			if (text.x + text.textWidth > FlxG.width || text.y + text.height > FlxG.height) {
				text.x -= text.textWidth + PAD;
				text.y -= text.height + PAD;
			}
		}
		
		private var PAD:int = 20;
	}

}