package Displays {
	import Components.Port;
	import Components.Carrier;
	import flash.geom.Point;
	import Layouts.PortLayout;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DPort extends FlxSprite {
		
		public var port:Port;
		public var layout:PortLayout;
		public function DPort(Layout:PortLayout) {
			layout = Layout;
			port = Layout.port;
			super();
			if (layout.vertical) {
				makeGraphic(3, U.GRID_DIM / 2, 0xff000000);
				offset.x = width / 2;
			} else {
				makeGraphic(U.GRID_DIM / 2, 3, 0xff000000);
				offset.y = height / 2;
			}
		}
		
		public function updatePosition(baseX:int, baseY:int):void {
			x = baseX + layout.offset.x * U.GRID_DIM;
			y = baseY + layout.offset.y * U.GRID_DIM;
			if (layout.reversed) {
				if (layout.vertical)
					y -= height;
				else
					x -= width;
			}
		}
		
		public function nearPoint(p:FlxPoint, radius:int = 0):Boolean {
			return p.x + radius >= x && p.y + radius >= y && p.x - radius <= x + width && p.y - radius <= y + height;
		}
	}

}