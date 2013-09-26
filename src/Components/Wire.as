package Components {
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import Layouts.PortLayout;
	import Modules.Module;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Wire implements Carrier {
		
		private var _path:Vector.<Point>;
		protected var pather:Pather;
		public var deployed:Boolean;
		public var exists:Boolean;
		public var FIXED:Boolean;
		public var source:Port;
		public var connections:Vector.<Carrier>;
		public var cacheInvalid:Boolean;
		
		private var lastPathEnd:Point; //microoptimization in attemptPathTo
		public var constrained:Boolean = true;
		
		public function Wire(Start:Point) {
			path = new Vector.<Point>;
			path.push(Start);
			
			connections = new Vector.<Carrier>;
			exists = true;
			pather = makePather();
		}
		
		protected function makePather():Pather {
			return new WirePather(this);
		}
		
		public function attemptPathTo(target:Point, smartPathEnabled:Boolean = false, force:Boolean = false):Boolean {
			return attemptPath(path[0], target, smartPathEnabled, force);
		}
		
		public function attemptPath(start:Point, end:Point, smartPathEnabled:Boolean = false, force:Boolean = false):Boolean {
			if (lastPathEnd && end.equals(lastPathEnd) && !force) return true; //ehh
			
			var newPath:Vector.<Point>;
			if (smartPathEnabled)
				newPath = smartPath(start, end);
			if (!newPath)
				newPath = pather.dumbPath(start, end);
			path = newPath;
			cacheInvalid = true;
			
			var pathSucceeded:Boolean = true;
			while (constrained && path.length > 1 && !validPosition()) {
				path.pop();
				pathSucceeded = false;
			}
			
			lastPathEnd = this.end;
			return pathSucceeded && this.end.equals(end);
		}
		
		protected function smartPath(start:Point, target:Point):Vector.<Point> {
			if (constrained && U.state.grid.moduleContentsAtPoint(start))
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
				
					if (constrained && ((!target.equals(nextPoint) && !pather.validPoint(nextPoint, delta))
										|| !pather.validTransition(curPoint, nextPoint)))
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
				var p:Point = curNode.point;
				reversedPath.push(p);
				curNode = curNode.parent;
			} while (curNode);
			
			var path:Vector.<Point> = new Vector.<Point>;
			while (reversedPath.length)
				path.push(reversedPath.pop());
			
			if (curPoint.equals(target))
				return path;
			
			//try to dumbpath to continue
			var pathToEnd:Vector.<Point> = pather.dumbPath(path[path.length - 1], target);
			for (i = 1; i < pathToEnd.length; i++)
				path.push(pathToEnd[i]);
			return path;
		}
		
		public function validPosition():Boolean {
			if (U.state.grid.moduleContentsAtPoint(path[0]) || U.state.grid.moduleContentsAtPoint(path[path.length -1]))
				return false;
			
			var source:Port = null;
			for each (var p:Point in path) {
				var carriers:Vector.<Carrier> = U.state.grid.carriersAtPoint(p);
				if (!carriers)
					continue;
				
				var pIsEndpoint:Boolean = isEndpoint(p);
				for each (var carrier:Carrier in carriers) {
					if (!pIsEndpoint && !carrier.isEndpoint(p))
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
			for (var i:int = 0; i < path.length - 2; i++) {
				var p:Point = path[i];
				var next:Point = path[i + 1];
				if (!pather.validTransition(p, next))
					return true;
			}
			
			return !validPosition();
		}
		
		
		
		
		public static function place(wire:Wire):Boolean {
			return wire.register();
		}
		
		protected function register():Boolean {
			if (deployed)
				return false;
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
		
		public function getPotentialConnections():Vector.<Carrier> {
			var potentialConnections:Vector.<Carrier> = new Vector.<Carrier>;
			for each (var p:Point in path) {
				var carriers:Vector.<Carrier> = U.state.grid.carriersAtPoint(p);
				if (carriers)
					for each (var connection:Carrier in carriers)
						if (connection != this && potentialConnections.indexOf(connection) == -1 && (isEndpoint(p) || connection.isEndpoint(p)))
							potentialConnections.push(connection);
			}
			return potentialConnections;
		}
		
		protected function checkForConnections():void {
			log(this +" adding connections");
			addConnections(U.state.grid.carriersAtPoint(start));
			addConnections(U.state.grid.carriersAtPoint(end));
			checkForEndpoints();
			//TODO: for each (var connection:Carrier in getPotentialConnections()) { addConnection(connection); joinConnection(connection); }
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
		
		public function connectionLoc(carrier:Carrier):Point {
			if (carrier is Port)
				return (carrier as Port).Loc;
			if (carrier is Wire) {
				var wire:Wire = carrier as Wire;
				var point:Point, endpoint:Point;
				for each (endpoint in [start, end])
					for each (point in wire.path)
						if (point.equals(endpoint))
							return endpoint;
				for each (endpoint in [start, end])
					for each (point in path)
						if (point.equals(endpoint))
							return endpoint;
				throw new Error("No known connection!");
			}
			throw new Error("Unknown carrier type!");
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
			return start.equals(p) || end.equals(p);
		}
		
		
		
		
		public static function remove(wire:Wire):Boolean {
			return wire.deregister();
		}
		
		protected function deregister():Boolean {
			if (FIXED || !deployed || path.length < 2)
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
		
		public function cleanup():void {
			deployed = false;
			exists = false;
			connections = new Vector.<Carrier>; //un-needed, but aesthetically pleasing
			source = null;
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
		
		public function shift(delta:Point):Wire {
			if (deployed)
				throw new Error("Cannot modify path of a deployed wire!");
			for each (var p:Point in path) {
				p.x += delta.x;
				p.y += delta.y;
			}
			return this;
		}
		
		
		
		public static function wireBetween(Start:Point, End:Point):Wire {
			var w:Wire = new Wire(Start);
			w.constrained = false;
			if (!w.attemptPathTo(End, true))
				throw new Error("Wire failed to path!");
			w.constrained = true;
			return w;
		}
		
		
		
		
		public function toString():String {
			return "WIRE: " + start.x + ", " + start.y + " -> " + end.x + ", " + end.y;
		}
		
		protected function log(...args):void {
			if (DEBUG.PRINT_CONNECTIONS)
				C.log(args);
		}
		
		public function saveString():String {
			var pointStrings:Vector.<String> = new Vector.<String>;
			for each (var p:Point in path)
				pointStrings.push(p.x + U.COORD_DELIM + p.y);
			return pointStrings.join(U.POINT_DELIM);
		}
		
		public function getBytes():ByteArray {
			//format: byte-length (int), start (int, int), h-delta (int), v-delta (int) ...
			var bytes:ByteArray = new ByteArray;
			
			var deltas:Vector.<int> = new Vector.<int>;
			var switchbackPoint:Point = path[0];
			
			function addDeltaTo(p:Point):void {
				var lastDelta:Point = p.subtract(switchbackPoint);
				if (!deltas.length && lastDelta.y)
					deltas.push(0);
				deltas.push(lastDelta.x ? lastDelta.x : lastDelta.y);
				switchbackPoint = p;
			}
			
			for (var i:int = 1; i < path.length; i++) {
				var currentPoint:Point = path[i];
				var delta:Point = currentPoint.subtract(switchbackPoint);
				if (delta.x && delta.y) {
					var lastPoint:Point = path[i - 1];
					addDeltaTo(lastPoint);
				}
			}
			addDeltaTo(path[path.length - 1]);
			
			var length:int = 4 + 4 + 4 + deltas.length * 4;
			bytes.writeInt(length);
			bytes.writeInt(path[0].x);
			bytes.writeInt(path[0].y);
			for each (var deltaV:int in deltas)
				bytes.writeInt(deltaV);
			
			if (bytes.length != length)
				throw new Error("Error in calculating length!");
			
			if (FlxG.debug) {
				bytes.position = 4;
				var loadWire:Wire = fromBytes(bytes, bytes.length);
				if (!equals(loadWire))
					throw new Error("Bad byte generation!");
			}
			
			bytes.position = 0;
			return bytes;
		}
		
		public function equals(wire:Wire):Boolean {
			if (!wire.path.length == path.length)
				return false;
			for (var i:int = 0; i < path.length; i++)
				if (!path[i].equals(wire.path[i]))
					return false;
			return true;
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
		
		public static function fromBytes(bytes:ByteArray, end:int):Wire {
			var start:Point = new Point(bytes.readInt(), bytes.readInt());
			var wire:Wire = new Wire(start);
			var horizontal:Boolean = true;
			while (bytes.position < end) {
				var delta:int = bytes.readInt();
				var absoluteDelta:int = Math.abs(delta);
				var switchbackPoint:Point = wire.path[wire.path.length - 1];
				
				for (var absd:int = 1; absd <= absoluteDelta; absd++) {
					var del:int = (delta > 0 ? 1 : -1) * absd;
					if (horizontal)
						wire.path.push(new Point(switchbackPoint.x + del, switchbackPoint.y));
					else
						wire.path.push(new Point(switchbackPoint.x, switchbackPoint.y + del));
				}
				
				horizontal = !horizontal;
			}
			return wire;
		}
		
		public static function wiresFromBytes(bytes:ByteArray, end:int):Vector.<Wire> {
			var wires:Vector.<Wire> = new Vector.<Wire>;
			while (bytes.position < end) {
				var wireByteLength:int = bytes.readInt();
				var wireEnd:int = bytes.position - 4 + wireByteLength;
				wires.push(fromBytes(bytes, wireEnd));
				if (bytes.position != wireEnd)
					throw new Error("Unread data in wire load!");
			}
			return wires;
		}
		
		public function get path():Vector.<Point> {
			return _path;
		}
		
		public function set path(p:Vector.<Point>):void {
			if (deployed)
				throw new Error("Cannot modify path of a deployed wire!");
			_path = p;
		}
		
		public function get start():Point {
			return path[0];
		}
		
		public function get end():Point {
			return path[path.length - 1];
		}
		
		private const LEFT_DELTA:Point = new Point( -1, 0);
		private const RIGHT_DELTA:Point = new Point( 1, 0);
		private const UP_DELTA:Point = new Point( 0, -1);
		private const DOWN_DELTA:Point = new Point( 0, 1);
	}
}