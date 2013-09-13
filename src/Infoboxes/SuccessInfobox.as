package Infoboxes {
	import Levels.Level;
	import LevelStates.LevelState;
	import Menu.MenuState;
	import org.flixel.*;
	import UI.MenuButton;
	import UI.GraphicButton
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SuccessInfobox extends Infobox {
		
		public var level:Level;
		public var partsCount:int;
		public function SuccessInfobox(level:Level, PartsCount:int) {
			this.level = level;
			partsCount = PartsCount;
			super();
		}
		
		override protected function init():void {
			super.init();
			
			var title:FlxText = U.TITLE_FONT.configureFlxText(new FlxText(bg.x + 20, bg.y + 10, bg.width - 40, "Victory!"), 0xffffff, 'center');
			add(title);
			setPageTop(title.y + title.height + 5);
			
			var timeInfo:String = level.goal.getTime();
			if (level.useTickRecord) {
				if (level.fewestTicks == level.goal.totalTicks)
					timeInfo += " (Best!)";
				else
					timeInfo += " (Best: " + level.fewestTicks + ")";
			}
			page.add(U.BODY_FONT.configureFlxText(new FlxText(bg.x + 20, bg.y + 100, bg.width - 40, timeInfo), 0xffffff, 'center')); 
			
			var setModuleRecord:Boolean = partsCount == level.fewestModules;
			if (level.useModuleRecord)
				page.add(U.BODY_FONT.configureFlxText(new FlxText(bg.x + 20, bg.y + 140, bg.width - 40, "Modules used: " + partsCount + (setModuleRecord ? " (Best!)" : " (Best: " + level.fewestModules + ")")), 0xffffff, 'center'));
			
			if (U.DEMO && level == U.DEMO_LIMIT)
				page.add(U.BODY_FONT.configureFlxText(new FlxText(bg.x + 20, bg.y + 180, bg.width - 40, "This is the end of the demo! I hope you've enjoyed it. For more games, go to pleasingfungus.com, or follow development at pleasing.tumblr.com. Thanks for playing!")));
			
			var backButton:GraphicButton = new GraphicButton(bg.x + bg.width / 2, bg.y + bg.height - 54, _back_sprite, function back():void {
				FlxG.switchState(new MenuState);
			}, "Exit to menu");
			backButton.X -= backButton.fullWidth / 2;
			backButton.fades = true;
			add(backButton);
			addLabelFor(backButton, "Menu");
			
			var successors:Vector.<Level> = level.nonBonusSuccessors;
			if (successors.length == 1 && successors[0].unlocked()) {
				var nextButton:GraphicButton = new GraphicButton(backButton.X + backButton.fullWidth + 8, backButton.Y, _next_sprite, function next():void {
					FlxG.switchState(new LevelState(successors[0]));
				}, "Continue to next level");
				nextButton.fades = true;
				add(nextButton);
				addLabelFor(nextButton, "Next");
			}
		}
		
		protected function addLabelFor(button:MenuButton, label:String):void {
			var extraWidth:int = 10;
			var labelText:FlxText = new FlxText(button.X - extraWidth / 2 - 1, button.Y + button.fullHeight - 2, button.fullWidth + extraWidth, label);
			U.TOOLBAR_FONT.configureFlxText(labelText, 0xffffff, 'center');
			labelText.scrollFactor.x = labelText.scrollFactor.y = 0;
			button.add(labelText);
		}
		
		[Embed(source = "../../lib/art/ui/up.png")] private const _back_sprite:Class;
		[Embed(source = "../../lib/art/ui/next.png")] private const _next_sprite:Class;
	}

}