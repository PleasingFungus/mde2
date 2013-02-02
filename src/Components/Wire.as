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
		
		protected var lastPathEnd:Point; //microoptimization in attemptPathTo
		
		public function Wire(Start:Point) {
			path = new Vector.<Point>;
			path.push(Start);
			
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
				if (delta.x)
					nextPoint = new Point(pathEnd.x + U.GRID_DIM * (delta.x > 0 ? 1 : -1), pathEnd.y);
				else
					nextPoint = new Point(pathEnd.x, pathEnd.y + U.GRID_DIM * (delta.y > 0 ? 1 : -1));
				
				if (U.state.lineContents(pathEnd, nextPoint))
					break;
				
				path.push(pathEnd = nextPoint);
			}
			
			lastPathEnd = path[path.length - 1];
			return true;
		}
		
		protected function endDrawing():void {
			while (path.length > 1 && !validPosition())
				path.pop();
			if (path.length > 1) {
				exists = true;
				connections = new Vector.<Carrier>;
				checkForConnections();
			}
		}
		
		protected function validPosition():Boolean {
			//TODO
			return true;
			
			/*var startConnector:Carrier = U.carrierAt(path[0]);
			var endConnector:Carrier = U.carrierAt(path[path.length - 1]);
			return !startConnector || !endConnector || !startConnector.getSource() || !endConnector.getSource();*/
		}
		
		protected function checkForConnections():void {	
			//TODO
			
			//addConnection(U.carrierAt(path[0]));
			//addConnection(U.carrierAt(path[path.length - 1]));
		}
		
		public static function place(wire:Wire):Boolean {
			//TODO
			
			wire.endDrawing();
			if (!wire.path.length) {
				wire.exists = false;
				return false;
			}
			
			U.state.wires.push(wire);
			for (var i:int = 0; i < wire.path.length - 1; i++)
				U.state.setLineContents(wire.path[i], wire.path[i + 1], wire);
			//U.connectionPoints.push(wire);
			//for each (var otherWire:Wire in U.wires)
				//otherWire.checkReadd(wire);
			return true;
		}
		
		public static function remove(wire:Wire):Boolean {
			//TODO
			
			if (wire.FIXED)
				return false;
			
			//U.connectionPoints.splice(U.connectionPoints.indexOf(wire), 1);
			for (var i:int = 0; i < wire.path.length - 1; i++)
				U.state.setLineContents(wire.path[i], wire.path[i + 1], null);
			U.state.wires.splice(U.state.wires.indexOf(wire), 1);
			wire.exists = false;
			
			for each (var other:Carrier in wire.connections)
				other.removeConnection(wire);
			
			var source:Port = wire.source;
			wire.resetSource();
			if (source && source.connection)
				source.connection.setSource(source); //re-propagate
			
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
		
		public function removeConnection(connection:Carrier):void {
			connections.splice(connections.indexOf(connection), 1);
		}
		
		public function resetSource():void {
			if (!source) return;
			
			source = null;
			for each (var carrier:Carrier in connections)
				carrier.resetSource();
		}
		
		public function setSource(source:Port):void {
			source = source;
		}
		
		public function addConnection(connection:Carrier):void {
			
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