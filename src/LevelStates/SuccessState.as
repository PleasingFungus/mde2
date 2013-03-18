package LevelStates {
	import Levels.Level;
	import Menu.DelayTutMenu;
	import Menu.TutorialMenu;
	import org.flixel.*;
	import Menu.LevelMenu;
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
		}
		
		override public function update():void {
			super.update();
			if (FlxG.mouse.justPressed() || FlxG.keys.any())
				FlxG.fade(0xff000000, MenuButton.FADE_TIME, function switchStates():void {
					if (U.tutorialState == U.TUT_BEAT_TUT_1)
						FlxG.switchState(new LevelState(U.tuts[1]));
					else if (U.tuts.indexOf(level) != -1)
						FlxG.switchState(new TutorialMenu);
					else if (U.delayTuts.indexOf(level) != -1)
						FlxG.switchState(new DelayTutMenu);
					else
						FlxG.switchState(new LevelMenu);
				});
		}
		
	}

}