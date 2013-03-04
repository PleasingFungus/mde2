package Displays {
	import org.flixel.*;
	import Controls.ControlSet;
	import UI.MenuButton;
	import Values.FixedValue;
	import Values.Value;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DMemory extends FlxGroup {
		
		private var bg:FlxSprite;
		private var moment:int;
		public var memory:Vector.<Value>;
		public function DMemory(Memory:Vector.<Value>) {
			memory = Memory;
			super();
			init();
		}
		
		public function init():void {
			moment = U.state.time.moment;
			makeBG();
			makePages();
		}
		
		protected function makeBG():void {
			var shade:FlxSprite = new FlxSprite;
			shade.makeGraphic(FlxG.width, FlxG.height, 0xff000000);
			shade.alpha = 0.4;
			add(shade);
			
			var width:int = FlxG.width * WIDTH_FRACTION;
			var height:int = FlxG.height * HEIGHT_FRACTION;
			bg = new FlxSprite((FlxG.width - width) / 2, (FlxG.height - height) / 2).makeGraphic(width, height, 0xff202020);
			var raisedBorderWidth:int = 2;
			
			var light:FlxSprite = new FlxSprite().makeGraphic(width - raisedBorderWidth * 2, height - raisedBorderWidth * 2, 0xff666666)
			bg.stamp(light, raisedBorderWidth, raisedBorderWidth);
			
			var innerDark:FlxSprite = new FlxSprite().makeGraphic(width - raisedBorderWidth * 4, height - raisedBorderWidth * 4, 0xff202020)
			bg.stamp(innerDark, raisedBorderWidth * 2, raisedBorderWidth * 2);
			
			add(bg);
		}
		
		protected function makePages():void {
			var BORDER:int = 10;
			var COL_WIDTH:int = 225;
			var COL_HEIGHT:int = bg.height - BORDER * 2;
			var ROW_HEIGHT:int = 20;
			var ROWS:int = COL_HEIGHT / (ROW_HEIGHT + BORDER / 2);
			var COLS:int = (bg.width - BORDER * 2) / (COL_WIDTH + BORDER);
			
			var row:int, col:int, skipped:Boolean;
			for (var memLine:int = 0; memLine < memory.length; memLine++) {
				var memValue:Value = memory[memLine];
				if (memValue && memValue != FixedValue.NULL) {
					var memText:FlxText = new FlxText(bg.x + BORDER + col * (COL_WIDTH + BORDER),
													  bg.y + BORDER + row * (ROW_HEIGHT + BORDER / 2),
													  COL_WIDTH, memLine + " : " + memValue.toString())
					add(U.BODY_FONT.configureFlxText(memText));
					
					row += 1;
					if (row >= ROWS) {
						row = 0;
						col += 1;
					}
					skipped = false;
				} else if (!skipped) {
					row += 1;
					if (row >= ROWS) {
						row = 0;
						col += 1;
					}
					skipped = true;
				}
			}
			//TODO
		}
		
		private var tick:int;
		
		override public function update():void {
			super.update();
			checkTime();
			checkClick();
			checkControls();
			tick++;
		}
		
		protected function checkTime():void {
			if (moment != U.state.time.moment)
				init(); //NOTE: interacts poorly with anything that resets memory
		}
		
		protected function checkClick():void {
			if (!tick)
				return;
			
			if (FlxG.mouse.justPressed())
				exists = false;
			
		}
		
		protected function checkControls():void {
			if (ControlSet.CANCEL_KEY.justPressed())
				exists = false;
		}
		
		private const WIDTH_FRACTION:Number = 3 / 4;
		private const HEIGHT_FRACTION:Number = 3 / 4;
		
	}

}