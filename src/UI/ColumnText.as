package UI {
	import org.flixel.FlxText;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ColumnText extends FlxText {
		
		protected var leftStr:String;
		protected var rightStr:String;
		protected var rightText:FlxText;
		public function ColumnText(X:int, Y:int, Width:int, LeftText:String, RightText:String) {
			leftStr = LeftText;
			super(X, Y, Width, LeftText);
			rightStr = RightText;
			create();
		}
		
		override public function setFormat(Font:String=null,Size:Number=8,Color:uint=0xffffff,Alignment:String=null,ShadowColor:uint=0):FlxText {
			if (Alignment == "center") {
				super.setFormat(Font, Size, Color, Alignment, ShadowColor);
				text = leftStr + rightStr;
				rightText = null;
			} else {
				super.setFormat(Font, Size, Color, Alignment, ShadowColor);
				create();
			}
			return this;
		}
		
		protected function create():void {
			rightText = new FlxText(x, y, width, rightStr);
			rightText.setFormat(font, size, color, alignment == 'right' ? 'left' : 'right', shadow);
		}
		
		override public function update():void {
			super.update();
			if (rightText)
				rightText.update();
		}
		
		override public function draw():void {
			super.draw();
			if (rightText)
				rightText.draw();
		}
	}

}