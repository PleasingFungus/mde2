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
		
		public function generate():void {
			var formatChunks:Array = formatString.split(FORMAT_MARK);
			if (formatChunks.length != colorStrings.length + 1)
				throw new Error("Format chunk count (" + formatChunks.length + ") doesn't match color string count (" + colorStrings.length + ") + 1!");
			
			var curStr:String = "";
			for (var i:int = 0; i < colorStrings.length; i++) {
				var colorText:ColorText = colorStrings[i];
				curStr += formatChunks[i] + "<font color='#"+colorText.color.toString(16)+"'>" + colorText.text +"</font>";
			}
			_textField.htmlText = curStr + formatChunks[formatChunks.length - 1];
			_regen = true;
			calcFrame();
		}
		
		override public function setFormat(Font:String = null, Size:Number = 8, Color:uint = 0xffffff, Align:String = 'left', ShadowColor:uint = 0):FlxText {
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
		
		
		override public function set color(Color:uint):void { ///?????
			super.color = Color;
			generate();
		}
		
		override public function set alignment(Alignment:String):void {
			super.alignment = Alignment;
			generate();
		}
		
		override public function set shadow(Color:uint):void {
			super.shadow = Color;
			generate();
		}
		
		public static const FORMAT_MARK:String = "{}";
	}

}