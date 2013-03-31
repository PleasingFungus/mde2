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
		public function SuccessState(level:Level) {
			this.level = level;
			super();
			
			FlxG.bgColor = 0xff000000;
			FlxG.mouse.show();
			
			FlxG.flash(0xff000000, MenuButton.FADE_TIME);
		}
		
		override public function create():void {
			add(U.TITLE_FONT.configureFlxText(new FlxText(20, 20, FlxG.width - 40, "Victory!")));
			add(U.BODY_FONT.configureFlxText(new FlxText(20, 100, FlxG.width - 40, level.goal.getTime())));
		}
		
		override public function update():void {
			super.update();
			if (FlxG.mouse.justPressed() || FlxG.keys.any())
				FlxG.fade(0xff000000, MenuButton.FADE_TIME, function switchStates():void {
					if (U.tutorialState == U.TUT_BEAT_TUT_1)
						FlxG.switchState(new LevelState(U.levels[1]));
					else 
						FlxG.switchState(new MenuState);
				});
		}
		
	}

}