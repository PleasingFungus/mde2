package Layouts {
	import Components.Port;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class PortLayout {
		
		public var port:Port;
		public var offset:Point;
		public function PortLayout(port:Port, Offset:Point) {
			this.port = port;
			offset = Offset;
		}
		
	}

}