package Menu {
	import org.flixel.*
	
	/**
	 * ...
	 * @author azazoth
	 */
	public class TitledColumn extends FlxGroup{
		
		private var _titleText:String;
		public var title:FlxText;
		public var column:Vector.<FlxText>;
		private var X:Number;
		private var Y:Number;
		public function TitledColumn(X:int, Y:int, Title:String, Width:int = -1) {
			if (Width == -1)
				Width = FlxG.width / 2;
			width = Width;
			
			this.X = X;
			this.Y = Y;
			_titleText = Title;
			column = new Vector.<FlxText>;
			make();
		}
		
		public function make():void {
			members = [];
			
			title = new FlxText(X - width / 2, Y, width, _titleText);
			title.setFormat(C.FONT, TITLE_SIZE, 0xffffff, 'center');
			add(title);
			
			height = title.height;
			
			var oldCol:Vector.<FlxText> = column;
			column = new Vector.<FlxText>;
			for each (var oldElement:FlxText in oldCol)
				addCol(oldElement.text);
		}
		
		public function addCols(...columnText):void {
			for each (var text:String in columnText)
				addCol(text);
		}
		
		public function addCol(text:String):void {
			var columnElement:FlxText = new FlxText(X - width / 2, Y + height + SPACING, width, text);
			columnElement.setFormat(C.FONT, COL_SIZE, 0xffffff, 'center');
			column.push(add(columnElement));
			height = columnElement.y + columnElement.height - title.y;
		}
		
		public function setWidth(newWidth:int):void {
			X += (newWidth - width) / 2;
			width = newWidth;
			make();
		}
		
		public function setY(newY:Number):void {
			scroll(newY - Y);
		}
		
		public function scroll(dy:Number):void {
			for each (var text:FlxText in members)
				text.y += dy;
			Y += dy;
		}
		
		
		private const TITLE_SIZE:int = 24;
		private const COL_SIZE:int = 16;
		private const SPACING:int = 2;
	}

}