package Components {
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Wire implements Carrier {
		
		public var path:Vector.<Point>;
		public var exists:Boolean = true;
		public var FIXED:Boolean;
		public var source:Port;
		public var connections:Vector.<Carrier>;
		
		protected var lastPathEnd:Point;
		
		public function Wire(Start:Point) {
			path = new Vector.<Point>;
			path.push(Start);
		}
		
		public function attemptPathTo(target:Point):Boolean {
			//TODO
			
			/*if (target.equals(lastPathEnd)) return false; //ehh
			
			var start:Point = path[0];
			path = new Vector.<Point>;
			path.push(start);
			
			var pathEnd:Point = path[path.length - 1];
			for (var delta:Point = target.subtract(pathEnd); delta.x || delta.y; delta = target.subtract(pathEnd))
				if (delta.x)
					path.push(pathEnd = new Point(pathEnd.x + U.GRID_DIM * (delta.x > 0 ? 1 : -1), pathEnd.y));
				else
					path.push(pathEnd = new Point(pathEnd.x, pathEnd.y + U.GRID_DIM * (delta.y > 0 ? 1 : -1)));
			
			lastPathEnd = path[path.length - 1];*/
			return true;
		}
		
		public static function place(wire:Wire):Boolean {
			//TODO
			
			/*wire.endDrawing();
			if (wire.path.length > 1) {
				U.wires.push(wire);
				U.connectionPoints.push(wire);
				for each (var otherWire:Wire in U.wires)
					otherWire.checkReadd(wire);
			} else {
				wire.exists = false;
				return false;
			}*/
			return true;
		}
		
		public static function remove(wire:Wire):Boolean {
			//TODO
			
			/*if (wire.FIXED)
				return false;
			
			U.connectionPoints.splice(U.connectionPoints.indexOf(wire), 1);
			wire.exists = false;
			
			var other:Carrier;
			for each (other in wire.connections)
				other.removeConnection(wire);
			
			var source:Port = wire.source;
			wire.resetSource();
			if (source && source.connection)
				source.connection.setSource(source); //re-propagate*/
			
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
				out += p.x + C_DELIM + p.y + P_DELIM;
			return out.substr(0, out.length - 1) + U.SAVE_DELIM;
		}
		
		public static function fromString(str:String):Wire {
			var path:Vector.<Point> = new Vector.<Point>;
			for each (var strPoint:String in str.split(P_DELIM)) {
				var strCoords:Array = strPoint.split(C_DELIM);
				path.push(new Point(int(strCoords[0]), int(strCoords[1])));
			}
			var wire:Wire = new Wire(path[0]);
			wire.path = path;
			return wire;
		}
		
		private static const C_DELIM:String = ',';
		private static const P_DELIM:String = ',,';
	}

}