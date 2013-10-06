package Displays {
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ScreenFilter extends FlxBasic {
		
		private var transform:ColorTransform;
		private var rect:Rectangle;
		public function ScreenFilter(color:uint) {
			var alphaSeg:uint = (color >> 24) & 0xff;
			var alpha:Number = alphaSeg / 0xff;
			var red:uint = ((color >> 16) & 0xff) * alpha;
			var green:uint = ((color >> 8) & 0xff) * alpha;
			var blue:uint = (color & 0xff) * alpha;
			transform = new ColorTransform(1 - alpha, 1 - alpha, 1 - alpha, 1, red, green, blue);
		}
		
		override public function draw():void {
			if (!rect || rect.width != FlxG.camera.buffer.width || rect.height != FlxG.camera.buffer.height)
				rect = new Rectangle(0, 0, FlxG.camera.buffer.width, FlxG.camera.buffer.height)
			FlxG.camera.buffer.colorTransform(rect, transform);
		}
		
	}

}