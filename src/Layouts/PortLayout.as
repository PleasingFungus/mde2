package Layouts {
	import Components.Port;
	import Components.Wire;
	import flash.geom.Point;
	import Modules.Module;
	import Components.Carrier;
	import Layouts.Nodes.Node;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class PortLayout implements Node {
		
		public var port:Port;
		public var vertical:Boolean;
		public var reversed:Boolean;
		public function PortLayout(port:Port, Offset:Point, Vertical:Boolean = false, Reversed:Boolean = false) {
			this.port = port;
			port.offset = Offset;
			vertical = Vertical;
			reversed = Reversed;
		}
		
		public function register():void {
			setLineContents(port);
			U.state.grid.addCarrierAtPoint(Loc, port);
		}
		
		public function attemptConnect():void {
			var connectPoint:Point = Loc;
			for each (var carrier:Carrier in U.state.grid.carriersAtPoint(connectPoint))
				if (carrier != port) {
					if (carrier is Port) {
						port.createLink(carrier as Port); 						
					} else {
						port.addConnection(carrier);
						carrier.addConnection(port);
						if (carrier.getSource())
							port.source = carrier.getSource();
					}
				}
			if (port.getSource())
				port.propagateSource();
		}
		
		public function deregister():void {
			U.state.grid.removeCarrierFromPoint(Loc, port);
			setLineContents(null);
		}
		
		
		private function setLineContents(contents:*):void {
			var connectionPoint:Point = Loc;
			var origin:Point = connectionPoint.add(new Point(vertical ? 0 : reversed ? -1 : 1, vertical ? reversed ? -1 : 1 : 0));
			U.state.grid.setLineContents(connectionPoint, origin, contents);
		}
		
		public function get Loc():Point {
			return port.Loc;
		}
		
		public function get offset():Point {
			return port.offset;
		}
		
		public function remainingDelay():int {
			return port.stable ? 0 : port.remainingDelay();
		}
	}

}