package LevelStates {
	import Components.Port;
	import Components.Wire;
	import flash.utils.Dictionary;
	import flash.geom.Point;
	import Components.Carrier;
	import Layouts.PortLayout;
	import Modules.Module;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class CurrentGrid {
		
		public var horizontalLines:Dictionary;
		public var verticalLines:Dictionary;
		public var saveString:String;
		public function CurrentGrid() {
			init();
		}
		
		public function init(SaveString:String = null):void {
			horizontalLines = new Dictionary;
			verticalLines = new Dictionary;
			saveString = SaveString;
			
			for each (var module:Module in U.state.modules)
				if (module.exists)
					for each (var port:PortLayout in module.layout.ports)
						if (port.port.isOutput)
							addMesh(port.Loc, port.port);
		}
		
		private function addMesh(start:Point, source:Port):void {
			var toCheck:Vector.<Point> = new Vector.<Point>;
			toCheck.push(new Point(start.x, start.y));
			var checked:Vector.<Point> = new Vector.<Point>;
			while (toCheck.length) {
				var p:Point = toCheck.pop();
				for each (var delta:Point in DELTAS) {
					var nextPoint:Point = p.add(delta);
					
					var lineContents:* = U.state.grid.lineContents(p, nextPoint);
					if (!(lineContents is Wire) ||
						(lineContents as Wire).source != source)
						continue;
					
					var old:Boolean = false;
					for each (var oldPoint:Point in toCheck)
						if (oldPoint.equals(nextPoint)) {
							old = true;
							break;
						}
					if (old)
						continue;
					for each (oldPoint in checked)
						if (oldPoint.equals(nextPoint)) {
							old = true;
							break;
						}
					if (old)
						continue;
					
					if (delta.x) {
						if (delta.x > 0)
							horizontalLines[p.x + U.COORD_DELIM + p.y] = 1;
						else
							horizontalLines[nextPoint.x + U.COORD_DELIM + nextPoint.y] = -1;
					} else {
						if (delta.y > 0)
							verticalLines[p.x + U.COORD_DELIM + p.y] = 1;
						else
							verticalLines[nextPoint.x + U.COORD_DELIM + nextPoint.y] = -1;
					}
					
					toCheck.push(nextPoint);
				}
				checked.push(p);
			}
		}
		
		public function lineToSpec(a:Point, b:Point):String {
			var horizontal:Boolean = a.x != b.x;
			var root:Point = horizontal ? a.x < b.x ? a : b : a.y < b.y ? a : b;
			return root.x + U.COORD_DELIM + root.y;
		}
		
		public function lineDirection(a:Point, b:Point):int {
			var horizontal:Boolean = a.x != b.x;
			return (horizontal ? horizontalLines : verticalLines)[lineToSpec(a, b)]
		}
		
		private const DELTAS:Array = [new Point( -1, 0), new Point(0, -1), new Point(1, 0), new Point(0, 1)];
	}

}