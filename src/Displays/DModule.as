package Displays {
	import Components.Port;
	import Components.Wire;
	import Layouts.InternalDWire;
	import Layouts.InternalWire;
	import Layouts.PortLayout;
	import Layouts.Nodes.InternalNode;
	import Modules.Module;
	import org.flixel.*;
	import UI.FontTuple;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DModule extends FlxSprite {
		
		public var module:Module;
		public var displayPorts:Vector.<DPort>;
		public var displayNodes:Vector.<DNode>;
		public var displayConnections:Vector.<InternalDWire>;
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
			font.configureFlxText(nameText, 0x0, 'center');
			nameText.scrollFactor = scrollFactor; //object
			
			displayPorts = new Vector.<DPort>;
			for each (var layout:PortLayout in module.layout.ports)
				displayPorts.push(makePort(layout));
			
			displayNodes = new Vector.<DNode>;
			displayConnections = new Vector.<InternalDWire>;
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
			
			var font:FontTuple = this.font;
			if (nameText.font != font.id || nameText.size != font.size)
				font.configureFlxText(nameText = new FlxText(-1, -1, width + U.GRID_DIM / 2, getName()), 0x0, 'center');
			
			updatePosition();
			
			for each (var displayNode:DNode in displayNodes)
				displayNode.node.update();
			
			for each (var dWire:DWire in displayConnections)
				dWire.update();
			
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
			
			nameText.x = x;
			nameText.y = y + (height - nameText.height) / 2;
		}
		
		public function descriptionAt(fp:FlxPoint):String {
			for each (var displayNode:DNode in displayNodes)
				if (displayNode.overlapsPoint(fp))
					return displayNode.node.getLabel();
			
			var out:String = module.name;
			if (module.getDescription())
				out += ": " + module.getDescription();
			if (U.state.level.delay && module.delay)
				out += " DELAY: " + module.delay+".";
			return out;
		}
		
		override public function draw():void {
			super.draw();
			
			if (module.internalLayout && U.state.zoom >= 0.5) {	
				for each (var displayConnection:DWire in displayConnections)
					if (displayConnection.visible)
						displayConnection.draw();
				for each (var displayNode:DNode in displayNodes)
					displayNode.draw();
			}
			else if (U.state.zoom >= 0.25) {
				nameText.text = getName();
				nameText.draw();
			}
			
			for each (var displayPort:DPort in displayPorts)
				displayPort.draw();
		}
		
		protected function get font():FontTuple {
			return U.state.zoom >= 0.5 ? U.MODULE_FONT_CLOSE : U.MODULE_FONT_FAR;
		}
	}

}