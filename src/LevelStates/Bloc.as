package LevelStates {
	import Components.Wire;
	import flash.geom.Point;
	import Modules.Module;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Bloc {
		
		public var modules:Vector.<Module>;
		public var wires:Vector.<Wire>;
		public var origin:Point;
		public var rooted:Boolean;
		public function Bloc(modules:Vector.<Module>, wires:Vector.<Wire>, Rooted:Boolean = true) {
			this.modules = modules;
			this.wires = wires;
			rooted = Rooted;
		}
		
		private var wasValid:Boolean;
		public function validPosition(p:Point):Boolean {
			if (!moveTo(p))
				return wasValid;
			
			for each (var module:Module in modules)
				if (!module.validPosition)
					return wasValid = false;
			for each (var wire:Wire in wires)
				if (!wire.validPosition())
					return wasValid = false;
			return wasValid = true;
		}
		
		public function place(p:Point):Boolean {
			moveTo(p);
			rooted = true;
			
			for each (var wire:Wire in wires)
				Wire.place(wire);
			for each (var module:Module in modules)
				module.register();
			
			return true;
		}
		
		public function remove(p:Point):Boolean {
			for each (var module:Module in modules)
				module.deregister()//.exists = true;
			for each (var wire:Wire in wires)
				Wire.remove(wire);
			
			rooted = false;
			origin = p;
			return true;
		}
		
		private function moveTo(p:Point):Boolean {
			if (origin.equals(p))
				return false;
			
			var delta:Point = p.subtract(origin);
			
			for each (var module:Module in modules) {
				module.x += delta.x;
				module.y += delta.y;
			}
			
			for each (var wire:Wire in wires)
				for each (var wirePoint:Point in wire.path) {
					wirePoint.x += p.x;
					wirePoint.y += p.y;
				}
			
			origin = p;
			return true;
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
		
		public static function fromModules(modules:Vector.<Module>, allWires:Vector.<Wire>):Bloc {
			var connectedWires:Vector.<Wire> = new Vector.<Wire>;
			
			//TODO
			return null;
		}
		
	}

}