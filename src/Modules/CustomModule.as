package Modules {
	import Components.ConnectionQuad;
	import Components.Port;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import Layouts.DefaultLayout;
	import Layouts.InternalLayout;
	import Layouts.PortLayout;
	import Layouts.ModuleLayout;
	import Values.Value;
	import org.flixel.FlxSprite;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class CustomModule extends Module {
		
		public var modules:Vector.<Module>;
		public function CustomModule(Modules:Vector.<Module>, X:int=C.INT_NULL, Y:int=C.INT_NULL) {
			modules = Modules;
			
			var averageLoc:Point = new Point;
			var port:Port;
			inputs = new Vector.<Port>;
			outputs = new Vector.<Port>;
			controls = new Vector.<Port>;
			for each (var module:Module in modules) {
				averageLoc = averageLoc.add(module);
				
				for each (port in module.inputs)
					if (!port.source)
						inputs.push(port);
				for each (port in module.outputs)
					if (!port.connections.length)
						outputs.push(port);
				for each (port in module.controls)
					if (!port.source)
						controls.push(port);
				
				writesToMemory += module.writesToMemory;
			}
			
			averageLoc.x = Math.round(averageLoc.x / modules.length);
			averageLoc.y = Math.round(averageLoc.y / modules.length);
			
			if (X == C.INT_NULL)
				X = averageLoc.x;
			if (Y == C.INT_NULL)
				Y = averageLoc.y;
			
			super(X, Y, "Custom", ModuleCategory.MISC,  inputs.length, outputs.length, controls.length);
			abbrev = "?";
			weight = modules.length;
		}
		
		override protected function makePorts(numInputs:int, numOutputs:int, numControls:int):void {
			
		}
		
		override public function generateSymbolDisplay():FlxSprite {
			var module:Module;
			var base:FlxSprite = new FlxSprite().makeGraphic(layout.dim.x * U.GRID_DIM, layout.dim.y * U.GRID_DIM, 0x0, true);
			var SYMBOL_DIM:int = 24;
			var usableSpace:Point = new Point(base.width - SYMBOL_DIM * 1.5, base.height - SYMBOL_DIM * 1.5);
			
			var topLeft:Point = new Point(int.MAX_VALUE, int.MAX_VALUE);
			var bottomRight:Point = new Point(int.MIN_VALUE, int.MIN_VALUE);
			for each (module in modules) {
				if (module.x < topLeft.x)
					topLeft.x = module.x;
				if (module.y < topLeft.y)
					topLeft.y = module.y;
				if (module.x > bottomRight.x)
					bottomRight.x = module.x;
				if (module.y > bottomRight.y)
					bottomRight.y = module.y;
			}
			
			topLeft.x *= U.GRID_DIM;
			topLeft.y *= U.GRID_DIM;
			bottomRight.x *= U.GRID_DIM;
			bottomRight.y *= U.GRID_DIM;
			
			var positioningScale:Point = new Point(usableSpace.x / Math.max(bottomRight.x - topLeft.x, usableSpace.x),
												   usableSpace.y / Math.max(bottomRight.y - topLeft.y, usableSpace.y));
			var symbolScale:Number = 1//Math.max(Math.min(positioningScale.x, positioningScale.y), 1/4);
			
			for each (module in modules) {
				var symbol:FlxSprite = module.generateSymbolDisplay();
				if (!symbol)
					continue;
				
				symbol.scale.x = symbol.scale.y = symbolScale;
				symbol.x = (module.x * U.GRID_DIM - topLeft.x) * positioningScale.x + symbolScale * SYMBOL_DIM / 2;
				symbol.y = (module.y * U.GRID_DIM - topLeft.y) * positioningScale.y + symbolScale * SYMBOL_DIM / 2;
				symbol.offset.x = symbol.offset.y = 0;
				base.stamp(symbol, symbol.x, symbol.y);
			}
			
			base.alpha = 1;
			return base;
		}
		
		override public function generateLargeSymbolDisplay():FlxSprite { return generateSymbolDisplay(); }
		
		override protected function generateLayout():ModuleLayout {
			var layout:ModuleLayout = new DefaultLayout(this, 2, 6);
			for each (var portLayout:PortLayout in layout.ports)
				portLayout.port.physParent = this;
			return layout;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			return new InternalLayout([]);
		}
		
		override public function initialize():void {
			super.initialize();
			for each (var module:Module in modules)
				module.initialize();
		}
		
		override public function cacheValues():void {
			for each (var module:Module in modules)
				module.cacheValues();
		}
		
		override public function clearCachedValues():void {
			for each (var module:Module in modules)
				module.clearCachedValues();
		}
		
		override public function updateState():Boolean {
			var changed:Boolean = false;
			for each (var module:Module in modules)
				changed = changed || module.updateState();
			return changed;
		}
		
		override public function drive(port:Port):Value {
			if (port.dataParent != this)
				return port.dataParent.drive(port);
			throw new Error("Port in custom-module sans parent!");
			//return U.V_UNPOWERED; 
		}
		
		
		
		override public function getSaveValues():Array {
			var saveValues:Array = super.getSaveValues();
			
			for each (var module:Module in modules) {
				var moduleConnections:Vector.<String> = new Vector.<String>;
				
				for each (var portLayout:PortLayout in module.layout.ports) {
					if (portLayout.port.isOutput)
						continue;
					
					var source:Port = portLayout.port.source;
					if (!source || modules.indexOf(source.dataParent) == -1) //TODO: FIXME: breaks with triple-nested custom modules
						moduleConnections.push(NIL_CONNECT + CONNECTION_DELIM + NIL_CONNECT);
					else
						moduleConnections.push(modules.indexOf(source.dataParent) + CONNECTION_DELIM + source.dataParent.outputs.indexOf(source));
				}
				
				var saveValue:String = escapeModuleString(module.saveString());
				if (moduleConnections.length)
					saveValue += MODULE_DELIM + moduleConnections.join(MODULE_DELIM);
				saveValues.push(saveValue);
			}
			
			return saveValues;
			
			
			//per custom module: type,x,y,module1,module2...
			//per module: [escaped modulestr]||connect1||connect2...
			//per connect: module|port
			//50,5,4,49||32|-15|0||3|1||3|2,...
		}
		
		public static function fromArgs(args:Array):CustomModule {
			var x:int = C.safeInt(args[0]);
			var y:int = C.safeInt(args[1]);
			args = args.slice(2);
			
			var modules:Vector.<Module> = new Vector.<Module>;
			for each (var argSet:String in args) {
				var moduleArgs:Array = argSet.split(MODULE_DELIM);
				var moduleString:String = moduleArgs[0];
				var unescapedString:String = unescapeModuleString(moduleString);
				if (unescapedString.indexOf(CONNECTION_DELIM) != -1)
					return null; //debug
				var module:Module = Module.fromString(unescapedString);
				modules.push(module);
			}
			
			for (var moduleIndex:int = 0; moduleIndex < modules.length; moduleIndex++) {
				module = modules[moduleIndex];
				moduleArgs = args[moduleIndex].split(MODULE_DELIM).slice(1);
				for (var portIndex:int = 0; portIndex < moduleArgs.length; portIndex++) {
					var port:Port = module.layout.ports[portIndex].port;
					var connectionArgs:Array = moduleArgs[portIndex].split(CONNECTION_DELIM);
					
					if (connectionArgs[0] == NIL_CONNECT)
						continue;
					
					var sourceModuleIndex:int = C.safeInt(connectionArgs[0]);
					var sourcePortIndex:int = C.safeInt(connectionArgs[1]);
					var source:Port = modules[sourceModuleIndex].outputs[sourcePortIndex];
					
					source.connections.push(port);
					port.connections.push(source);
					port.source = source;
				}
			}
			
			return new CustomModule(modules, x, y);
		}
		
		public static function fromSelection(selection:Vector.<Module>, Loc:Point):CustomModule {
			var module:Module, moduleIndex:int;
				
			if (!selection.length)
				return null;
			
			if (U.state && U.state.level.writerLimit) {
				var writerCount:int = U.state.numMemoryWriters();
				for each (module in selection)
					writerCount += module.writesToMemory;
				if (writerCount > U.state.level.writerLimit)
					return null;
			}
			
			var clones:Vector.<Module> = new Vector.<Module>;
			for each (module in selection) {
				var moduleString:String = module.saveString();
				var clone:Module = Module.fromString(moduleString);
				clones.push(clone);
			}
			
			for (moduleIndex = 0; moduleIndex < clones.length; moduleIndex++) {
				clone = clones[moduleIndex];
				module = selection[moduleIndex];
				for (var portIndex:int = 0; portIndex < clone.layout.ports.length; portIndex++) {
					var oldPortLayout:PortLayout = module.layout.ports[portIndex];
					if (oldPortLayout.port.isOutput || !oldPortLayout.port.source)
						continue;
					var oldSource:Port = oldPortLayout.port.source;
					
					var sourceModuleIndex:int = selection.indexOf(oldSource.dataParent);
					if (sourceModuleIndex == -1)
						for (sourceModuleIndex = 0; sourceModuleIndex < selection.length; sourceModuleIndex++) //try to look for custom modules containing the port
							if (selection[sourceModuleIndex].outputs.indexOf(oldSource) != -1)
								break; //TODO: FIXME: this will break for triple-nested custom modules
					if (sourceModuleIndex != -1 && sourceModuleIndex < selection.length) {
						var sourceModule:Module = selection[sourceModuleIndex];
						var sourcePortIndex:int = sourceModule.outputs.indexOf(oldSource);
						
						var cloneSource:Port = clones[sourceModuleIndex].outputs[sourcePortIndex];
						var newPort:Port = clone.layout.ports[portIndex].port;
						
						newPort.source = cloneSource;
						cloneSource.connections.push(newPort);
					}
				}
			}
			
			var customModule:CustomModule = new CustomModule(clones, Loc.x, Loc.y);
			if (customModule.outputs.length > 16 || customModule.inputs.length > 16 || customModule.controls.length > 16)
				return null;
			if (Math.max(customModule.outputs.length, customModule.inputs.length) * customModule.controls.length > 64)
				return null;
			return customModule;
		}
		
		private static function escapeModuleString(s:String):String {
			for (var i:int = 0; i < ESCAPE_TABLE.length; i++)
				s = C.replaceAllLinear(s, ESCAPE_TABLE[i], ESCAPE_CHAR+i)
			return s;
		}
		
		private static function unescapeModuleString(s:String):String {
			for (var i:int = ESCAPE_TABLE.length - 1; i >= 0; i--)
				s = C.replaceAllLinear(s, ESCAPE_CHAR+i, ESCAPE_TABLE[i])
			return s;
		}
		
		override protected function getSaveBytes():ByteArray {
			var moduleBytes:Vector.<ByteArray> = new Vector.<ByteArray>;
			var moduleLength:int = 4;
			for each (var module:Module in modules) {
				var bytes:ByteArray = module.getBytes();
				moduleBytes.push(bytes);
				moduleLength += bytes.length;
			}
			var byteArray:ByteArray = new ByteArray;
			byteArray.writeInt(moduleLength);
			for each (bytes in moduleBytes)
				byteArray.writeBytes(bytes);
			
			for each (module in modules)
				for each (var portLayout:PortLayout in module.layout.ports)
					if (portLayout.port.source != portLayout.port && portLayout.port.source &&
						modules.indexOf(portLayout.port.source.dataParent) != -1) //TODO: FIXME: breaks with triple-nested custom modules
						byteArray.writeBytes(new ConnectionQuad(portLayout.port, portLayout.port.source).toBytes(modules));
			
			return byteArray;
		}
		
		public static function fromBytes(x:int, y:int, bytes:ByteArray, end:int, allowableTypes:Vector.<Class> = null):CustomModule {
			var moduleLength:int = bytes.readInt();
			var moduleEnd:int = bytes.position - 4 + moduleLength;
			var modules:Vector.<Module> = Module.modulesFromBytes(bytes, moduleEnd, allowableTypes);
			if (bytes.position != moduleEnd)
				throw new Error("Unexpected position in module reading for custom module");
			
			while (bytes.position < end)
				ConnectionQuad.fromBytes(bytes, modules).connect();
			if (bytes.position != end)
				throw new Error("Unexpected position in connection reading for custom module");
			
			return new CustomModule(modules, x, y);
		}
		
		private static var CONNECTION_DELIM:String = "|";
		private static var MODULE_DELIM:String = "||";
		private static var NIL_CONNECT:String = "-";
		private static var ESCAPE_CHAR:String = "%";
		private static var ESCAPE_TABLE:Array = [ESCAPE_CHAR, MODULE_DELIM, CONNECTION_DELIM, U.ARG_DELIM];
	}

}