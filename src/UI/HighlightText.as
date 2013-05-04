package UI {
	import org.flixel.FlxText;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class HighlightText extends FlxText {
		
		public var formatString:String;
		public var colorStrings:Vector.<ColorText>;
		public function HighlightText(X:int, Y:int, Width:int,
									  FormatString:String, ColorStrings:Vector.<ColorText>) {
			super(X, Y, Width);
			formatString = FormatString;
			colorStrings = ColorStrings;
			generate();
		}
		
		private var DEBUG_HIGHLIGHT_TEXTS:Vector.<FlxText>;
		
		public function generate():void {
			var formatChunks:Array = formatString.split(FORMAT_MARK);
			if (formatChunks.length != colorStrings.length + 1)
				throw new Error("Format chunk count (" + formatChunks.length + ") doesn't match color string count (" + colorStrings.length + ") + 1!");
			
			var highlightTexts:Vector.<FlxText> = new Vector.<FlxText>;
			var curStr:String = "";
			for (var i:int = 0; i < colorStrings.length; i++) {
				var colorText:ColorText = colorStrings[i];
				curStr += formatChunks[i] + colorText.text;
				super.text = curStr;
				
				var highlightText:FlxText = new FlxText( -1, -1, width, colorText.text).setFormat(font, size, colorText.color);
				highlightText.x = x + endWidth - highlightText.textWidth;
				highlightText.y = y + height - highlightText.height;
				if (highlightText.y != y)
					highlightText.x -= 1; //hack
				highlightTexts.push(highlightText);
			}
			super.text = curStr + formatChunks[formatChunks.length - 1];
			
			for each (highlightText in highlightTexts) {
				//replicating 'stamp()'
				_flashPoint.x = highlightText.x - x;
				if ('right' == alignment)
					_flashPoint.x += width - textWidth - 4; //-4 = hack
				_flashPoint.y = highlightText.y - y;
				_flashRect2.width = highlightText.framePixels.width;
				_flashRect2.height = highlightText.framePixels.height;
				framePixels.copyPixels(highlightText.framePixels,_flashRect2,_flashPoint,null,null,true);
				_flashRect2.width = _pixels.width;
				_flashRect2.height = _pixels.height;
			}
			
			DEBUG_HIGHLIGHT_TEXTS = highlightTexts;
		}
		
		override public function setFormat(Font:String = null, Size:Number = 8, Color:uint = 0xffffff, Align:String = 'left', ShadowColor:uint = 0):FlxText {
			Align = ALLOWED_ALIGNMENTS.indexOf(Align) != -1 ? Align : 'left';
			super.setFormat(Font, Size, Color, Align, ShadowColor);
			generate();
			return this;
		}
		
		override public function set text(Text:String):void {
			formatString = Text;
			generate();
		}
		
		override public function set size(Size:Number):void {
			super.size = Size;
			generate();
		}
		
		
		override public function set color(Color:uint):void {
			super.color = Color;
			generate();
		}
		
		override public function set alignment(Alignment:String):void {
			Alignment = ALLOWED_ALIGNMENTS.indexOf(Alignment) != -1 ? Alignment : 'left';
			super.alignment = Alignment;
			generate();
		}
		
		override public function set shadow(Color:uint):void {
			super.shadow = Color;
			generate();
		}
		
		public static const FORMAT_MARK:String = "{}";
		private const ALLOWED_ALIGNMENTS:Array = ["left", "right"];
	}

}