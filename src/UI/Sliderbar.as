package UI {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import Modules.Configuration;
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
		public var config:Configuration;
		public var labelEnabled:Boolean = true;
		private var textWidth:int;
		
		protected var valueRange:Range;
		protected var value:int;
		protected var onChange:Function;
		
		protected var slider:FlxSprite;
		protected var rail:FlxSprite;
		protected var leftArrow:FlxSprite;
		protected var rightArrow:FlxSprite;
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
			
			valueRange = ValueRange ? ValueRange : new Range(-16, 15);
			value = InitialValue != C.INT_NULL ? InitialValue : valueRange.initial;
			onChange = OnChange;
			create();
		}
		
		public function create():void {
			members = [];
			
			width = 80;
			height = labelEnabled ? 48 : 20;
			
			//slider bit
			slider = new FlxSprite(-1, y).makeGraphic(8, 20, 0xffa0a0a0, true, "scrollbar");
			slider.framePixels.fillRect(new Rectangle(1, 1, slider.width - 2, slider.height - 2), 0xff202020);
			
			leftArrow = new FlxSprite(x, y, _left_arrow);
			rightArrow = new FlxSprite(x + width, y, _right_arrow);
			rightArrow.x -= rightArrow.width;
			
			//"rail"
			rail = new FlxSprite(x + leftArrow.width, slider.y + slider.height / 2).makeGraphic(width - leftArrow.width * 2, 4, 0xffa0a0a0);
			add(rail);
			add(leftArrow);
			add(rightArrow);
			add(slider);
			
			if (labelEnabled) {			
				//value display
				valueText = new FlxText( -1, -1, FlxG.width, " ").setFormat(U.LABEL_FONT.id, U.LABEL_FONT.size, 0xffffff);
				valueText.text = valueRange.nameOf(valueRange.min);
				textWidth = valueText.textWidth;
				valueText.text = valueRange.nameOf(valueRange.max);
				textWidth = Math.max(textWidth, valueText.textWidth);
				valueText.text = valueRange.nameOf(value);
				//valueText.alignment = 'center';
				//valueText.width = textWidth;
				
				valueBox = new FlxSprite(valueText.x - TEXT_BORDER, valueText.y - TEXT_BORDER).makeGraphic(textWidth + TEXT_BORDER * 2, valueText.height + TEXT_BORDER * 2, 0xff202020, true);
				valueBox.framePixels.fillRect(new Rectangle(TEXT_BORDER / 2, TEXT_BORDER / 2, valueBox.width - TEXT_BORDER, valueBox.height - TEXT_BORDER), 0xff666666);
				
				add(valueBox);
				add(valueText);
			}
			
			positionElements();
		}
		
		public function positionElements():void {
			leftArrow.x = x;
			rightArrow.x = x + width - rightArrow.width;
			leftArrow.y = rightArrow.y = y;
			
			rail.x = x + leftArrow.width;
			rail.y = y + slider.height / 2;
			
			var posFraction:Number = (value - valueRange.min) / (valueRange.max - valueRange.min);
			if (isNaN(posFraction))
				posFraction = 0.5;
			slider.x = rail.x + (rail.width - slider.width) * posFraction;
			slider.y = y;
			
			if (labelEnabled) {
				valueText.x = x + width / 2 - textWidth / 2;
				valueText.y = y + height - valueText.height - TEXT_BORDER;
				
				valueBox.x = valueText.x - TEXT_BORDER;
				valueBox.y = valueText.y - TEXT_BORDER;
			}
		}
		
		public function setDieOnClickOutside(die:Boolean, onDie:Function = null):Sliderbar {
			dieOnClickOutside = die;
			onDeath = onDie;
			return this;
		}
		
		public function setLabeled(enabled:Boolean):Sliderbar {
			labelEnabled = enabled;
			create();
			return this;
		}
		
		override public function update():void {
			super.update();
			checkClick();
			tick++;
		}
		
		protected function checkClick():void {
			var adjMouse:FlxPoint = getAdjMouse();
			var barMoused:Boolean = adjMouse.x >= rail.x && adjMouse.x <= rail.x + rail.width && adjMouse.y >= slider.y && adjMouse.y <= slider.y + slider.height && (!U.buttonManager || !U.buttonManager.moused);
			if ((barMoused || leftArrow.overlapsPoint(FlxG.mouse, true) || rightArrow.overlapsPoint(FlxG.mouse, true)) && U.buttonManager)
				U.buttonManager.moused = true
			
			if (FlxG.mouse.justPressed()) {
				if (barMoused) {
					barClicked = true;
					moveSlider();
				} else if (leftArrow.overlapsPoint(FlxG.mouse, true)) {
					if (config)
						forceValue(config.decrement());
					else 
						changeValueTo(value - 1);
				} else if (rightArrow.overlapsPoint(FlxG.mouse, true)) {
					if (config)
						forceValue(config.increment());
					else 
						changeValueTo(value + 1);
				} else if (tick && dieOnClickOutside) {
					exists = false;
					if (onDeath != null)
						onDeath();
				}
			}
			
			if (barClicked) {
				if (FlxG.mouse.pressed())
					moveSlider();
				else
					barClicked = false;
			}
		}
		
		private function changeValueTo(newValue:int):void {
			if (newValue < valueRange.min || newValue > valueRange.max)
				return;
			
			if (onChange != null) {
				var out:* = onChange(newValue);
				forceValue(!(out == null) ? out : newValue);
			} else
				forceValue(newValue);
		}
		
		private function getAdjMouse():FlxPoint {
			return new FlxPoint(FlxG.mouse.x + FlxG.camera.scroll.x * (slider.scrollFactor.x - 1), 
								FlxG.mouse.y + FlxG.camera.scroll.y * (slider.scrollFactor.y - 1));
		}
		
		private function moveSlider():void {			
			var oldX:int = slider.x;
			slider.x = Math.max(rail.x, Math.min(rail.x + rail.width - slider.width, getAdjMouse().x));
			if (oldX != slider.x)
				updateValue();
		}
		
		protected function updateValue():void {
			var oldValue:int = value;
			var sliderFraction:Number = (slider.x - rail.x) / (rail.width - slider.width);
			value = valueRange.width * sliderFraction + valueRange.min;
			if (value != oldValue) {
				var out:* = onChange(value);
				if (out is int)
					value = out as int;
				if (labelEnabled)
					valueText.text = valueRange.nameOf(value);
			}
		}
		
		public function forceValue(v:int):Boolean {
			if (v < valueRange.min || v > valueRange.max)
				return false;
			
			value = v;
			
			if (labelEnabled)
				valueText.text = valueRange.nameOf(v);
			
			var fraction:Number = (v - valueRange.min) / valueRange.width;
			slider.x = rail.x + fraction * (rail.width - slider.width);
			
			return true;
		}
		
		[Embed(source = "../../lib/art/ui/leftscrollarrow.png")] private const _left_arrow:Class;
		[Embed(source = "../../lib/art/ui/rightscrollarrow.png")] private const _right_arrow:Class;
		
		private const TEXT_BORDER:int = 2;
	}

}