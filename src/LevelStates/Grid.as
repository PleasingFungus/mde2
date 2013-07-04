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
		
		private var horizontalLines:Dictionary;
		private var verticalLines:Dictionary;
		private var modulePoints:Dictionary;
		private var carrierPoints:Dictionary;
		
		public function Grid() {
			horizontalLines = new Dictionary;
			verticalLines = new Dictionary;
			modulePoints = new Dictionary;
			carrierPoints = new Dictionary;
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
			return carrierPoints[pointString(p)];
		}
		
		public function addCarrierAtPoint(p:Point, carrier:Carrier):void {
			var coordStr:String = pointString(p);
			
			if (modulePoints[coordStr])
				throw new Error("Can't add a wire inside a module!");
			
			var carriers:Vector.<Carrier> = carrierPoints[coordStr];
			if (!carriers) carriers = carrierPoints[coordStr] = new Vector.<Carrier>;

			carriers.push(carrier);
		}
		
		public function removeCarrierFromPoint(p:Point, carrier:Carrier):void {
			var coordStr:String = pointString(p);
			
			var carriers:Vector.<Carrier> = carrierPoints[coordStr];
			if (!carriers)
				throw new Error("Can't remove a wire where none's present!");
			
			var carrierIndex:int = carriers.indexOf(carrier);
			if (carrierIndex == -1)
				throw new Error("Can't remove a wire that's not present!");
			
			if (carriers.length == 1)
				carrierPoints[coordStr] = null;
			else
				carriers.splice(carrierIndex, 1);
		}
		
		public function setPointContents(p:Point, module:Module):void {
			var coordStr:String = pointString(p);
			if (carrierPoints[coordStr])
				throw new Error("Can't stomp on wires with a module!");
			if (module == null && !modulePoints[coordStr])
				throw new Error("Removing a module that wasn't present!"); //dubious;
			modulePoints[coordStr] = module;
		}
		
		public function moduleContentsAtPoint(p:Point):Module {
			return modulePoints[pointString(p)];
		}
		
		private function pointString(p:Point):String { return p.x + U.COORD_DELIM + p.y; }
		
	}

}