package Layouts {
	import Components.Wire;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flixel.FlxSprite;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InternalControlWire extends InternalWire {
		
		public var tuple:NodeTuple;
		public var dependent:InternalWire;
		protected var intersectPoint:int;
		public function InternalControlWire(Root:InternalNode, Tuple:NodeTuple, wires:Vector.<InternalWire>) {
			tuple = Tuple;
			
			dependent = findDependent(wires);
			dependent.reverseControlTruncation = tuple.reverseTruncate;
			
			intersectPoint = Math.min(Math.floor(dependent.path.length / 2), Tuple.suggestedIntersect);
			//C.log(dependent.path.length, intersectPoint);
			var midpoint:Point = dependent.path[intersectPoint];
			super(Root.Loc, midpoint, Root.parent.layout.getBounds(),
				  function enabled():Boolean { return exists; },
				  Root.getValue);
			
			fullControl = true;
		}
		
		override public function update():void {
			if (tuple.isEnabled()) {
				controlPoint = C.INT_NULL;
				dependent.controlPoint = C.INT_NULL;
			} else {
				controlPoint = 0;
				dependent.controlPoint = intersectPoint;
			}
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