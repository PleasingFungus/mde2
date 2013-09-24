package Components {
	import Components.Wire;
	import flash.geom.Point;
	import Layouts.PortLayout;
	import Components.WireHistory;
	import Modules.CustomModule;
	import Modules.Module;
	import Actions.BlocLiftAction;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Bloc {
		
		public var modules:Vector.<Module>;
		public var wires:Vector.<Wire>;
		private var newLinks:Vector.<Link>;
		public var connections:Vector.<Connection>;
		public var origin:Point;
		public var lastLoc:Point;
		public var lastRootedLoc:Point;
		public var rooted:Boolean;
		public var exists:Boolean;
		public function Bloc(modules:Vector.<Module>, wires:Vector.<Wire>, Rooted:Boolean = true) {
			this.modules = modules;
			this.wires = wires;
			connections = new Vector.<Connection>;
			rooted = Rooted;
			exists = true;
		}
		
		public function validPosition(p:Point):Boolean {
			if (!moveTo(p))
				return false;
			
			for each (var module:Module in modules)
				if (!module.validPosition)
					return false;
			for each (var wire:Wire in wires)
				if (wire.collides())
					return false;
			return true;
		}
		
		public function place(p:Point):Boolean {
			if (rooted)
				return false;
			
			moveTo(p);
			rooted = true;
			
			for each (var wire:Wire in wires)
				Wire.place(wire);
			
			newLinks = new Vector.<Link>;
			for each (var module:Module in modules) {
				module.register();
				for each (var port:PortLayout in module.layout.ports)
					if (port.port.newLink) {
						newLinks.push(port.port.newLink)
						port.port.newLink = null;
					}
			}
			
			exists = true;
			return true;
		}
		
		public function remove(p:Point):Boolean {
			if (!rooted)
				return false;
			
			for each (var link:Link in newLinks)
				Link.remove(link);
			for each (var module:Module in modules)
				module.deregister();
			for each (var wire:Wire in wires)
				Wire.remove(wire);
			
			rooted = false;
			exists = false;
			origin = lastRootedLoc = p;
			return true;
		}
		
		public function unravel():void {
			if (rooted)
				exists = false;
			else
				destroy();
		}
		
		public function destroy():void {
			for each (var module:Module in modules)
				module.exists = false;
			for each (var wire:Wire in wires)
				wire.exists = false;
			exists = false;
		}
		
		public function mobilize():void {
			for each (var module:Module in modules)
				module.exists = true;
			for each (var wire:Wire in wires)
				wire.exists = true;
			exists = true;
		}
		
		public function moveTo(p:Point):Boolean {
			if (origin.equals(p) || (lastLoc && lastLoc.equals(p)))
				return true;
			lastLoc = p;
				
			//shift modules/wires			
			var delta:Point = p.subtract(origin);
			
			for each (var module:Module in modules) {
				module.x += delta.x;
				module.y += delta.y;
			}
			
			for each (var wire:Wire in wires)
				wire.shift(delta);
			
			var oldLoc:Point = origin;
			origin = p;
			
			return true;
		}
		
		private function verifyNotPlaced():void {
			for each (var module:Module in modules)
				if (module.deployed)
					throw new Error("Module not retracted!");
			for each (var wire:Wire in wires)
				if (wire.deployed)
					throw new Error("Wire not retracted!");
		}
		
		protected function carrierIncluded(carrier:Carrier):Boolean {
			if (carrier is Wire)
				return wires.indexOf(carrier) != -1;
			if (carrier is Port) {
				if (modules.indexOf((carrier as Port).parent) != -1)
					return true;
				return layoutForPort(carrier as Port) != null; //dumb but maybe it's a custommodule?
			}
			
			throw new Error("Unknown carrier type!");
		}
		
		protected function layoutForPort(port:Port):PortLayout {
			//this is dumb and bad
			for each (var module:Module in modules)
				if (module == port.parent || module is CustomModule)
					for each (var portLayout:PortLayout in module.layout.ports)
						if (portLayout.port == port)
							return portLayout;
			return null;
		}
		
		public function lift():void {	
			new BlocLiftAction(this, U.pointToGrid(U.mouseLoc)).execute();
		}
		
		
		public function toString():String {
			var moduleStrings:Vector.<String> = new Vector.<String>;
			for each (var module:Module in modules)
				moduleStrings.push(module.saveString());
			var wireStrings:Vector.<String> = new Vector.<String>;
			for each (var wire:Wire in wires)
				wireStrings.push(wire.saveString());
			return [moduleStrings.join(U.SAVE_DELIM), wireStrings.join(U.SAVE_DELIM)].join(U.MAJOR_SAVE_DELIM);
		}
		
		
		public static function fromString(str:String, Rooted:Boolean = false):Bloc {
			var stringSegments:Array = str.split(U.MAJOR_SAVE_DELIM);
			var moduleStrings:Array = stringSegments[0].split(U.SAVE_DELIM);
			var wireStrings:Array = stringSegments[1].split(U.SAVE_DELIM);
			
			var allowableTypes:Vector.<Class> = U.state.level.allowedModules;
			var writersRemaining:int = U.state.level.writerLimit ? U.state.level.writerLimit - U.state.numMemoryWriters() : int.MAX_VALUE;
			
			var modules:Vector.<Module> = new Vector.<Module>;
			var averageLoc:Point = new Point;
			for each (var moduleString:String in moduleStrings) {
				var module:Module = Module.fromString(moduleString, allowableTypes);
				if (!module) continue;
				if (module.writesToMemory > writersRemaining) continue;
				
				modules.push(module);
				U.state.modules.push(module);
				averageLoc = averageLoc.add(module);
				writersRemaining -= module.writesToMemory;
			}
			if (modules.length) {
				averageLoc.x = Math.round(averageLoc.x / modules.length);
				averageLoc.y = Math.round(averageLoc.y / modules.length);
			}
			
			var wires:Vector.<Wire> = new Vector.<Wire>;
			var wireLength:int;
			for each (var wireString:String in wireStrings) {
				var wire:Wire = Wire.fromString(wireString);
				if (!wire) continue;
				
				wires.push(wire);
				
				if (!modules.length) {
					for each (var p:Point in wire.path)
						averageLoc = averageLoc.add(p);
					wireLength += wire.path.length;
				}
			}
			if (!modules.length) {
				if (!wires.length)
					return null;
				averageLoc.x = Math.round(averageLoc.x / wireLength);
				averageLoc.y = Math.round(averageLoc.y / wireLength);
			}
			
			var bloc:Bloc = new Bloc(modules, wires, Rooted);
			bloc.origin = averageLoc;
			if (bloc.rooted)
				bloc.lastRootedLoc = bloc.origin;
			return bloc;
		}
		
		
		public static function make(moduleArray:Array, wireArray:Array):Bloc {
			var modules:Vector.<Module> = new Vector.<Module>;
			for each (var module:Module in moduleArray)
				modules.push(module);
			
			var wires:Vector.<Wire> = new Vector.<Wire>;
			for each (var wire:Wire in wireArray)
				wires.push(wire);
			
			return new Bloc(modules, wires);
		}
	}

}