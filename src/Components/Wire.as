package Components {
	import flash.geom.Point;
	import Modules.Module;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Wire implements Carrier {
		
		public var path:Vector.<Point>;
		public var deployed:Boolean;
		public var exists:Boolean;
		public var FIXED:Boolean;
		public var source:Port;
		public var connections:Vector.<Carrier>;
		
		private var lastPathEnd:Point; //microoptimization in attemptPathTo
		protected var constrained:Boolean = true;
		
		public function Wire(Start:Point) {
			path = new Vector.<Point>;
			path.push(Start);
			
			connections = new Vector.<Carrier>;
			exists = true;
		}
		
		public function attemptPathTo(target:Point, smartPathEnabled:Boolean = false):Boolean {
			if (lastPathEnd && target.equals(lastPathEnd)) return false; //ehh
			
			var newPath:Vector.<Point>;
			if (smartPathEnabled)
				newPath = smartPath(path[0], target);
			if (!newPath)
				newPath = dumbPath(path[0], target);
			path = newPath;
			
			while (constrained && path.length > 1 && !validPosition())
				path.pop();
			
			lastPathEnd = path[path.length - 1];
			return true;
		}
		
		protected function smartPath(start:Point, target:Point):Vector.<Point> {
			if (constrained && U.state.grid.objTypeAtPoint(start) == Module)
				return null;
			
			var manhattan:int = C.manhattan(start, target);
			
			var toCheck:Array = [{
				'point' : start,
				'distFromStart' : 0,
				'distToEnd' : manhattan,
				'totalDist' : manhattan,
				'parent' : null,
				'delta' : new Point
			}];
			var checked:Array = [];
			
			var deltas:Array = [new Point( -1, 0), new Point(0, -1), new Point(1, 0), new Point(0, 1)];
			
			while (toCheck.length) {
				var curNode:Object = toCheck.pop();
				var curPoint:Point = curNode.point;
				
				if (curPoint.equals(target) || checked.length > 80)
					break;
				
				for each (var delta:Point in deltas) {
					var nextPoint:Point = curPoint.add(delta);
				
					if (constrained && (U.state.grid.lineContents(curPoint, nextPoint) ||
										(!nextPoint.equals(target) && !mayMoveThrough(nextPoint, delta))))
						continue;
					
					var alreadyFound:Boolean = false;
					for each (var checkedNode:Object in checked)
						if (nextPoint.equals(checkedNode.point)) {
							alreadyFound = true;
							break;
						}
					if (alreadyFound)
						continue;
					
					var nextNode:Object = {
						'point' : nextPoint,
						'distFromStart' : curNode.distFromStart + 1,// + (delta.equals(curNode.delta) ? 1 : 1.25),
						'distToEnd' : C.manhattan(nextPoint, target),
						'parent' : curNode,
						'delta' : delta
					}
					nextNode['totalDist'] = nextNode.distFromStart + nextNode.distToEnd;
					
					for each (var foundNode:Object in toCheck)
						if (nextPoint.equals(foundNode.point)) {
							alreadyFound = true;
							if (foundNode.totalDist > nextNode.totalDist) {
								foundNode.distFromStart = nextNode.distFromStart;
								foundNode.totalDist = nextNode.totalDist;
								foundNode.parent = nextNode.parent;
							}
							break;
						}
					if (alreadyFound)
						continue;
					
					for (var i:int = 0; i < toCheck.length; i++)
						if (toCheck[i].distToEnd <= nextNode.distToEnd)
							break;
					toCheck.splice(i, 0, nextNode);
				}
				
				checked.push(curNode);
			}
			
			if (!curPoint.equals(target)) {
				if (!toCheck.length) //completely blocked
					return null;
				//try to salvage what you can of the path (find the closest node checked)
				curNode = checked[0];
				for (i = 1; i < checked.length; i++) {
					var curDist:int = curNode.totalDist;
					var checkedDist:int = checked[i].totalDist;
					if (checkedDist < curDist || (checkedDist == curDist && checked[i].distFromStart < curNode.distFromStart))
						curNode = checked[i];
				}
			}
			
			var reversedPath:Vector.<Point> = new Vector.<Point>;
			do {
				reversedPath.push(curNode.point);
				curNode = curNode.parent;
			} while (curNode);
			
			var path:Vector.<Point> = new Vector.<Point>;
			while (reversedPath.length)
				path.push(reversedPath.pop());
			
			if (curPoint.equals(target))
				return path;
			
			//try to dumbpath to continue
			var pathToEnd:Vector.<Point> = dumbPath(path[path.length - 1], target);
			for (i = 1; i < pathToEnd.length; i++)
				path.push(pathToEnd[i]);
			return path;
		}
		
		protected function dumbPath(start:Point, target:Point):Vector.<Point> {
			var path:Vector.<Point> = new Vector.<Point>;
			path.push(start);
			if (constrained && U.state.grid.objTypeAtPoint(start) == Module)
				return path;
			
			var pathEnd:Point = path[path.length - 1];
			var nextPoint:Point;
			for (var delta:Point = target.subtract(pathEnd); delta.x || delta.y; delta = target.subtract(pathEnd)) {
				var nextDelta:Point = delta.x > 0 ? RIGHT_DELTA : LEFT_DELTA;
				nextPoint = pathEnd.add(nextDelta);
				if ((!delta.x || !mayMoveThrough(nextPoint, nextDelta)) && delta.y) {
					nextDelta = delta.y > 0 ? DOWN_DELTA : UP_DELTA;
					nextPoint = pathEnd.add(nextDelta);
				}
				
				if (constrained && (U.state.grid.lineContents(pathEnd, nextPoint) || U.state.grid.objTypeAtPoint(nextPoint) == Module))
					break;
				
				path.push(pathEnd = nextPoint);
				
				if (!mayMoveThrough(nextPoint, nextDelta))
					break;
			}
			
			return path;
		}
		
		protected function mayMoveThrough(p:Point, delta:Point):Boolean {
			var objType:Class = U.state.grid.objTypeAtPoint(p);
			if (objType == null)
				return true;
			if (objType == Module)
				return false;
			
			var carriers:Vector.<Carrier> = U.state.grid.carriersAtPoint(p);
			for each (var carrier:Carrier in carriers)
				if (carrier is Port)
					return false;
			
			var otherWire:Wire = U.state.grid.lineContents(p, p.add(delta));
			if (otherWire)
				return false;
			
			return true;
		}
		
		public function validPosition():Boolean {
			if (U.state.grid.objTypeAtPoint(path[0]) == Module || U.state.grid.objTypeAtPoint(path[path.length -1]) == Module)
				return false;
			
			var source:Port = null;
			for each (var p:Point in path) {
				var carriers:Vector.<Carrier> = U.state.grid.carriersAtPoint(p);
				if (!carriers)
					continue;
					
				var pointIsEndpoint:Boolean = isEndpoint(p);
				for each (var carrier:Carrier in carriers) {
					if (!pointIsEndpoint && !carrier.isEndpoint(p))
						continue;
					
					var carrierSource:Port = carrier.getSource();
					if (carrierSource) {
						if (!source)
							source = carrierSource;
						else if (source != carrierSource)
							return false;
					}
				}
			}
			return true;
		}
		
		public function collides():Boolean {			
			for (var i:int = 0; i < path.length - 1; i++) {
				var p:Point = path[i];
				var next:Point = path[i + 1];
				var delta:Point = next.subtract(p);
				if (!mayMoveThrough(next, delta))
					return true;
			}
			
			return !validPosition();
		}
		
		
		
		
		public static function place(wire:Wire):Boolean {
			return wire.register();
		}
		
		protected function register():Boolean {
			if (path.length < 2) {
				exists = false;
				return false;
			}
			
			exists = true;
			deployed = true;
			checkForConnections();
			if (source)
				propagateSource();
			
			U.state.wires.push(this);
			for (var i:int = 0; i < path.length - 1; i++)
				U.state.grid.setLineContents(path[i], path[i + 1], this);
			for each (var p:Point in path)
				U.state.grid.addCarrierAtPoint(p, this);
			
			return true;
		}
		
		protected function checkForConnections():void {
			log(this +" adding connections");
			addConnections(U.state.grid.carriersAtPoint(path[0]));
			addConnections(U.state.grid.carriersAtPoint(path[path.length - 1]));
			checkForEndpoints();
		}
		
		protected function checkForEndpoints():void {
			for (var i:int = 1; i < path.length - 1; i++)
				for each (var connection:Carrier in U.state.grid.carriersAtPoint(path[i])) {
					if (connection == this || connections.indexOf(connection) != -1 || !connection.isEndpoint(path[i]))
						continue;
					addConnection(connection);
					joinConnection(connection);
				}
		}
		
		public function addConnections(carriers:Vector.<Carrier>):void {
			if (!carriers)
				return;
			
			for each (var connection:Carrier in carriers) {
				if (connection == this || connections.indexOf(connection) != -1)
					continue;
				
				addConnection(connection);
				joinConnection(connection);
			}
		}
		
		private function joinConnection(connection:Carrier):void {
			connection.addConnection(this);
			if (connection.getSource()) {
				if (!this.source)
					this.source = connection.getSource();
				else if (this.source != connection.getSource())
					throw new Error("Multiple sources in one mesh!");
			}
		}
		
		protected function propagateSource():void {
			for each (var connection:Carrier in connections) {
				if (!connection.getSource())
					connection.setSource(source);
				else if (connection.getSource() != this.source)
					throw new Error("Multiple sources in one mesh!");
			}
		}
		
		public function isEndpoint(p:Point):Boolean {
			return path[0].equals(p) || path[path.length - 1].equals(p);
		}
		
		
		
		
		public static function remove(wire:Wire):Boolean {
			return wire.deregister();
		}
		
		protected function deregister():Boolean {
			if (FIXED || path.length < 2)
				return false;
			
			for each (var p:Point in path)
				U.state.grid.removeCarrierFromPoint(p, this);
			for (var i:int = 0; i < path.length - 1; i++)
				U.state.grid.setLineContents(path[i], path[i + 1], null);
			U.state.wires.splice(U.state.wires.indexOf(this), 1);
			exists = false;
			deployed = false;
			
			var connection:Carrier;
			for each (connection in connections)
				connection.removeConnection(this);
			if (source) {
				for each (connection in connections)
					connection.resetSource();
				source.propagateSource(); //re-propagate
			}
			
			connections = new Vector.<Carrier>; //un-needed, but aesthetically pleasing
			source = null;
			
			return true;
		}
		
		//Carrier implementations
		
		public function getConnections():Vector.<Carrier> {
			return connections;
		}
		
		public function isSource():Boolean {
			return false;
		}
		
		public function getSource():Port {
			return source;
		}
		
		public function setSource(Source:Port):void {
			log("Set " + Source + " as source for " + this);
			source = Source;
			propagateSource();
		}
		
		public function resetSource():void {
			if (!source) return;
			
			source = null;
			log("Unset source for " + this);
			for each (var carrier:Carrier in connections)
				carrier.resetSource();
		}
		
		public function addConnection(connection:Carrier):void {
			log(this +" added a connection with " + connection);
			connections.push(connection);
		}
		
		public function removeConnection(connection:Carrier):void {
			log(this + " removed its connection with " + connection);
			connections.splice(connections.indexOf(connection), 1);
		}
		
		public function toString():String {
			return "WIRE: " + path[0].x + ", " + path[0].y + " -> " + path[path.length - 1].x + ", " + path[path.length -1].y;
		}
		
		protected function log(...args):void {
			if (U.DEBUG_PRINT_CONNECTIONS)
				C.log(args);
		}
		
		public function saveString():String {
			var out:String = '';
			for each (var p:Point in path)
				out += p.x + U.COORD_DELIM + p.y + U.POINT_DELIM;
			return out.substr(0, out.length - 1) + U.SAVE_DELIM;
		}
		
		public static function fromString(str:String):Wire {
			if (!str.length) return null;
			var path:Vector.<Point> = new Vector.<Point>;
			for each (var strPoint:String in str.split(U.POINT_DELIM)) {
				var strCoords:Array = strPoint.split(U.COORD_DELIM);
				path.push(new Point(int(strCoords[0]), int(strCoords[1])));
			}
			var wire:Wire = new Wire(path[0]);
			wire.path = path;
			return wire;
		}
		
		private const LEFT_DELTA:Point = new Point( -1, 0);
		private const RIGHT_DELTA:Point = new Point( 1, 0);
		private const UP_DELTA:Point = new Point( 0, -1);
		private const DOWN_DELTA:Point = new Point( 0, 1);
	}
}