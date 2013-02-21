package Displays {
	import org.flixel.*;
	import Testing.GeneratedGoal;
	import UI.MenuButton;
	import Controls.ControlSet;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DGoal extends FlxGroup {
		
		private var bg:FlxSprite;
		public var level:Level;
		public function DGoal(level:Level) {
			super();
			this.level = level;
			init();
		}
		
		protected function init():void {
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
			
			//bg.alpha = 0.67;
			add(bg);
			
			var title:FlxText = new FlxText(bg.x + 8, bg.y + 8, bg.width - 16, level.name);
			title.setFormat(U.FONT, U.FONT_SIZE * 2, 0xffffff, 'center');
			add(title);
			
			var description:FlxText = new FlxText(bg.x + 8, title.y + title.height + 8, bg.width - 16, level.goal.description);
			description.setFormat(U.FONT, U.FONT_SIZE);
			add(description);
			
			//var goal:FlxText = new FlxText(description.x, description.y + description.height + 8, description.width,
										   //"Goal: M["+
			var testType:String;
			if (level.goal is GeneratedGoal)
				testType = (level.goal as GeneratedGoal).testRuns + " random programs";
			else
				testType = "Simple run";
			
			var testing:FlxText = new FlxText(description.x, description.y + description.height + 16, description.width,
											  "Testing: "+testType + ", time limit of " + level.goal.timeLimit + " cycles");
			if (level.goal is GeneratedGoal)
				testing.text += " per test";
			testing.setFormat(U.FONT, U.FONT_SIZE);
			add(testing);
		}
		
		
		private var tick:int;
		
		override public function update():void {
			super.update();
			checkClick();
			checkControls();
			tick++;
		}
		
		protected function checkClick():void {
			if (tick && FlxG.mouse.justPressed())
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