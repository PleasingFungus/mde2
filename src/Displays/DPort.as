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
		protected var lastZoom:Number;
		public function DPort(Layout:PortLayout) {
			layout = Layout;
			port = Layout.port;
			super();
			
			init();
		}
		
		protected function init():void {
			if (U.zoom >= 0.5)
				loadGraphic(_sprite);
			else
				makeGraphic(U.GRID_DIM, U.GRID_DIM);
			
			if (layout.vertical) {
				angle = 90;
				offset.x = width / 2;
			} else {
				offset.y = height / 2;
			}
			
			lastZoom = U.zoom;
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
			if (U.zoom != lastZoom)
				init();
			color = getColor();
			super.draw();
		}
		
		protected function getColor():uint {
			if (!U.buttonManager.moused && overlapsPoint(U.mouseFlxLoc) && U.state)
				return U.HIGHLIGHTED_COLOR;
			
			if (!port.getSource())
				return U.UNCONNECTED_COLOR;
			
			var value:Value = port.getValue();
			if (value.unknown)
				return U.UNKNOWN_COLOR;
			else if (value.unpowered)
				return U.UNPOWERED_COLOR;
			else
				return U.DEFAULT_COLOR;
		}
		
		public function nearPoint(p:FlxPoint, radius:int = 0):Boolean {
			return p.x + radius >= x && p.y + radius >= y && p.x - radius <= x + width && p.y - radius <= y + height;
		}
		[Embed(source = "../../lib/art/wiring/port_8.png")] private const _sprite:Class;
	}

}