package UI {
	import Controls.Key;
	import flash.geom.Point;
	import org.flixel.*;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class TextButton extends MenuButton {
		
		protected var desc:String;
		protected var text:FlxText;
		
		public var callsWithName:Boolean;
		
		public function TextButton(X:int, Y:int, Desc:String, OnSelect:Function = null, Tooltip:String = null, Hotkey:Key = null ) {
			desc = Desc;
			highlightBorder = new Point(5, 10);
			super(X, Y, OnSelect, Tooltip, Hotkey);
		}
		
		override public function init():void {
			var size:int = 16;
			var align:String = 'left';
			var font:String = null;
			var graphicColor:uint = 0x0;
			
			if (text) {
				align = text.alignment;
				size = text.size;
				font = text.font;
				graphicColor = text.color;
				
				remove(text);
			}
			
			text = new FlxText(x + highlightBorder.x, y + highlightBorder.y, FlxG.width, desc);
			text.setFormat(font, size, graphicColor, align);
			add(text);
			
			super.init();
		}
		
		override protected function calculateGraphicLoc():void {
			coreGraphic = new FlxSprite(text.x, text.y).makeGraphic(text.textWidth, text.height);
			if (text.alignment == 'center') {
				text.alignment = 'left';
				coreGraphic.x = text.x + (text.width - text.textWidth) / 2;
				coreGraphic.width = text.textWidth;
				text.alignment = 'center';
			}
		}
		
		override protected function executeChoice():void {
			if (callsWithName)
				onSelect(text.text);
			else
				super.executeChoice();
		}
		
		override public function set Y(Y:int):void {
			super.Y = Y;
			text.y = coreGraphic.y;
		}
		
		override public function set X(X:int):void {
			super.X = X;
			text.x = X + highlightBorder.x;
			calculateGraphicLoc();
		}
		
		public function setFormat(Font:String = null, Size:Number = 8, Color:uint = 0xffffff, Alignment:String = null):MenuButton {
			text.setFormat(Font, Size, Color, Alignment);
			init();
			return this;
		}
		
		override public function setDisabled(disabled:Boolean):MenuButton {
			text.color = disabled ? 0x404040 : 0x0;
			return super.setDisabled(disabled);
		}
	}

}