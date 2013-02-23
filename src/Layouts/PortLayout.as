package Layouts {
	import Components.Port;
	import flash.geom.Point;
	import Modules.Module;
	import Components.Carrier;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class PortLayout implements Node {
		
		public var port:Port;
		public var parent:Module;
		public var offset:Point;
		public var vertical:Boolean;
		public var reversed:Boolean;
		public function PortLayout(port:Port, Offset:Point, Vertical:Boolean = false, Reversed:Boolean = false) {
			this.port = port;
			parent = port.parent;
			offset = Offset;
			vertical = Vertical;
			reversed = Reversed;
		}
		
		public function register():void {
			setLineContents(port);
			U.state.addCarrierAtPoint(Loc, port);
		}
		
		public function attemptConnect():void {
			var connectPoint:Point = Loc;
			for each (var carrier:Carrier in U.state.carriersAtPoint(connectPoint))
				if (carrier != port) {
					port.addConnection(carrier);
					carrier.addConnection(port);
					if (carrier.getSource())
						port.source = carrier.getSource();
				}
			if (port.getSource())
				port.propagateSource();
		}
		
		public function disconnect():void {
			var connection:Carrier;
			for each (connection in port.connections)
				connection.removeConnection(port);
			if (port.getSource()) {
				for each (connection in port.connections)
					connection.resetSource();
				if (!port.isSource())
					port.source.propagateSource(); //re-propagate
			}
			
			port.connections = new Vector.<Carrier>;
			port.source = null;
		}
		
		public function deregister():void {
			U.state.removeCarrierFromPoint(Loc, port);
			setLineContents(null);
		}
		
		
		private function setLineContents(contents:*):void {
			var connectionPoint:Point = Loc;
			var origin:Point = connectionPoint.add(new Point(vertical ? 0 : reversed ? -1 : 1, vertical ? reversed ? -1 : 1 : 0));
			U.state.setLineContents(connectionPoint, origin, contents);
		}
		
		public function get validPosition():Boolean {
			if (!port.isOutput) return true;
			
			var carriers:Vector.<Carrier> = U.state.carriersAtPoint(Loc);
			if (!carriers) return true;
			
			for each (var carrier:Carrier in carriers)
				if (carrier.getSource() && carrier.getSource() != port)
					return false;
			return true;
		}
		
		public function get Loc():Point {
			return parent.add(offset);
		}
	}

}