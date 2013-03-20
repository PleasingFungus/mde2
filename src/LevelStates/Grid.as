package LevelStates {
	import flash.utils.Dictionary;
	import flash.geom.Point;
	import Components.Carrier;
	import Modules.Module;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Grid {
		
		public var horizontalLines:Dictionary;
		public var verticalLines:Dictionary;
		public var carriersAtPoints:Dictionary;
		
		public function Grid() {
			horizontalLines = new Dictionary;
			verticalLines = new Dictionary;
			carriersAtPoints = new Dictionary;
		}
		
		
		public function lineToSpec(a:Point, b:Point):String {
			var horizontal:Boolean = a.x != b.x;
			var root:Point = horizontal ? a.x < b.x ? a : b : a.y < b.y ? a : b;
			return root.x + U.COORD_DELIM + root.y;
		}
		
		public function lineContents(a:Point, b:Point):* {
			var horizontal:Boolean = a.x != b.x;
			return (horizontal ? horizontalLines : verticalLines)[lineToSpec(a, b)]
		}
		
		public function setLineContents(a:Point, b:Point, newContents:*):* {
			var horizontal:Boolean = a.x != b.x;
			return (horizontal ? horizontalLines : verticalLines)[lineToSpec(a, b)] = newContents;
		}
		
		public function carriersAtPoint(p:Point):Vector.<Carrier> {
			return carriersAtPoints[p.x + U.COORD_DELIM + p.y];
		}
		
		public function addCarrierAtPoint(p:Point, carrier:Carrier):void {
			var coordStr:String = p.x + U.COORD_DELIM + p.y;
			var carriers:Vector.<Carrier> = carriersAtPoints[coordStr];
			if (!carriers) carriers = carriersAtPoints[coordStr] = new Vector.<Carrier>;
			carriers.push(carrier);
		}
		
		public function removeCarrierFromPoint(p:Point, carrier:Carrier):void {
			var coordStr:String = p.x + U.COORD_DELIM + p.y;
			var carriers:Vector.<Carrier> = carriersAtPoints[coordStr];
			carriers.splice(carriers.indexOf(carrier), 1);
			if (!carriers.length) carriersAtPoints[coordStr] = null;
		}
		
		public function objTypeAtPoint(p:Point):Class {
			var contents:* = carriersAtPoints[p.x + U.COORD_DELIM + p.y];
			if (!contents)
				return null;
			if (contents is Module)
				return Module;
			return Vector;
		}
		
		public function setPointContents(p:Point, module:Module):void {
			carriersAtPoints[p.x + U.COORD_DELIM + p.y] = module;
		}
		
		public function moduleContentsAtPoint(p:Point):Module {
			return carriersAtPoints[p.x + U.COORD_DELIM + p.y];
		}
		
	}

}