package Layouts {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import Modules.Module;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ModuleLayout {
		
		public var module:Module;
		public var offset:Point;
		public var dim:Point;
		public var ports:Vector.<PortLayout>
		public function ModuleLayout(module:Module, Offset:Point, Dim:Point, Ports:Vector.<PortLayout>) {
			this.module = module;
			offset = Offset;
			dim = Dim;
			ports = Ports;
		}
		
		public function getBounds():Rectangle {
			var tl:Point = module.add(offset);
			return new Rectangle(tl.x, tl.y, dim.x, dim.y);
		}
	}

}