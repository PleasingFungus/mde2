package Displays {
	import Components.Port;
	import Modules.Module;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DModule extends FlxSprite {
		
		public var module:Module;
		private var inputs:Vector.<DPort>;
		private var outputs:Vector.<DPort>;
		private var controls:Vector.<DPort>;
		private var nameText:FlxText;
		private var locked:Boolean;
		public function DModule(module:Module) {
			super(module.x, module.y);
			this.module = module;
			module.display = this;
			refresh();
			x -= width / 2;
			y -= height / 2;
		}
		
		public function refresh():void {
			if (locked) {
				module.severConnections();
				removeConnectPoints();
			}
			
			makeGraphic(DIM * module.controls.length + PADDING,
						DIM * Math.max(module.inputs.length, module.outputs.length) + PADDING,
						module.FIXED ? 0xff808080 : 0xff7070a0, true);
			
			nameText = new FlxText( -1, -1, width - DIM / 4, getName());
			nameText.setFormat(U.FONT, U.FONT_SIZE, 0x0, 'center');
			nameText.scrollFactor = scrollFactor; //object
			
			var port:Port;
			inputs = new Vector.<DPort>;
			for each (port in module.inputs) makePort(port, inputs);
			outputs = new Vector.<DPort>;
			for each (port in module.outputs) makePort(port, outputs);
			controls = new Vector.<DPort>;
			for each (port in module.controls) makePort(port, controls, true);
			
			if (locked)
				lockdown();
		}
		
		private function getName():String {
			var displayName:String = module.renderName();
			if (U.level.delayEnabled && module.delay)
				displayName += "\n\nD" + module.delay;
			return displayName;
		}
		
		private function makePort(port:Port, portList:Vector.<DPort>, vertical:Boolean = false):DPort {
			var displayPort:DPort = new DPort(port, vertical);
			displayPort.scrollFactor = scrollFactor; //object
			portList.push(displayPort);
			return displayPort;
		}
		
		public function lockdown():void {
			module.x = x + width / 2;
			module.y = y + height / 2;
			positionPorts();
			
			var port:DPort;
			for each (port in inputs) lockPort(port);
			for each (port in outputs) lockPort(port);
			for each (port in controls) lockPort(port);
			
			locked = true;
			exists = module.exists = true;
		}
		
		protected function lockPort(port:DPort):void {
			U.connectionPoints.push(port);
			port.attemptConnect();
		}
		
		public function removeConnectPoints():void {
			var port:DPort;
			for each (port in inputs) removeConnection(port); 
			for each (port in outputs) removeConnection(port);
			for each (port in controls) removeConnection(port);
		}
		
		protected function removeConnection(port:DPort):void {
			U.connectionPoints.splice(U.connectionPoints.indexOf(port), 1);
			port.port.connection = null;
		}
		
		public function findPort(p:Port):DPort {
			var dPort:DPort;
			for each (dPort in inputs) if (dPort.port == p) return dPort;
			for each (dPort in outputs) if (dPort.port == p) return dPort;
			for each (dPort in controls) if (dPort.port == p) return dPort;
			return null;
		}
		
		override public function update():void {
			super.update();
			if (module.dirty)
				refresh();
			//if (nameText.font != U.FONT || nameText.size != U.FONT_SIZE) {
				//nameText = new FlxText(nameText.x, nameText.y, nameText.width * U.FONT_SIZE / nameText.size, nameText.text);
				//nameText.setFormat(U.FONT, U.FONT_SIZE, 0x0, nameText.alignment, nameText.shadow);
			//}
			if (!module.exists)
				exists = false;
		}
		
		override public function draw():void {
			super.draw();
			
			var displayPort:DPort;
			
			if (!locked)
				positionPorts();
			
			for each (displayPort in inputs)
				displayPort.draw();
			
			for each (displayPort in outputs)
				displayPort.draw();
			
			for each (displayPort in controls)
				displayPort.draw();
			
			if (U.zoom >= 0.5) {
				nameText.x = x +DIM / 8;
				nameText.y = y + (height - nameText.height) / 2;
				nameText.text = getName();
				nameText.draw();
			}
		}
		
		protected function positionPorts():void {
			var Y:int, X:int, displayPort:DPort;
			
			Y = y + PADDING / 2 + DIM / 2 + (height - PADDING - inputs.length * DIM) / 2;
			for each (displayPort in inputs) {
				displayPort.x = x;
				displayPort.y = Y;
				Y += DIM;
			}
			
			Y = y + PADDING / 2 + DIM / 2 + (height - PADDING - outputs.length * DIM) / 2;
			for each (displayPort in outputs) {
				displayPort.x = x + width - displayPort.width;
				displayPort.y = Y;
				Y += DIM;
			}
			
			X = x + PADDING / 2 + DIM / 2;
			for each (displayPort in controls) {
				displayPort.x = X;
				displayPort.y = y;
				X += DIM;
			}
		}
		
		private const DIM:int = 32;
		private const PADDING:int = DIM * 1.5;
		
		
		
		public static function place(displayModule:DModule):Boolean {
			displayModule.lockdown();
			U.modules.push(displayModule.module);
			
			return true;
		}
		
		public static function remove(displayModule:DModule):Boolean {
			var module:Module = displayModule.module;
			if (module.FIXED)
				return false;
			
			module.exists = false;
			module.severConnections();
			displayModule.removeConnectPoints();
			U.modules.splice(U.modules.indexOf(module), 1);
			
			return true;
		}
	}

}