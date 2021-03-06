package LevelStates {
	import Levels.Level;
	import Menu.MenuState;
	import org.flixel.*;
	import UI.MenuButton;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SuccessState extends FlxState {
		
		public var level:Level;
		public var partsCount:int;
		public function SuccessState(level:Level, PartsCount:int) {
			this.level = level;
			partsCount = PartsCount;
			super();
			
			FlxG.bgColor = 0xff000000;
			FlxG.mouse.show();
			
			FlxG.flash(0xff000000, MenuButton.FADE_TIME);
		}
		
		override public function create():void {
			add(U.TITLE_FONT.configureFlxText(new FlxText(20, 20, FlxG.width - 40, "Victory!")));
			var timeInfo:String = level.goal.getTime();
			if (level.useTickRecord) {
				if (level.fewestTicks == level.goal.totalTicks)
					timeInfo += " (Best!)";
				else
					timeInfo += " (Best: " + level.fewestTicks + ")";
			}
			add(U.BODY_FONT.configureFlxText(new FlxText(20, 100, FlxG.width - 40, timeInfo))); 
			var setModuleRecord:Boolean = partsCount == level.fewestModules;
			if (level.useModuleRecord)
				add(U.BODY_FONT.configureFlxText(new FlxText(20, 140, FlxG.width - 40, "Modules used: " + partsCount + (setModuleRecord ? " (Best!)" : " (Best: " + level.fewestModules + ")"))));
			
			if (U.DEMO && level == U.DEMO_LIMIT)
				add(U.BODY_FONT.configureFlxText(new FlxText(20, 180, FlxG.width - 40, "This is the end of the demo! I hope you've enjoyed it. For more games, go to pleasingfungus.com, or follow development at pleasing.tumblr.com. Thanks for playing!")));
		}
		
		override public function update():void {
			super.update();
			if (FlxG.mouse.justPressed() || FlxG.keys.any())
				FlxG.fade(0xff000000, MenuButton.FADE_TIME, function switchStates():void {
					if (U.tutorialState == U.TUT_BEAT_TUT_1)
						FlxG.switchState(new LevelState(Level.ALL[1]));
					else 
						FlxG.switchState(new MenuState);
				});
		}
		
	}

}