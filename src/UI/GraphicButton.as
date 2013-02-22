package UI {
	import Controls.Key;
	import org.flixel.FlxSprite;
	import flash.geom.Point;
	import org.flixel.FlxText;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class GraphicButton extends MenuButton {
		
		public var rawGraphic:Class;
		protected var graphic:FlxSprite;
		protected var hotkeyHint:FlxText;
		
		public function GraphicButton(X:int, Y:int, RawGraphic:Class, OnSelect:Function = null, Hotkey:Key = null) {
			rawGraphic = RawGraphic;
			highlightBorder = new Point(2, 2);
			super(X, Y, OnSelect, Hotkey);
		}
		
		override public function init():void {
			graphic = new FlxSprite(x + highlightBorder.x, y + highlightBorder.y, rawGraphic);
			add(graphic);
			
			super.init();
			
			if (hotkey)
				add(hotkeyHint = new FlxText( -1, -1, 1000, hotkey.toString()).setFormat(U.FONT, 16));
		}
		
		override protected function calculateGraphicLoc():void {
			coreGraphic = graphic;
		}
		
		override public function draw():void {
			if (hotkey) {
				hotkeyHint.x = graphic.x + graphic.width * 3 / 4;
				hotkeyHint.y = graphic.y + graphic.height * 3 / 4;
			}
			super.draw();
		}
		
		public function loadGraphic(RawGraphic:Class):void {
			if (rawGraphic == RawGraphic) return;
			rawGraphic = RawGraphic;
			graphic.loadGraphic(rawGraphic);
		}
	}

}