package Layouts {
	import Components.Wire;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InternalControlWire extends InternalWire {
		
		public var tuple:NodeTuple;
		public var dependent:InternalWire;
		public function InternalControlWire(Root:InternalNode, Tuple:NodeTuple, wires:Vector.<InternalWire>) {
			tuple = Tuple;
			
			dependent = findDependent(wires);
			
			var midIndex:int = Math.min(Math.floor(dependent.path.length / 2), 3);
			C.log(dependent.path.length, midIndex);
			var midpoint:Point = dependent.path[midIndex];
			super(Root.Loc, midpoint, true, true,
				  function enabled():Boolean { return exists; },
				  Root.getValue);
		}
		
		override public function update():void {
			dependent.control = !tuple.isEnabled();
		}
		
		protected function findDependent(wires:Vector.<InternalWire>):InternalWire {
			var a:Point = tuple.a.Loc;
			var b:Point = tuple.b.Loc;
			for each (var wire:InternalWire in wires) {
				var wPath:Vector.<Point> = wire.path;
				if ((wPath[0].equals(a) && wPath[wPath.length - 1].equals(b)) ||
					(wPath[0].equals(b) && wPath[wPath.length - 1].equals(a)))
					return wire;
			}
			
			return null;
		}
		
	}

}