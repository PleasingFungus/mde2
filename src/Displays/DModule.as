package Displays {
	import Components.Port;
	import Components.Wire;
	import Layouts.InternalDWire;
	import Layouts.InternalNode;
	import Layouts.InternalWire;
	import Layouts.PortLayout;
	import Modules.Module;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DModule extends FlxSprite {
		
		public var module:Module;
		public var displayPorts:Vector.<DPort>;
		public var displayNodes:Vector.<DNode>;
		public var displayConnections:Vector.<DWire>;
		private var nameText:FlxText;
		private var locked:Boolean;
		private var wasValid:Boolean;
		public function DModule(module:Module) {
			super(module.x, module.y);
			this.module = module;
			refresh();
		}
		
		public function refresh():void {
			wasValid = module.validPosition;
			var moduleColor:uint;
			if (module.FIXED)
				moduleColor = 0xff808080;
			else if (wasValid)
				moduleColor = 0xff7070a0;
			else
				moduleColor = 0xffa07070;
			
			makeGraphic(module.layout.dim.x * U.GRID_DIM,
						module.layout.dim.y * U.GRID_DIM,
						moduleColor, true);
			
			nameText = new FlxText( -1, -1, width + U.GRID_DIM / 2, getName());
			nameText.setFormat(U.FONT, U.FONT_SIZE, 0x0, 'center');
			nameText.scrollFactor = scrollFactor; //object
			
			displayPorts = new Vector.<DPort>;
			for each (var layout:PortLayout in module.layout.ports)
				displayPorts.push(makePort(layout));
			
			displayNodes = new Vector.<DNode>;
			displayConnections = new Vector.<DWire>;
			if (module.internalLayout)
				for each (var node:InternalNode in module.internalLayout.nodes) {
					displayNodes.push(new DNode(node));
					for each (var connection:InternalWire in node.internalWires)
						displayConnections.push(new InternalDWire(connection));
				}
		}
		
		private function getName():String {
			var displayName:String = module.renderName();
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
			
			if (module.dirty || (wasValid != module.validPosition))
				refresh();
			
			updatePosition();
			
			if (U.SCALE_FONTS_WITH_ZOOM) {
				if (nameText.font != U.FONT || nameText.size != U.FONT_SIZE) {
					nameText = new FlxText(nameText.x, nameText.y, nameText.width * U.FONT_SIZE / nameText.size, nameText.text);
					nameText.setFormat(U.FONT, U.FONT_SIZE, 0x0, nameText.alignment, nameText.shadow);
				}
			}
			
			visible = solid = module.exists;
		}
		
		protected function updatePosition():void {
			var baseX:int = module.x * U.GRID_DIM;
			var baseY:int = module.y * U.GRID_DIM;
			
			x = baseX + module.layout.offset.x * U.GRID_DIM;
			y = baseY + module.layout.offset.y * U.GRID_DIM;
			
			for each (var displayPort:DPort in displayPorts)
				displayPort.updatePosition(baseX, baseY);
			
			for each (var displayNode:DNode in displayNodes)
				displayNode.node.updatePosition();
			
			nameText.size = U.state.zoom >= 0.5 ? U.FONT_SIZE : U.FONT_SIZE * 2;
			nameText.x = x;
			nameText.y = y + (height - nameText.height) / 2;
		}
		
		override public function draw():void {
			super.draw();
			for each (var displayPort:DPort in displayPorts)
				displayPort.draw();
			
			if (module.internalLayout && U.state.zoom >= 0.5) {	
				for each (var displayConnection:DWire in displayConnections)
					displayConnection.draw();	
				for each (var displayNode:DNode in displayNodes)
					displayNode.draw();
			}
			else if (U.state.zoom >= 0.25) {
				nameText.text = getName();
				nameText.draw();
			}
		}
	}

}