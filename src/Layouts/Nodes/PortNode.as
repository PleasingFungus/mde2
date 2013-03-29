package Layouts.Nodes {
	import Components.Port;
	import flash.geom.Point;
	import Modules.Module;
	import Layouts.PortLayout;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class PortNode extends InternalNode {
		
		public function PortNode(Parent:Module, Dim:Point, Offset:Point, portLayout:PortLayout) {
			var port:Port = portLayout.port;
			super(Parent, Dim, Offset, [portLayout], [], port.getValue, port.name, port.isOutput);
		}
		
	}

}