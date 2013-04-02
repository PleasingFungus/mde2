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
		public function Bloc(modules:Vector.<Module>, wires:Vector.<Wire>) {
			this.modules = modules;
			this.wires = wires;
			//TODO: set origin
		}
		
		public function validPosition(p:Point):Boolean {
			//TODO
			return false;
		}
		
		public function place(p:Point):Boolean {
			//TODO
			return false;
		}
		
		public function uproot(p:Point):Boolean {
			//TODO
			return false;
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
		}
		
	}

}