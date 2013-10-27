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
	import UI.ColorText;
	import UI.FontTuple;
	import UI.GraphicButton;
	import UI.HighlightFormat;
	
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
		protected var nameText:FlxText;
		protected var detailsText:FlxText;
		protected var symbol:FlxSprite;
		protected var largeSymbol:FlxSprite;
		protected var editButton:EditButton;
		public function DModule(module:Module) {
			super(module.x, module.y);
			this.module = module;
			if (module.exists)
				refresh();
		}
		
		public function refresh():void {
			makeGraphic(module.layout.dim.x * U.GRID_DIM,
						module.layout.dim.y * U.GRID_DIM,
						0xffffffff, true);
			
			displayPorts = new Vector.<DPort>;
			for each (var layout:PortLayout in module.layout.ports)
				displayPorts.push(makePort(layout));
			
			displayNodes = new Vector.<DNode>;
			displayConnections = new Vector.<InternalDWire>;
			if (module.internalLayout) {
				for each (var node:InternalNode in module.internalLayout.nodes) {
					displayNodes.push(node.generateDisplay());
					for each (var connection:InternalWire in node.internalWires)
						displayConnections.push(new InternalDWire(connection));
				}
				
				symbol = module.generateSymbolDisplay();
				largeSymbol = module.generateLargeSymbolDisplay();
				if (!symbol) {
					nameText = new FlxText( -1, -1, width, module.name);
					U.MODULE_LABEL_FONT.configureFlxText(nameText, 0x0, 'center');
					nameText.scrollFactor = scrollFactor;
				}
			} else {			
				detailsText = new FlxText( -1, -1, width + U.GRID_DIM / 2, getDetails());
				U.MODULE_FONT_CLOSE.configureFlxText(detailsText, 0x0, 'center');
				detailsText.scrollFactor = scrollFactor; //object
			}
			
			if (module.getConfiguration() && module.configurableInPlace && !module.FIXED && U.state.level.canEditModules)
				editButton = new EditButton(this);
			
			getColor();
			updatePosition();
		}
		
		protected function getDetails():String {
			var displayName:String = module.renderDetails();
			if (U.state && U.state.level.delay && module.delay)
				displayName += "\n\nD" + module.delay;
			return displayName;
		}
		
		protected function makePort(layout:PortLayout):DPort {
			var displayPort:DPort = new DPort(layout);
			displayPort.scrollFactor = scrollFactor; //object
			return displayPort;
		}
		
		override public function update():void {
			super.update();
			
			visible = module.exists;
			if (!module.exists)
				return;
			
			if (!displayPorts) //first-time update with module existing
				refresh(); 
			else if (module.internalLayout && module.internalLayout.nodes.length &&
					 module.internalLayout.nodes[0] != displayNodes[0].node) //layout regenerated
				refresh();
			
			if (!lastLoc || !module.equals(lastLoc))
				updatePosition();
			visible = !outsideScreen();
			if (!visible)
				return;
			
			getColor();
			
			for each (var displayNode:DNode in displayNodes)
				displayNode.node.update();
			
			for each (var dWire:DWire in displayConnections)
				dWire.update();
			
			if (editButton) {
				editButton.exists = module.deployed && U.state.editEnabled;
				if (editButton.active && editButton.exists)
					editButton.update();
			}
		}
		
		protected function outsideScreen():Boolean {
			var sr:Rectangle = U.screenRect();
			return ((x + width + U.GRID_DIM < sr.x) ||
					(y + height + U.GRID_DIM < sr.y) ||
					(x - U.GRID_DIM >= sr.right) ||
					(y - U.GRID_DIM >= sr.bottom));
		}
		
		protected function getColor():void {
			var moduleColor:uint;
			
			if (selected)
				color = U.SELECTION_COLOR;
			else if (module.FIXED)
				color = MODULE_GRAY;
			else if (module.validPosition)
				color = MODULE_BLUE;
			else
				color = MODULE_RED;
		}
		
		private var lastLoc:Point;
		protected function updatePosition():void {
			var baseX:int = module.x * U.GRID_DIM;
			var baseY:int = module.y * U.GRID_DIM;
			
			x = baseX + module.layout.offset.x * U.GRID_DIM;
			y = baseY + module.layout.offset.y * U.GRID_DIM;
			
			for each (var displayPort:DPort in displayPorts)
				displayPort.updatePosition(baseX, baseY);
			
			for each (var displayNode:DNode in displayNodes)
				displayNode.updatePosition();
			
			
			if (symbol) {
				symbol.x = x + width / 2 - symbol.width / 2;
				symbol.y = y + height - symbol.height - 4;
				if (largeSymbol) {
					largeSymbol.x = x + width / 2 - largeSymbol.width / 2;
					largeSymbol.y = y + height / 2 - largeSymbol.height / 2;
				}
			} else if (nameText) {
				nameText.x = x;
				nameText.y = y + height - (nameText.height + 2);
			} else {			
				detailsText.x = x;
				detailsText.y = y + (height - detailsText.height) / 2;
			}
			
			if (editButton) {
				editButton.X = x + width / 2 - editButton.fullWidth / 2;
				editButton.Y = y + 5;
			}
			
			lastLoc = module.clone();
		}
		
		public function descriptionAt(fp:FlxPoint):HighlightFormat {
			if (U.zoom >= 0.5) {
				for each (var displayNode:DNode in displayNodes)
					if (displayNode.overlapsPoint(fp))
						return HighlightFormat.plain(displayNode.node.getLabel());
				
				if (editButton && editButton.moused)
					return new HighlightFormat("{}", ColorText.singleVec(new ColorText(U.CONFIG_COLOR, "Edit")));
			}
			
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
			if (!displayPorts) //not initialized
				return;
			
			for each (var displayPort:DPort in displayPorts)
				displayPort.draw();
			
			super.draw();
			
			drawInternals();
			drawLabel();
			if (editButton && editButton.visible && editButton.exists)
				editButton.draw();
		}
		
		protected function drawInternals():void {
			if (!module.internalLayout || U.zoom < 0.5)
				return;
			for each (var displayConnection:DWire in displayConnections)
				if (displayConnection.visible)
					displayConnection.draw();
			for each (var displayNode:DNode in displayNodes)
				displayNode.draw();
		}
		
		protected function drawLabel():void {
			if (module.internalLayout) {	
				if (U.zoom >= 0.5) {
					if (symbol)
						symbol.draw();
					else
						nameText.draw();
				} else if (largeSymbol)
					largeSymbol.draw();
			} else if (U.zoom >= 0.5) {
				detailsText.text = getDetails();
				detailsText.draw();
			}
		}
		
		public function drawNodeText():void {
			for each (var node:DNode in displayNodes)
				if (node.visible && node.exists)
					node.drawScreenspaceText();
		}
		
		protected const MODULE_BLUE:uint = 0xff7070a0;
		protected const MODULE_RED:uint = 0xffa07070;
		protected const MODULE_GRAY:uint = 0xff808080;
	}

}