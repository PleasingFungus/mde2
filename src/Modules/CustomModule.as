package Modules {
	import Components.Port;
	import flash.geom.Point;
	import Layouts.PortLayout;
	import Layouts.ModuleLayout;
	import Values.Value;
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
			}
			
			averageLoc.x = Math.round(averageLoc.x / modules.length);
			averageLoc.y = Math.round(averageLoc.y / modules.length);
			
			if (X == C.INT_NULL)
				X = averageLoc.x;
			if (Y == C.INT_NULL)
				Y = averageLoc.y;
			
			super(X, Y, "Custom", CAT_MISC,  inputs.length, outputs.length, controls.length);
			abbrev = "?";
			
			//TODO: calculate delay
		}
		
		override protected function makePorts(numInputs:int, numOutputs:int, numControls:int):void {
			
		}
		
		override protected function generateLayout():ModuleLayout {
			var layout:ModuleLayout = super.generateLayout();
			for each (var portLayout:PortLayout in layout.ports)
				portLayout.parent = this;
			return layout;
		}
		
		override public function initialize():void {
			super.initialize();
			for each (var module:Module in modules)
				module.initialize();
		}
		
		override public function lastMinuteInit():void {
			for each (var module:Module in modules)
				module.lastMinuteInit();
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
			if (port.parent != this)
				return port.parent.drive(port);
			return U.V_UNPOWERED;
		}
		
		
		
		override public function getSaveValues():Array {
			var saveValues:Array = super.getSaveValues();
			
			for each (var module:Module in modules) {
				var moduleConnections:Vector.<String> = new Vector.<String>;
				
				for each (var portLayout:PortLayout in module.layout.ports) {
					if (portLayout.port.isOutput)
						continue;
					
					var source:Port = portLayout.port.source;
					if (!source || modules.indexOf(source.parent) == -1)
						moduleConnections.push(NIL_CONNECT + CONNECTION_DELIM + NIL_CONNECT);
					else
						moduleConnections.push(modules.indexOf(source.parent) + CONNECTION_DELIM + source.parent.outputs.indexOf(source));
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
		
		public static function fromSelection(selection:Vector.<Module>):CustomModule {
			var module:Module, moduleIndex:int;
				
			if (!selection.length)
				return null;
			
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
					
					var sourceModuleIndex:int = selection.indexOf(oldSource.parent);
					if (sourceModuleIndex == -1)
						for (sourceModuleIndex = 0; sourceModuleIndex < selection.length; sourceModuleIndex++) //try to look for custom modules containing the port
							if (selection[sourceModuleIndex].outputs.indexOf(oldSource) != -1)
								break;
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
			return new CustomModule(clones);
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
		
		private static var CONNECTION_DELIM:String = "|";
		private static var MODULE_DELIM:String = "||";
		private static var NIL_CONNECT:String = "-";
		private static var ESCAPE_CHAR:String = "%";
		private static var ESCAPE_TABLE:Array = [ESCAPE_CHAR, MODULE_DELIM, CONNECTION_DELIM, U.ARG_DELIM];
	}

}