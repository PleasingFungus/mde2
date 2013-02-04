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
		public var vertical:Boolean;
		public var reversed:Boolean;
		public function PortLayout(port:Port, Offset:Point, Vertical:Boolean = false, Reversed:Boolean = false) {
			this.port = port;
			offset = Offset;
			vertical = Vertical;
			reversed = Reversed;
		}
		
	}

}