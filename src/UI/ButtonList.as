package UI {
	import Controls.ControlSet;
	import flash.geom.Point;
	import org.flixel.*
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ButtonList extends FlxGroup {
		
		public var x:int;
		public var y:int;
		public var buttons:Vector.<MenuButton>;
		
		protected var bg:FlxSprite;
		protected var updatedOnce:Boolean;
		protected var _width:int;
		protected var _height:int;
		protected var forcedWidth:int;
		protected var verticalSpace:int = 10;
		
		public var closesOnClickOutside:Boolean;
		public var closesOnEsc:Boolean;
		public var justDie:Boolean;
		public var onDeath:Function;
		public function ButtonList(X:int, Y:int, Buttons:Vector.<MenuButton>, OnDeath:Function = null) {
			super();
			x = X;
			y = Y;
			buttons = Buttons;
			onDeath = OnDeath;
			
			closesOnClickOutside = true;
			closesOnEsc = true;
			
			create();
		}
		
		public function create():void {
			members = [];
			
			var Y:int = y + BG_BORDER;
			var X:int = x + BG_BORDER;
			var maxWidth:int;
			
			for each (var button:MenuButton in buttons) {
				button.X = X;
				button.Y = Y;
				
				Y += button.fullHeight + verticalSpace;
				if (button.fullWidth > maxWidth)
					maxWidth = button.fullWidth;
			}
			
			Y += BG_BORDER - verticalSpace;
			_width = forcedWidth ? forcedWidth : maxWidth + BG_BORDER * 2;
			_height = Y - y;
			
			makeBG();
			
			if (x + width > FlxG.width) {
				var dx:int = FlxG.width - (x + width);
				bg.x += dx;
				for each (button in buttons)
					button.X += dx;
			}
			
			if (y + height > FlxG.height) {
				var dy:int = FlxG.height - (y + height);
				bg.y += dy;
				for each (button in buttons)
					button.Y += dy;
			}
			
			for each (button in buttons)
				add(button);
		}
		
		protected function makeBG():void {
			bg = new FlxSprite(x, y).makeGraphic(_width, _height, 0xff666666, true, "ButtonList "+_width+"-"+_height);
			var raisedBorderWidth:int = 2;
			
			var light:FlxSprite = new FlxSprite().makeGraphic(_width - raisedBorderWidth * 2, _height - raisedBorderWidth * 2, 0xff999999)
			bg.stamp(light, raisedBorderWidth, raisedBorderWidth);
			
			var innerDark:FlxSprite = new FlxSprite().makeGraphic(_width - raisedBorderWidth * 4, _height - raisedBorderWidth * 4, 0xff666666)
			bg.stamp(innerDark, raisedBorderWidth * 2, raisedBorderWidth * 2);
			
			add(bg);
		}
		
		public function get width():int { return _width }
		public function get height():int { return _height }
		
		
		public function forceWidth(ForcedWidth:int):void {
			forcedWidth = ForcedWidth;
			create();
		}
		
		public function setSpacing(spacing:int):void {
			verticalSpace = spacing;
			create();
		}
		
		override public function update():void {
			super.update();
			
			var moused:Boolean = bg.overlapsPoint(FlxG.mouse, true);
			if (FlxG.mouse.justPressed() && updatedOnce && 
				(justDie ||
				(closesOnClickOutside && !moused)))
				exists = false;
			else if (closesOnEsc && ControlSet.CANCEL_KEY.justPressed() && updatedOnce)
				exists = false;
			if (!exists && onDeath != null)
				onDeath();
			updatedOnce = true;
			
			if (exists && U.buttonManager && !U.buttonManager.moused && moused)
				U.buttonManager.moused = true;
		}
		
		protected const BG_BORDER:int = 5;
	}

}