package Displays {
	import Components.Port;
	import Components.Carrier;
	import flash.geom.Point;
	import Layouts.PortLayout;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import Values.Value;
	
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
			
			loadGraphic(_sprite);
			if (layout.vertical) {
				angle = 90;
				offset.x = width / 2;
			} else {
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
		
		override public function draw():void {
			color = getColor();
			super.draw();
		}
		
		protected function getColor():uint {
			if (!port.getSource())
				return 0xff0000;
			
			var value:Value = port.getValue();
			if (value.unknown)
				return 0xc219d9;
			else if (value.unpowered)
				return 0x1d19d9;
			else
				return 0x0;
		}
		
		public function nearPoint(p:FlxPoint, radius:int = 0):Boolean {
			return p.x + radius >= x && p.y + radius >= y && p.x - radius <= x + width && p.y - radius <= y + height;
		}
		[Embed(source = "../../lib/art/wiring/port_8.png")] private const _sprite:Class;
	}

}