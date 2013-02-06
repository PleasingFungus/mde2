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
					nextPoint = new Point(pathEnd.x + (delta.x > 0 ? 1 : -1), pathEnd.y);
				else
					nextPoint = new Point(pathEnd.x, pathEnd.y + (delta.y > 0 ? 1 : -1));
				
				if (U.state.lineContents(pathEnd, nextPoint))
					break;
				
				path.push(pathEnd = nextPoint);
			}
			
			while (path.length > 1 && !validPosition())
				path.pop();
			
			lastPathEnd = path[path.length - 1];
			return true;
		}
		
		protected function endDrawing():void {
			if (path.length > 1) {
				exists = true;
				connections = new Vector.<Carrier>;
				checkForConnections();
			}
		}
		
		protected function validPosition():Boolean {
			var sources:int = 0;
			for each (var carriers:Vector.<Carrier> in [U.state.carriersAtPoint(path[0]), U.state.carriersAtPoint(path[path.length - 1])])
				if (carriers)
					for each (var carrier:Carrier in carriers)
						if (carrier.getSource()) {
							sources += 1;
							if (sources > 1)
								return false;
						}
			return true;
		}
		
		protected function checkForConnections():void {	
			addConnections(U.state.carriersAtPoint(path[0]));
			addConnections(U.state.carriersAtPoint(path[path.length - 1]));
		}
		
		public function addConnections(carriers:Vector.<Carrier>):void {
			if (!carriers)
				return;
			
			for each (var connection:Carrier in carriers)
				addConnection(connection);
		}
		
		public static function place(wire:Wire):Boolean {
			wire.endDrawing();
			if (wire.path.length < 2) {
				wire.exists = false;
				return false;
			}
			
			wire.exists = true;
			U.state.wires.push(wire);
			for (var i:int = 0; i < wire.path.length - 1; i++)
				U.state.setLineContents(wire.path[i], wire.path[i + 1], wire);
			for each (var p:Point in wire.path)
				U.state.addCarrierAtPoint(p, wire);
			
			return true;
		}
		
		public static function remove(wire:Wire):Boolean {
			if (wire.FIXED)
				return false;
			
			for each (var p:Point in wire.path)
				U.state.removeCarrierFromPoint(p, wire);
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
		
		public function setSource(Source:Port):void {
			source = Source;
			for each (var connection:Carrier in connections)
				if (!connection.getSource())
					connection.setSource(Source);
		}
		
		public function addConnection(connection:Carrier):void {
			if (!connection || connection == this || connections.indexOf(connection) != -1) return;
			
			connections.push(connection);
			connection.addConnection(this);
			if (connection.getSource()) {
				if (!source)
					setSource(connection.getSource());
				else if (source != connection.getSource())
					throw new Error("Multiple sources in one mesh!");
			}
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