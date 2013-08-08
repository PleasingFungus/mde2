package Displays {
	import Actions.CustomAction;
	import Controls.Key;
	import org.flixel.FlxPoint;
	import org.flixel.FlxText;
	import UI.GraphicButton;
	import UI.Sliderbar;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DClock extends GraphicButton {
		
		private var numberText:FlxText;
		private var lastNum:int;
		public function DClock(X:int, Y:int) {
			lastNum = U.state.time.clockPeriod;
			var min:int = 1;
			var max:int = 63;
			super(X, Y, _clock_sprite, function onClick():void {
				U.state.upperLayer.add(new BoxedSliderbar(X - fullWidth + 6, Y + fullWidth, new Range(min, max, U.state.time.clockPeriod),
													 function setClockPeriod(v:int):void { U.state.time.clockPeriod = Math.min(Math.max(v, min), max); },
													 U.state.time.clockPeriod).setDieOnClickOutside(true, function setNum():void {
														if (lastNum != U.state.time.clockPeriod)
															new CustomAction(function setValue(newValue:int, oldValue:int):Boolean { lastNum = U.state.time.clockPeriod = newValue; return true; },
																			 function setValue(newValue:int, oldValue:int):Boolean { lastNum = U.state.time.clockPeriod = oldValue; return true; },
																			 U.state.time.clockPeriod, lastNum).execute();
													 }).setLabeled(false));
			}, "Set system clock period", HKEY);
			numberText = U.LABEL_FONT.configureFlxText(new FlxText(X, Y + 8, fullWidth, " "), 0x0, 'center');
			numberText.scrollFactor = new FlxPoint;
		}
		
		override public function draw():void {
			super.draw();
			if (numberText.text != U.state.time.clockPeriod + "")
				numberText.text = U.state.time.clockPeriod+"";
			numberText.draw();
		}
		
		private const HKEY:Key = null; //TODO
		
		[Embed(source = "../../lib/art/ui/clock_blank.png")] private const _clock_sprite:Class;
	}

}