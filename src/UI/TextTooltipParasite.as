package UI {
	import flash.geom.Point;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class TextTooltipParasite extends FlxBasic {
		
		public var text:FlxText;
		public var tooltip:FlxObject;
		public function TextTooltipParasite(Text:FlxText, Tooltip:FlxObject) {
			super();
			text = Text;
			tooltip = Tooltip;
		}
		
		override public function update():void {
			tooltip.visible = C.textOverlapsPoint(text, new Point(FlxG.mouse.x - FlxG.camera.scroll.x,
																  FlxG.mouse.y - FlxG.camera.scroll.y))
			tooltip.x = FlxG.mouse.x + 20;
			if (tooltip.x + tooltip.width >= FlxG.width - 5)
				tooltip.x = FlxG.mouse.x - (tooltip.width + 10);
			tooltip.y = FlxG.mouse.y + 30;
			if (tooltip.y + tooltip.height >= FlxG.height - 5)
				tooltip.y = FlxG.mouse.y - (tooltip.height + 10);
		}
		
	}

}