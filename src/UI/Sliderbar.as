package UI {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flixel.*;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Sliderbar extends FlxGroup {
		
		public var x:int;
		public var y:int;
		public var width:int;
		public var height:int;
		
		protected var valueRange:Range;
		protected var value:int;
		protected var onChange:Function;
		
		protected var slider:FlxSprite;
		protected var rail:FlxSprite;
		protected var valueText:FlxText;
		protected var valueBox:FlxSprite;
		
		protected var barClicked:Boolean;
		protected var dieOnClickOutside:Boolean;
		protected var onDeath:Function;
		protected var tick:int;
		
		public function Sliderbar(X:int, Y:int, ValueRange:Range = null, OnChange:Function = null, InitialValue:int = C.INT_NULL) {
			super();
			
			x = X;
			y = Y;
			width = 80;
			height = 48;
			
			valueRange = ValueRange ? ValueRange : new Range(-16, 15);
			value = InitialValue != C.INT_NULL ? InitialValue : valueRange.initial;
			onChange = OnChange;
			create();
		}
		
		public function create():void {
			members = [];
			
			//slider bit
			slider = new FlxSprite(-1, y).makeGraphic(8, 20, 0xffa0a0a0, true, "sliderBar");
			slider.framePixels.fillRect(new Rectangle(1, 1, slider.width - 2, slider.height - 2), 0xff202020);
			
			//TODO: arrows
			
			//"rail"
			rail = new FlxSprite(x, slider.y + slider.height / 2).makeGraphic(width, 4, 0xffa0a0a0);
			rail.y -= rail.height / 2;
			add(rail);
			add(slider);
			
			var posFraction:Number = (value - valueRange.min) / (valueRange.max - valueRange.min);
			slider.x = rail.x + width * posFraction - slider.width / 2;
			
			//value display
			valueText = new FlxText( -1, -1, FlxG.width, " ").setFormat(U.LABEL_FONT.id, U.LABEL_FONT.size, 0xffffff);
			valueText.text = valueRange.nameOf(valueRange.min);
			var textWidth:int = valueText.textWidth;
			valueText.text = valueRange.nameOf(valueRange.max);
			textWidth = Math.max(textWidth, valueText.textWidth);
			valueText.text = valueRange.nameOf(value);
			//valueText.alignment = 'center';
			//valueText.width = textWidth;
			
			var textBorder:int = 2;
			valueText.x = x + width / 2 - textWidth / 2;
			valueText.y = y + height - valueText.height - textBorder;
			
			valueBox = new FlxSprite(valueText.x - textBorder, valueText.y - textBorder).makeGraphic(textWidth + textBorder * 2, valueText.height + textBorder * 2, 0xff202020, true);
			valueBox.framePixels.fillRect(new Rectangle(textBorder / 2, textBorder / 2, valueBox.width - textBorder, valueBox.height - textBorder), 0xff666666);
			
			add(valueBox);
			add(valueText);
		}
		
		public function setDieOnClickOutside(die:Boolean, onDie:Function = null):Sliderbar {
			dieOnClickOutside = die;
			onDeath = onDie;
			return this;
		}
		
		override public function update():void {
			super.update();
			checkClick();
			tick++;
		}
		
		protected function checkClick():void {
			var adjMouse:FlxPoint = new FlxPoint(FlxG.mouse.x + FlxG.camera.scroll.x * (slider.scrollFactor.x - 1), 
												 FlxG.mouse.y + FlxG.camera.scroll.y * (slider.scrollFactor.y - 1));
			
			if (FlxG.mouse.justPressed()) {
				barClicked = adjMouse.x >= rail.x && adjMouse.x <= rail.x + rail.width && adjMouse.y >= slider.y && adjMouse.y <= slider.y + slider.height;
				if (barClicked)
					U.buttonManager.clicked = true;
				else if (tick && dieOnClickOutside) {
					exists = false;
					if (onDeath != null)
						onDeath();
				}
			}
			
			if (barClicked) {
				if (FlxG.mouse.pressed()) {
					var oldX:int = slider.x;
					slider.x = Math.max(rail.x, Math.min(rail.x + rail.width - slider.width, adjMouse.x - slider.width / 2));
					if (oldX != slider.x)
						updateValue();
				} else
					barClicked = false;
			}
		}
		
		protected function updateValue():void {
			var oldValue:int = value;
			var sliderFraction:Number = (slider.x - rail.x) / (rail.width - slider.width);
			value = valueRange.width * sliderFraction + valueRange.min;
			if (value != oldValue) {
				var out:* = onChange(value);
				if (out is int)
					value = out as int;
				valueText.text = valueRange.nameOf(value);
			}
		}
		
		public function forceValue(v:int):Boolean {
			if (v < valueRange.min || v > valueRange.max)
				return false;
			
			value = v;
			
			valueText.text = valueRange.nameOf(v);
			
			var fraction:Number = (v - valueRange.min) / valueRange.width;
			slider.x = rail.x + fraction * (rail.width - slider.width) - slider.width / 2;
			
			return true;
		}
	}

}