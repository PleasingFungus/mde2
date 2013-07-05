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
		protected var connections:Vector.<Connection>;
		public var singlyAssociatedWires:Vector.<AssociatedWire>;
		public var multiplyAssociatedWires:Vector.<AssociatedWire>;
		public var newAssociatedWires:Vector.<Wire>;
		public var origin:Point;
		public var lastLoc:Point;
		public var lastRootedLoc:Point;
		public var rooted:Boolean;
		public var exists:Boolean;
		public function Bloc(modules:Vector.<Module>, wires:Vector.<Wire>, Rooted:Boolean = true) {
			this.modules = modules;
			this.wires = wires;
			rooted = Rooted;
			exists = true;
		}
		
		public function validPosition(p:Point):Boolean {
			if (!moveTo(p))
				return false;
			if (singlyAssociatedWires) //already did a full test
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
			if (rooted)
				return false;
			
			moveTo(p);
			rooted = true;
			
			for each (var wire:Wire in wires)
				Wire.place(wire);
			for each (var module:Module in modules)
				module.register();
			
			if (singlyAssociatedWires != null) {
				for each (var assocWire:AssociatedWire in allAssociatedWires)
					Wire.place(assocWire.wire);
				singlyAssociatedWires = multiplyAssociatedWires = null;
			}
			
			exists = true;
			return true;
		}
		
		public function remove(p:Point):Boolean {
			if (!rooted)
				return false;
			
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
			for each (var associatedWire:AssociatedWire in allAssociatedWires) {
				Wire.remove(associatedWire.wire);
				associatedWire.wire.exists = true;
			}
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
			
			if (!singlyAssociatedWires)
				return true;
			
			for each (var associatedWire:AssociatedWire in multiplyAssociatedWires)
				associatedWire.wire.shift(delta);
			
			//attempt path
			var pathSuccess:Boolean = attemptPath();
			verifyNotPlaced();
			if (pathSuccess)
				return true;
			
			
			delta = new Point( -delta.x, -delta.y);
			for each (module in modules) {
				module.x += delta.x;
				module.y += delta.y;
			}
			for each (wire in wires)
				wire.shift(delta);
			for each (associatedWire in multiplyAssociatedWires)
				associatedWire.wire.shift(delta);
			origin = oldLoc;
			return false;
		}
		
		private function verifyNotPlaced():void {
			for each (var module:Module in modules)
				if (module.deployed)
					throw new Error("Module not retracted!");
			for each (var wire:Wire in wires)
				if (wire.deployed)
					throw new Error("Wire not retracted!");
			for each (var associatedWire:AssociatedWire in allAssociatedWires)
				if (associatedWire.wire.deployed)
					throw new Error("Associated wire not retracted!");
		}
		
		protected function attemptPath():Boolean {
			var module:Module, wire:Wire, associatedWire:AssociatedWire;
			var rollbackModules:Vector.<Module> = new Vector.<Module>;
			var rollbackWires:Vector.<Wire> = new Vector.<Wire>;
			
			//build assocwire history
			var history:Vector.<WireHistory> = new Vector.<WireHistory>;
			for each (associatedWire in singlyAssociatedWires)
				history.push(new WireHistory(associatedWire.wire));
			
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
			
			for each (associatedWire in multiplyAssociatedWires) {
				if (!associatedWire.wire.validPosition())
					return rollback();
				
				Wire.place(associatedWire.wire);
				rollbackWires.push(associatedWire.wire);
			}
			
			//for each assocwire, attempt path, place
			for each (associatedWire in singlyAssociatedWires) {
				var pathSuccess:Boolean = associatedWire.wire.attemptPath(associatedWire.connection.origin.clone(),
																		  associatedWire.connection.points[0].add(deltaSinceRoot), true, true);
				if (!pathSuccess) {
					rollback();
					for each (var wireHistory:WireHistory in history)
						wireHistory.revertBasic();
					return false;
				}
				
				Wire.place(associatedWire.wire);
				rollbackWires.push(associatedWire.wire);
			}
			
			rollback();
			return true;
		}
		
		
		
		public function generateAssociatedWires():void {
			if (!U.ASSOC_WIRES)
				return;
			
		//2. to gen, make an empty list of associates (containing a ConnectedCarrier & a wire ref apiece). foreach ConnectedCarrier
			singlyAssociatedWires = new Vector.<AssociatedWire>;
			multiplyAssociatedWires = new Vector.<AssociatedWire>;
			newAssociatedWires = new Vector.<Wire>;
			
			connections = findConnections();
			
			function generateAssociatedWire(connection:Connection):void {
				var wire:Wire = new Wire(connection.points[0]);
				singlyAssociatedWires.push(new AssociatedWire(wire, connection));
				newAssociatedWires.push(wire);
			}
			
			for each (var connection:Connection in connections) {
				//i. if it's a port, assert only one connection loc, then gen a new wire.
				if (connection.carrier is Port) {
					if (connection.points.length > 1)
						throw new Error("Port connected at multiple locations!");
					generateAssociatedWire(connection);
					continue;
				}
				
				if (connection.carrier is Wire) {
					var wire:Wire = connection.carrier as Wire;
					if (connection.points.length > 1) {
						//just add it to the list of associates directly.
						Wire.remove(wire); //dubious !
						multiplyAssociatedWires.push(new AssociatedWire(wire, connection));
					} else if (wire.isEndpoint(connection.points[0])) {
						Wire.remove(wire);
						singlyAssociatedWires.push(new AssociatedWire(wire, connection));
					} else
						//if there's only one connection loc, gen a new wire.
						generateAssociatedWire(connection);
					continue;
				}
				
				throw new Error("Unknown carrier type!");
			}
		}
		
		//1. for each port & wire in the bloc, note down all the distinct things that they connect to (universally), and the distinct points at which each is connected.
			//list of Connections; each has an externally associated carrier & a list of connection points. no primary carrier; that's irrelevant.
		public function findConnections():Vector.<Connection> {
			var connections:Vector.<Connection> = new Vector.<Connection>;
			var carrier:Carrier;
			
			function addConnection(carrier:Carrier, loc:Point):void {
				for each (var connection:Connection in connections)
					if (connection.carrier == carrier) {
						connection.points.push(loc);
						return;
					}
				connections.push(new Connection(carrier, loc));
			}
			
			for each (var module:Module in modules)
				for each (var portLayout:PortLayout in module.layout.ports)
					for each (carrier in portLayout.port.connections)
						if (!carrierIncluded(carrier))
							addConnection(carrier, portLayout.Loc);
			
			for each (var wire:Wire in wires)
				for each (carrier in wire.connections)
					if (!carrierIncluded(carrier))
						addConnection(carrier, wire.connectionLoc(carrier));
			
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
		
		public function get allAssociatedWires():Vector.<AssociatedWire> {
			var allAssociatedWires:Vector.<AssociatedWire> = new Vector.<AssociatedWire>;
			for each (var wireList:Vector.<AssociatedWire> in [singlyAssociatedWires, multiplyAssociatedWires])
				for each (var assocWire:AssociatedWire in wireList)
					allAssociatedWires.push(assocWire);
			return allAssociatedWires;
		}
	}

}