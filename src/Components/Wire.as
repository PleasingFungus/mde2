package Components {
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Wire implements Carrier {
		
		public var path:Vector.<Point>;
		public var exists:Boolean;
		public var FIXED:Boolean;
		public var source:Port;
		public var connections:Vector.<Carrier>;
		
		private var lastPathEnd:Point; //microoptimization in attemptPathTo
		private var oldConnections:Vector.<Carrier>;
		protected var constrained:Boolean = true;
		
		public function Wire(Start:Point) {
			path = new Vector.<Point>;
			path.push(Start);
			
			connections = new Vector.<Carrier>;
			exists = true;
		}
		
		public function attemptPathTo(target:Point):Boolean {
			if (lastPathEnd && target.equals(lastPathEnd)) return false; //ehh
			
			var start:Point = path[0]; //amusing variant: start = path[path.length - 1]?
			path = new Vector.<Point>;
			path.push(start);
			
			var pathEnd:Point = path[path.length - 1];
			var nextPoint:Point;
			for (var delta:Point = target.subtract(pathEnd); delta.x || delta.y; delta = target.subtract(pathEnd)) {
				nextPoint = new Point(pathEnd.x + (delta.x > 0 ? 1 : -1), pathEnd.y);
				if ((!delta.x || !mayMoveThrough(nextPoint)) && delta.y)
					nextPoint = new Point(pathEnd.x, pathEnd.y + (delta.y > 0 ? 1 : -1));
				
				if (constrained && U.state.lineContents(pathEnd, nextPoint))
					break;
				
				path.push(pathEnd = nextPoint);
			}
			
			while (constrained && path.length > 1 && !validPosition())
				path.pop();
			
			lastPathEnd = path[path.length - 1];
			return true;
		}
		
		protected function mayMoveThrough(p:Point):Boolean {
			return true;
		}
		
		protected function validPosition():Boolean {
			var source:Port = null;
			for each (var carriers:Vector.<Carrier> in [U.state.carriersAtPoint(path[0]), U.state.carriersAtPoint(path[path.length - 1])])
				if (carriers)
					for each (var carrier:Carrier in carriers) {
						var carrierSource:Port = carrier.getSource();
						if (carrierSource) {
							if (!source)
								source = carrierSource;
							else if (source != carrierSource)
								return false;
						}
					}
			return true;
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
			if (!oldConnections)
				checkForConnections();
			else
				restoreOldConnections();
			if (source)
				propagateSource();
			
			U.state.wires.push(this);
			for (var i:int = 0; i < path.length - 1; i++)
				U.state.setLineContents(path[i], path[i + 1], this);
			for each (var p:Point in path)
				U.state.addCarrierAtPoint(p, this);
			
			return true;
		}
		
		protected function checkForConnections():void {
			log(this +" adding connections");
			addConnections(U.state.carriersAtPoint(path[0]));
			addConnections(U.state.carriersAtPoint(path[path.length - 1]));
		}
		
		protected function restoreOldConnections():void {
			connections = oldConnections;
			for each (var connection:Carrier in connections)
				joinConnection(connection);
			oldConnections = null; //un-needed, but aesthetically pleasing
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
		
		
		
		
		public static function remove(wire:Wire):Boolean {
			return wire.deregister();
		}
		
		protected function deregister():Boolean {
			if (FIXED)
				return false;
			
			for each (var p:Point in path)
				U.state.removeCarrierFromPoint(p, this);
			for (var i:int = 0; i < path.length - 1; i++)
				U.state.setLineContents(path[i], path[i + 1], null);
			U.state.wires.splice(U.state.wires.indexOf(this), 1);
			exists = false;
			
			var connection:Carrier;
			for each (connection in connections)
				connection.removeConnection(this);
			if (source) {
				for each (connection in connections)
					connection.resetSource();
				source.propagateSource(); //re-propagate
			}
			
			oldConnections = connections;
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
			if (U.DEBUG && U.DEBUG_PRINT_CONNECTIONS)
				C.log(args);
		}
		
		public function saveString():String {
			var out:String = '';
			for each (var p:Point in path)
				out += p.x + U.COORD_DELIM + p.y + U.POINT_DELIM;
			return out.substr(0, out.length - 1) + U.SAVE_DELIM;
		}
		
		public static function fromString(str:String):Wire {
			var path:Vector.<Point> = new Vector.<Point>;
			for each (var strPoint:String in str.split(U.POINT_DELIM)) {
				var strCoords:Array = strPoint.split(U.COORD_DELIM);
				path.push(new Point(int(strCoords[0]), int(strCoords[1])));
			}
			var wire:Wire = new Wire(path[0]);
			wire.path = path;
			return wire;
		}
	}
}