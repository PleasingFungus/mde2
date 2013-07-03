package Components {
	import Components.Wire;
	import flash.geom.Point;
	import Layouts.PortLayout;
	import LevelStates.WireHistory;
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
		public var connections:Vector.<Connection>;
		public var associatedWires:Vector.<Wire>;
		public var newAssociatedWires:Vector.<Wire>;
		public var origin:Point;
		public var lastLoc:Point;
		public var lastRootedLoc:Point;
		public var rooted:Boolean;
		public var exists:Boolean;
		public function Bloc(modules:Vector.<Module>, wires:Vector.<Wire>, Rooted:Boolean = true) {
			this.modules = modules;
			this.wires = wires;
			connections = findConnections();
			rooted = Rooted;
			exists = true;
		}
		
		public function validPosition(p:Point):Boolean {
			if (!moveTo(p))
				return false;
			if (associatedWires)
				return true;
			
			for each (var module:Module in modules)
				if (!module.validPosition)
					return false;
			for each (var wire:Wire in wires)
				if (wire.collides())
					return false;
			return true;
		}
		
		public function place(p:Point):Boolean {
			moveTo(p);
			rooted = true;
			
			for each (var wire:Wire in wires)
				Wire.place(wire);
			for each (var module:Module in modules)
				module.register();
			
			connections = findConnections();
			
			exists = true;
			return true;
		}
		
		public function remove(p:Point):Boolean {
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
			for each (wire in associatedWires)
				if (wire.deployed) {
					Wire.remove(wire);
					wire.exists = true;
				}
			exists = true;
		}
		
		public function moveTo(p:Point):Boolean {
			if (origin.equals(p) || (lastLoc && lastLoc.equals(p)))
				return false;
			lastLoc = p;
				
			//shift modules/wires			
			var delta:Point = p.subtract(origin);
			
			for each (var module:Module in modules) {
				module.x += delta.x;
				module.y += delta.y;
			}
			
			for each (var wire:Wire in wires)
				for each (var wirePoint:Point in wire.path) {
					wirePoint.x += delta.x;
					wirePoint.y += delta.y;
				}
			
			var oldLoc:Point = origin;
			origin = p;
			
			if (!associatedWires)
				return true;
			//attempt path
			if (attemptPath())
				return true;
			
			for each (module in modules) {
				module.x -= delta.x;
				module.y -= delta.y;
			}
			for each (wire in wires)
				for each (wirePoint in wire.path) {
					wirePoint.x -= delta.x;
					wirePoint.y -= delta.y;
				}
			origin = oldLoc;
			return false;
		}
		
		protected function attemptPath():Boolean {
			var module:Module, wire:Wire;
			var rollbackModules:Vector.<Module> = new Vector.<Module>;
			var rollbackWires:Vector.<Wire> = new Vector.<Wire>;
			
			//build assocwire history
			var history:Vector.<WireHistory> = new Vector.<WireHistory>;
			for each (wire in associatedWires)
				history.push(new WireHistory(wire));
			
			function rollback():Boolean {
				for each (module in rollbackModules) {
					Module.remove(module);
					module.exists = true;
				}
				for each (wire in rollbackWires) {
					Wire.remove(wire);
					wire.exists = true;
				}
				return false;
			}
			
			var deltaSinceRoot:Point = origin.subtract(lastRootedLoc);
			
			//place modules, wires
			for each (module in modules) {
				if (!module.validPosition)
					return rollback();
				
				Module.place(module);
				rollbackModules.push(module);
			}
			
			for each (wire in wires) {
				if (!wire.validPosition())
					return rollback();
				
				Wire.place(wire);
				rollbackWires.push(wire);
			}
			
			//for each assocwire, attempt path, place
			for (var connectionIndex:int = 0; connectionIndex < connections.length; connectionIndex++) {
				var connection:Connection = connections[connectionIndex];
				wire = associatedWires[connectionIndex];
				var pathSuccess:Boolean = wire.attemptPath(connection.point.clone(), connection.point.add(deltaSinceRoot), true, true);
				if (!pathSuccess) {
					rollback();
					for each (var wireHistory:WireHistory in history)
						wireHistory.revert();
					return false;
				}
				
				Wire.place(wire);
				rollbackWires.push(wire);
			}
			
			rollback();
			return true;
		}
		
		protected function findConnections():Vector.<Connection> {
			var connections:Vector.<Connection> = new Vector.<Connection>;
			var carrier:Carrier;
			for each (var module:Module in modules)
				for each (var portLayout:PortLayout in module.layout.ports)
					for each (carrier in portLayout.port.connections)
						if (!carrierIncluded(carrier))
							connections.push(new Connection(portLayout.port, carrier, portLayout.Loc));
			for each (var wire:Wire in wires)
				for each (carrier in wire.connections)
					if (!carrierIncluded(carrier))
						connections.push(new Connection(wire, carrier, wire.connectionLoc(carrier)));
			return connections;
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
			associatedWires = generateAssociatedWires();
			new BlocLiftAction(this, U.pointToGrid(U.mouseLoc)).execute();
			mobilize();
		}
		
		protected function generateAssociatedWires():Vector.<Wire> {
			var wires:Vector.<Wire> = new Vector.<Wire>;
			newAssociatedWires = new Vector.<Wire>;
			for each (var connection:Connection in connections) {
				if (connection.secondary is Wire) {
					var wire:Wire = connection.secondary as Wire;
					if (wire.path[0].equals(connection.point) || wire.path[wire.path.length - 1].equals(connection.point)) {
						wires.push(wire);
						continue;
					}
				}
				var newWire:Wire = new Wire(connection.point);
				wires.push(newWire);
				newAssociatedWires.push(newWire);
			}
			return wires;
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