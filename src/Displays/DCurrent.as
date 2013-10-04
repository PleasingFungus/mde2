package Displays {
	import Components.Carrier;
	import Components.Link;
	import Components.Port;
	import org.flixel.*;
	import UI.FloatText;
	import Values.Value;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DCurrent extends FloatText {
		
		private var dWires:Vector.<DWire>;
		private var dModules:Vector.<DModule>;
		private var dLinks:Vector.<DLink>;
		private var lastMouse:FlxBasic;
		private var lastMoment:int;
		public function DCurrent(DWires:Vector.<DWire>, DModules:Vector.<DModule>, DLinks:Vector.<DLink>) {
			super(U.LABEL_FONT.configureFlxText(new FlxText( -1, -1, FlxG.width / 4, " "), 0xffffff));
			
			dWires = DWires;
			dModules = DModules;
			dLinks = DLinks;
		}
		
		override public function update():void {
			checkMouse();
			super.update();
		}
		
		private function checkMouse():void {
			var moused:FlxBasic;
			
			if (U.buttonManager.moused || U.state.findMousedModule()) {
				lastMouse = null;
				return;
			}
			
			for each (var dModule:DModule in dModules)
				if (dModule.module.exists && dModule.module.deployed)
					for each (var dPort:DPort in dModule.displayPorts)
						if (dPort.nearPoint(U.mouseFlxLoc, U.GRID_DIM / 2 / U.zoom)) {
							buildDisplay(moused = dPort, dPort.port);
							break;
						}
			
			if (!moused)
				for each (var dWire:DWire in dWires)
					if (dWire.wire.exists && dWire.wire.deployed && !dWire.outsideScreen() && dWire.overlapsPoint(U.mouseFlxLoc)) {
						buildDisplay(moused = dWire, dWire.wire);
						break;
					}
			
			if (!moused)
				for each (var dLink:DLink in dLinks)
					if (dLink.link.mouseable && !dLink.outsideScreen() && dLink.overlapsPoint(U.mouseFlxLoc)) {
						buildDisplay(moused = dLink, null, dLink.link);
						break;
					}
			
			lastMouse = moused;
		}
		
		private function buildDisplay(moused:FlxBasic, carrier:Carrier, link:Link = null):void {
			if (moused == lastMouse && lastMoment == U.state.time.moment)
				return;
			
			lastMoment = U.state.time.moment;
			
			if (carrier)
				text.text = getDisplayText(carrier);
			else if (link)
				text.text = getLinkDisplayText(link);
			else
				throw new Error("No link or carrier to display!");
		}
		
		protected function getDisplayText(carrier:Carrier):String {
			var displayText:String = "";
			
			if (carrier is Port) {
				displayText += "Port";
				var port:Port = carrier as Port;
				
				if (port.name)
					displayText += " '" + port.name+"'"
				displayText += ": "
				
				if (port.isOutput)
					displayText += port.getValue();
				
				if (port.isSource()) {
					if (U.state.level.delay && port.getLastChanged() > -1)
						displayText += " since " + port.getLastChanged();
					return displayText;
				}
			} else
				displayText += "Wire: ";
			
			var source:Port = carrier.getSource();
			if (source) {
				if (!port || !port.isOutput)
					displayText += source.getValue();
				if (source != carrier) {
					displayText += " from module " + source.dataParent.name; //should be physparent?
					if (source.name)
						displayText += "'s '" +source.name+"'";
				}
			} else
				displayText += "No source";
				
			if (port && port.source && !port.source.getValue().unknown && !port.stable)
				displayText += " (Ticks Until Stable: " + port.remainingDelay()+")";
			
			return displayText;
		}
		
		protected function getLinkDisplayText(link:Link):String {
			var source:Port = link.source;
			var dest:Port = link.destination;
			
			var value:Value = source.getValue();
			var out:String = source.getValue() + " from " + source.dataParent.name; //should be physparent?
			if (source.name)
				out += "'s " + source.name;
			out += " to " + dest.dataParent.name; //should be physparent?
			if (dest.name)
				out += "'s " + dest.name;
			if (!source.getValue().unknown && !dest.stable)
				out += " (Ticks until stable: " + dest.remainingDelay() + ")";
			return out;
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