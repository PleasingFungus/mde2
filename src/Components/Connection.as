package Components {
	import flash.geom.Point;
	import Layouts.PortLayout;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Connection {
		
		public var port:PortLayout;
		public var origin:Point;
		public function Connection(port:PortLayout, point:Point) {
			this.port = port;
			origin = point;
		}
		
	}

}