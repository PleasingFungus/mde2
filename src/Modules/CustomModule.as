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
		public function CustomModule(Modules:Vector.<Module>) {
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
			
			super(averageLoc.x, averageLoc.y, "Custom", CAT_MISC,
				  inputs.length, outputs.length, controls.length);
			
				  
			
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
		
		override public function drive(port:Port):Value {
			if (port.parent != this)
				return port.parent.drive(port);
			return U.V_UNPOWERED;
		}
		
		override public function getSaveValues():Array {
			var saveValues:Array = [ALL_MODULES.indexOf(Object(this).constructor)];
			
			for each (var module:Module in modules) {
				var moduleConnections:Vector.<String> = new Vector.<String>;
				
				for each (var portLayout:PortLayout in module.layout.ports) {
					if (portLayout.port.isOutput)
						continue;
					
					var source:Port = portLayout.port.source;
					if (!source || modules.indexOf(source.parent) == -1)
						moduleConnections.push(NIL_CONNECT + INTERNAL_DELIM + NIL_CONNECT);
					else
						moduleConnections.push(modules.indexOf(source.parent) + INTERNAL_DELIM + source.parent.outputs.indexOf(source));
				}
				
				var saveValue:String = module.getSaveValues().join(INTERNAL_DELIM);
				if (moduleConnections.length)
					saveValue += SECTION_DELIM + moduleConnections.join(SECTION_DELIM);
				saveValues.push(saveValue);
			}
			
			return saveValues;
			
			//50,49||32|-15|0||3|1||3|2||...
		}
		
		public static function fromArgs(args:Array):CustomModule {
			var modules:Vector.<Module> = new Vector.<Module>;
			for each (var argSet:String in args) {
				var moduleArgs:Array = argSet.split(SECTION_DELIM);
				var moduleString:String = moduleArgs[0];
				var module:Module = Module.fromString(C.replaceAll(moduleString, INTERNAL_DELIM, U.ARG_DELIM));
				modules.push(module);
			}
			
			for (var j:int = 0; j < modules.length; j++) {
				module = modules[j];
				moduleArgs = args[j].split(SECTION_DELIM).slice(1);
				for (var i:int = 0; i < moduleArgs.length; i++) {
					var port:Port = module.layout.ports[i].port;
					var connectionArgs:Array = moduleArgs[i].split(INTERNAL_DELIM);
					var moduleIndex:int = C.safeInt(connectionArgs[0]);
					var portIndex:int = C.safeInt(connectionArgs[1]);
					var source:Port = modules[moduleIndex].outputs[portIndex];
					
					source.connections.push(port);
					port.connections.push(source);
					port.source = source;
				}
			}
			
			return new CustomModule(modules);
		}
		
		public static function fromSelection(selection:Vector.<Module>):CustomModule {
			if (!selection.length)
				return null;
			
			var clones:Vector.<Module> = new Vector.<Module>;
			for each (var module:Module in selection) {
				var moduleString:String = module.saveString();
				var clone:Module = Module.fromString(moduleString.substr(0, moduleString.length - 1));
				clones.push(clone);
			}
			
			for (var j:int = 0; j < clones.length; j++) {
				clone = clones[j];
				module = selection[j];
				for (var i:int = 0; i < clone.layout.ports.length; i++) {
					var oldPortLayout:PortLayout = module.layout.ports[i];
					if (oldPortLayout.port.isOutput || !oldPortLayout.port.source)
						continue;
					
					var moduleIndex:int = selection.indexOf(oldPortLayout.port.source.parent);
					if (moduleIndex != -1) {
						var portIndex:int = oldPortLayout.port.source.parent.outputs.indexOf(oldPortLayout.port.source);
						
						var cloneSource:Port = clones[moduleIndex].outputs[portIndex];
						var newPort:Port = clone.layout.ports[i].port;
						
						newPort.source = cloneSource;
						cloneSource.connections.push(newPort);
					}
				}
			}
			return new CustomModule(clones);
		}
		
		private static var SECTION_DELIM:String = "||";
		private static var INTERNAL_DELIM:String = "|";
		private static var NIL_CONNECT:String = "-";
	}

}