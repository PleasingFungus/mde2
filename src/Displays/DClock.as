package Displays {
	import Actions.CustomAction;
	import Controls.Key;
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
			super(X, Y, _clock_sprite, function onClick():void {
				U.state.upperLayer.add(new Sliderbar(X + fullWidth, Y + fullWidth, new Range(2, 63, U.state.time.clockPeriod),
													 function setClockPeriod(v:int):void { U.state.time.clockPeriod = v },
													 U.state.time.clockPeriod).setDieOnClickOutside(true, function setNum():void {
														if (lastNum != U.state.time.clockPeriod)
															new CustomAction(function setValue(newValue:int, oldValue:int):Boolean { lastNum = U.state.time.clockPeriod = newValue; return true; },
																			 function setValue(newValue:int, oldValue:int):Boolean { lastNum = U.state.time.clockPeriod = oldValue; return true; },
																			 U.state.time.clockPeriod, lastNum).execute();
													 }));
			}, "Set system clock period", HKEY);
			numberText = U.LABEL_FONT.configureFlxText(new FlxText(X, Y + 8, fullWidth, " "), 0x0, 'center');
		}
		
		override public function draw():void {
			super.draw();
			if (numberText.text != U.state.time.clockPeriod + "")
				numberText.text = U.state.time.clockPeriod+"";
			numberText.draw();
		}
		
		private const HKEY:Key = new Key("C");
		
		[Embed(source = "../../lib/art/ui/clock_blank.png")] private const _clock_sprite:Class;
	}

}