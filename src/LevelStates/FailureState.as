package LevelStates {
	import org.flixel.*;
	import Levels.Level;
	import UI.MenuButton;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class FailureState extends FlxState {
		
		private var level:Level
		public function FailureState(level:Level) {
			this.level = level;
			
			FlxG.bgColor = 0xff000000;
			FlxG.mouse.show();
			
			FlxG.flash(0xff000000, MenuButton.FADE_TIME);
			
		}
		
		override public function create():void {
			add(U.TITLE_FONT.configureFlxText(new FlxText(20, 20, FlxG.width - 40, "Timeout...")));
			add(U.BODY_FONT.configureFlxText(new FlxText(20, 100, FlxG.width - 40, level.goal.getTime())));
		}
		
		override public function update():void {
			super.update();
			if (FlxG.mouse.justPressed() || FlxG.keys.any())
				FlxG.fade(0xff000000, MenuButton.FADE_TIME, function switchStates():void { 
					FlxG.switchState(new LevelState(level));
				});
		}
		
		
	}

}