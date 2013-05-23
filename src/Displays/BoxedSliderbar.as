package Displays {
	import org.flixel.*;
	import UI.Sliderbar;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class BoxedSliderbar extends FlxGroup {
		
		protected var x:int;
		protected var y:int;
		protected var valueRange:Range;
		protected var onChange:Function;
		protected var initialValue:int;
		public var sliderbar:Sliderbar;
		protected var bg:FlxSprite;
		protected var maxHeight:int;
		
		public function BoxedSliderbar(X:int, Y:int, ValueRange:Range = null, OnChange:Function = null, InitialValue:int = C.INT_NULL) {
			super();
			x = X;
			y = Y;
			valueRange = ValueRange;
			onChange = OnChange;
			initialValue = InitialValue;
			init();
		}
		
		public function init():void {
			members = [];
			sliderbar = new Sliderbar(x + INNER_PAD + BORDER_WIDTH, y + INNER_PAD + BORDER_WIDTH, valueRange, onChange, initialValue)
			var height:int = sliderbar.height + (INNER_PAD + BORDER_WIDTH) * 2;
			if (maxHeight)
				height = Math.min(height, maxHeight);
			add(bg = new FlxSprite(x, y).makeGraphic(sliderbar.width + (INNER_PAD + BORDER_WIDTH) * 2, height, 0xff666666, true));
			add(sliderbar);
			
			bg.pixels.fillRect(new Rectangle(BORDER_WIDTH/2, BORDER_WIDTH/2, bg.width - BORDER_WIDTH, bg.height - BORDER_WIDTH), 0xff999999);
			bg.pixels.fillRect(new Rectangle(BORDER_WIDTH, BORDER_WIDTH, bg.width - BORDER_WIDTH*2, bg.height - BORDER_WIDTH*2), 0xff666666);
			bg.frame = 0;
			bg.scrollFactor.x = bg.scrollFactor.y = 0;
		}
		
		public function overlapsPoint(p:FlxPoint):Boolean {
			return bg.overlapsPoint(p, true, FlxG.camera);
		}
		
		public function setDieOnClickOutside(die:Boolean, onDie:Function = null):BoxedSliderbar {
			sliderbar.setDieOnClickOutside(die, onDie);
			return this;
		}
		
		override public function update():void {
			super.update();
			if (!U.buttonManager.moused && overlapsPoint(FlxG.mouse)) 
				U.buttonManager.moused = true;
			if (!sliderbar.exists) {
				if (overlapsPoint(FlxG.mouse) && FlxG.mouse.justPressed())
					sliderbar.exists = true;
				else
					exists = false;
			}
		}
		
		protected const BORDER_WIDTH:int = 4;
		protected const INNER_PAD:int = 4;
	}

}