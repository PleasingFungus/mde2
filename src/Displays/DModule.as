package Displays {
	import Components.Port;
	import Components.Wire;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import Layouts.InternalDWire;
	import Layouts.InternalWire;
	import Layouts.PortLayout;
	import Layouts.Nodes.InternalNode;
	import Modules.Module;
	import org.flixel.*;
	import UI.FontTuple;
	import UI.HighlightFormat;
	import UI.Tooltip;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DModule extends FlxSprite {
		
		public var module:Module;
		public var displayPorts:Vector.<DPort>;
		public var displayNodes:Vector.<DNode>;
		public var displayConnections:Vector.<InternalDWire>;
		public var selected:Boolean;
		private var nameText:FlxText;
		private var detailsText:FlxText;
		private var abbrevText:FlxText;
		public function DModule(module:Module) {
			super(module.x, module.y);
			this.module = module;
			refresh();
		}
		
		public function refresh():void {
			makeGraphic(module.layout.dim.x * U.GRID_DIM,
						module.layout.dim.y * U.GRID_DIM,
						0xffffffff, true);
			
			detailsText = new FlxText( -1, -1, width + U.GRID_DIM / 2, getDetails());
			U.MODULE_FONT_CLOSE.configureFlxText(detailsText, 0x0, 'center');
			detailsText.scrollFactor = scrollFactor; //object
			
			if (module.abbrev) {
				abbrevText = new FlxText( -1, -1, width + U.GRID_DIM / 2, module.abbrev);
				U.NODE_FONT.configureFlxText(abbrevText, 0x0, 'center');
				abbrevText.scrollFactor = scrollFactor;
			}
			
			displayPorts = new Vector.<DPort>;
			for each (var layout:PortLayout in module.layout.ports)
				displayPorts.push(makePort(layout));
			
			displayNodes = new Vector.<DNode>;
			displayConnections = new Vector.<InternalDWire>;
			if (module.internalLayout) {
				for each (var node:InternalNode in module.internalLayout.nodes) {
					displayNodes.push(new DNode(node));
					for each (var connection:InternalWire in node.internalWires)
						displayConnections.push(new InternalDWire(connection));
				}
				
				nameText = new FlxText( -1, -1, width, module.name);
				U.NODE_FONT.configureFlxText(nameText, 0x0, 'center');
				nameText.scrollFactor = scrollFactor;
			}
			
			updatePosition();
		}
		
		private function getDetails():String {
			var displayName:String = module.renderDetails();
			if (U.state.level.delay && module.delay)
				displayName += "\n\nD" + module.delay;
			return displayName;
		}
		
		private function makePort(layout:PortLayout):DPort {
			var displayPort:DPort = new DPort(layout);
			displayPort.scrollFactor = scrollFactor; //object
			return displayPort;
		}
		
		override public function update():void {
			super.update();
			
			visible = module.exists;
			if (!module.exists)
				return;
			
			updatePosition();
			visible = !outsideScreen();
			if (!visible)
				return;
			
			getColor();
			
			for each (var displayNode:DNode in displayNodes)
				displayNode.node.update();
			
			for each (var dWire:DWire in displayConnections)
				dWire.update();
			
		}
		
		protected function outsideScreen():Boolean {
			var sr:Rectangle = U.screenRect();
			return ((x + width + U.GRID_DIM < sr.x) ||
					(y + height + U.GRID_DIM < sr.y) ||
					(x - U.GRID_DIM >= sr.right) ||
					(y - U.GRID_DIM >= sr.bottom));
		}
		
		private function getColor():void {
			var moduleColor:uint;
			
			if (selected)
				color = U.SELECTION_COLOR;
			else if (module.FIXED)
				color = 0xff808080;
			else if (module.validPosition)
				color = 0xff7070a0;
			else
				color = 0xffa07070;
		}
		
		private var lastLoc:Point;
		protected function updatePosition():void {
			if (lastLoc && module.equals(lastLoc))
				return;
			
			var baseX:int = module.x * U.GRID_DIM;
			var baseY:int = module.y * U.GRID_DIM;
			
			x = baseX + module.layout.offset.x * U.GRID_DIM;
			y = baseY + module.layout.offset.y * U.GRID_DIM;
			
			for each (var displayPort:DPort in displayPorts)
				displayPort.updatePosition(baseX, baseY);
			
			for each (var displayNode:DNode in displayNodes)
				displayNode.node.updatePosition();
			
			detailsText.x = x;
			detailsText.y = y + (height - detailsText.height) / 2;
			
			if (nameText) {
				nameText.x = x;
				nameText.y = y + height - (nameText.height + 2);
			}
			
			if (abbrevText) {
				abbrevText.x = x;
				abbrevText.y = y + (height - detailsText.height) / 2;
			}
			
			lastLoc = module.clone();
		}
		
		public function descriptionAt(fp:FlxPoint):HighlightFormat {
			for each (var displayNode:DNode in displayNodes)
				if (displayNode.overlapsPoint(fp))
					return HighlightFormat.plain(displayNode.node.getLabel());
			
			var format:HighlightFormat = module.getHighlitDescription();
			if (format) {
				format.formatString = module.name + ": " + format.formatString;
				return format;
			}
			
			var out:String = module.name;
			if (module.getDescription())
				out += ": " + module.getFullDescription();
			return HighlightFormat.plain(out);
		}
		
		override public function draw():void {
			super.draw();
			
			if (module.internalLayout && U.zoom >= 0.5) {	
				for each (var displayConnection:DWire in displayConnections)
					if (displayConnection.visible)
						displayConnection.draw();
				for each (var displayNode:DNode in displayNodes)
					displayNode.draw();
				nameText.draw();
			}
			else if (U.zoom >= 0.5) {
				detailsText.text = getDetails();
				detailsText.draw();
			}
			
			for each (var displayPort:DPort in displayPorts)
				displayPort.draw();
		}
	}

}