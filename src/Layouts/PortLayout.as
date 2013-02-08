package Layouts {
	import Components.Port;
	import flash.geom.Point;
	import Modules.Module;
	import Components.Carrier;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class PortLayout {
		
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
		
		public function attemptConnect():void {
			var connectPoint:Point = parent.add(offset);
			for each (var carrier:Carrier in U.state.carriersAtPoint(connectPoint)) {
				if (carrier == port)
					continue;
				
				if (port.isOutput && carrier.getSource() && carrier.getSource() != port)
					throw new Error("Source connected to source at " + connectPoint);
				
				port.addConnection(carrier);
				break;
			}
		}
		
		public function register():void {
			setLineContents(port);
			U.state.addCarrierAtPoint(parent.add(offset), port);
		}
		
		public function deregister():void {
			U.state.removeCarrierFromPoint(parent.add(offset), port);
			setLineContents(null);
		}
		
		private function setLineContents(contents:*):void {
			var connectionPoint:Point = parent.add(offset);
			var origin:Point = connectionPoint.add(new Point(vertical ? 0 : reversed ? -1 : 1, vertical ? reversed ? -1 : 1 : 0));
			U.state.setLineContents(connectionPoint, origin, contents);
		}
		
		public function get validPosition():Boolean {
			if (!port.isOutput) return true;
			
			var carriers:Vector.<Carrier> = U.state.carriersAtPoint(parent.add(offset));
			if (!carriers) return true;
			
			for each (var carrier:Carrier in carriers)
				if (carrier.getSource() && carrier.getSource() != port)
					return false;
			return true;
		}
	}

}