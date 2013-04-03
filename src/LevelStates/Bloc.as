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
		public var exists:Boolean;
		public function Bloc(modules:Vector.<Module>, wires:Vector.<Wire>, Rooted:Boolean = true) {
			this.modules = modules;
			this.wires = wires;
			rooted = Rooted;
			exists = true;
		}
		
		private var wasValid:Boolean;
		public function validPosition(p:Point):Boolean {
			moveTo(p)
			
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
			origin = p;
			return true;
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
			if (origin.equals(p))
				return false;
			
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
			
			origin = p;
			return true;
		}
		
		//public function copy():Bloc {
			//var modules:Vector.<Module> = new Vector.<Module>;
			//for each (var module:Module in this.modules)
				//modules.push(module.copy());
			//
			//var wires:Vector.<Wire> = new Vector.<Wire>;
			//for each (var wire:Wire in this.wires)
				//wires.push(wire.copy());
			//
			//return new Bloc(modules, wires, false);
		//}
		
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