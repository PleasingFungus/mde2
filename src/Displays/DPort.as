package Displays {
	import Components.ConnectionPoint;
	import Components.Port;
	import Components.Carrier;
	import flash.geom.Point;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DPort extends FlxSprite implements ConnectionPoint {
		
		public var port:Port;
		public function DPort(port:Port, vertical:Boolean = false) {
			this.port = port;
			super();
			if (vertical) {
				makeGraphic(3, U.GRID_DIM, 0xff000000);
				offset.x = width / 2;
			} else {
				makeGraphic(U.GRID_DIM, 3, 0xff000000);
				offset.y = height / 2;
			}
		}
		
		public function getCarrier():Carrier {
			return port;
		}
		
		public function canConnectAt(p:Point):Boolean {
			return connectPoint.equals(p);
		}
		
		public function get connectPoint():Point {
			var p:Point = new Point(x, y);
			if (port.isOutput)
				p.x += width;
			return p;
		}
		
		public function attemptConnect():void {
			for each (var carrier:Carrier in U.carriersAt(connectPoint))
				if (carrier && carrier != port && !(port.isOutput && carrier.getSource())) {
					port.addConnection(carrier);
					break;
				}
		}
	}

}