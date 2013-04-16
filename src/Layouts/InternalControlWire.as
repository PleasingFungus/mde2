package Layouts {
	import Components.Wire;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flixel.FlxSprite;
	import Layouts.Nodes.InternalNode;
	import Layouts.Nodes.NodeTuple;
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
			dependent.truncatedByControlWireFromEnd = tuple.reverseTruncate;
			dependent.controlPointIndex = Math.min(Math.floor(dependent.path.length / 2), Tuple.suggestedIntersect);
			//C.log(dependent.path.length, intersectPoint);
			
			var midpoint:Point = dependent.path[dependent.controlPointIndex];
			super(Root.Loc, midpoint, Root.parent.layout.getBounds(),
				  function enabled():Boolean { return exists; },
				  Root.getValue);
		}
		
		override public function update():void {
			dependent.controlTruncated = dashed = !tuple.isEnabled();
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