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
		
		public function GraphicButton(X:int, Y:int, RawGraphic:Class, OnSelect:Function = null, Tooltip:String= null, Hotkey:Key = null) {
			rawGraphic = RawGraphic;
			highlightBorder = new Point(2, 2);
			super(X, Y, OnSelect, Tooltip, Hotkey);
		}
		
		override public function init():void {
			graphic = new FlxSprite(x + highlightBorder.x, y + highlightBorder.y, rawGraphic);
			add(graphic);
			
			super.init();
		}
		
		override protected function calculateGraphicLoc():void {
			coreGraphic = graphic;
		}
		
		public function loadGraphic(RawGraphic:Class):void {
			if (rawGraphic == RawGraphic) return;
			rawGraphic = RawGraphic;
			graphic.loadGraphic(rawGraphic);
		}
	}

}