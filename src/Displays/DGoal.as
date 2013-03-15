package Displays {
	import org.flixel.*;
	import Testing.Goals.GeneratedGoal;
	import UI.GraphicButton;
	import UI.MenuButton;
	import Controls.ControlSet;
	import Levels.Level;
	import Values.OpcodeValue;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DGoal extends FlxGroup {
		
		private var bg:FlxSprite;
		public var level:Level;
		private var pages:Vector.<FlxText>;
		private var forwardButton:GraphicButton;
		private var backButton:GraphicButton;
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
			
			var X:int = bg.x + 8;
			var Width:int = bg.width - 16;
			var title:FlxText = new FlxText(X, bg.y + 8, Width, level.name);
			U.TITLE_FONT.configureFlxText(title, 0xffffff, 'center');
			add(title);
			var Y:int = title.y + title.height + 8;
			
			pages = new Vector.<FlxText>;
			var description:FlxText = new FlxText(X, Y, Width, level.goal.description);
			U.BODY_FONT.configureFlxText(description);
			pages.push(add(description));
			
			if (level.expectedOps.length) {
				var optext:String =  "Ops to support: "
				for each (var op:OpcodeValue in level.expectedOps) {
					optext += "\n" + op;
					if (op.description)
						optext += ": " + op.description;
				}
				var expectedOps:FlxText = new FlxText(X, Y, Width, optext);
				pages.push(add(U.BODY_FONT.configureFlxText(expectedOps)));
			}
			
			var miscInfo:Array = [];
			if (level.delay)
				miscInfo.push("Propagation delay enabled.");
			if (level.goal is GeneratedGoal)
				miscInfo.push("Testing: " + (level.goal as GeneratedGoal).testRuns + " random programs, time limit of " + level.goal.timeLimit + " cycles per test");
			
			if (miscInfo.length) {
				var miscInfoText:FlxText = new FlxText(X, Y, Width, miscInfo.join('\n\n'));
				pages.push(add(U.BODY_FONT.configureFlxText(miscInfoText)));
			}
			
			var kludge:DGoal = this;
			add(new GraphicButton(bg.x + bg.width / 2 - 16, bg.y + bg.height - 48, _close_sprite, function close():void { kludge.exists = false } ))
			add(forwardButton = new GraphicButton(bg.x + bg.width - 48, bg.y + bg.height - 48, _forward_sprite, function forward():void { U.state.goalPage++; } ));
			add(backButton = new GraphicButton(bg.x + 16, bg.y + bg.height - 48, _back_sprite, function back():void { U.state.goalPage--; } ));
		}
		
		
		private var tick:int;
		
		override public function update():void {
			super.update();
			U.buttonManager.moused = true;
			checkPages();
			checkClick();
			checkControls();
			tick++;
		}
		
		protected function checkPages():void {
			for (var page:int = 0; page < pages.length; page++)
				pages[page].exists = page == U.state.goalPage;
			forwardButton.exists = U.state.goalPage < pages.length - 1;
			backButton.exists = U.state.goalPage > 0;
		}
		
		protected function checkClick():void {
			if (tick && FlxG.mouse.justPressed() && !bg.overlapsPoint(FlxG.mouse, true))
				exists = false;
		}
		
		protected function checkControls():void {
			if (ControlSet.CANCEL_KEY.justPressed())
				exists = false;
		}
		
		private const WIDTH_FRACTION:Number = 3 / 4;
		private const HEIGHT_FRACTION:Number = 3 / 4;
		
		[Embed(source = "../../lib/art/ui/close.png")] private const _close_sprite:Class;
		[Embed(source = "../../lib/art/ui/forward.png")] private const _forward_sprite:Class;
		[Embed(source = "../../lib/art/ui/back_w.png")] private const _back_sprite:Class;
	}

}