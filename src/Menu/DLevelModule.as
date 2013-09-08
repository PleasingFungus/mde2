package Menu {
	import Displays.DModule;
	import Levels.LevelModule;
	import LevelStates.LevelState;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	import UI.MenuButton;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DLevelModule extends DModule {
		
		protected var levelModule:LevelModule;
		protected var livery:FlxSprite;
		public function DLevelModule(module:LevelModule) {
			levelModule = module;
			super(module);
		}
		
		override protected function getColor():void {
			if (U.DEMO && U.DEMO_PERMITTED.indexOf(levelModule.level) == -1)
				color = MODULE_DARK_GRAY;
			else if (!levelModule.unlocked)
				color = MODULE_GRAY;
			else if (!U.buttonManager.moused && overlapsPoint(U.mouseFlxLoc, true))
				color = U.HIGHLIGHTED_COLOR;
			else if (levelModule.level.isBonus)
				color = MODULE_RED;
			else
				color = MODULE_BLUE;
		}
		
		override public function update():void {
			super.update();
			checkClick();
		}
		
		private function checkClick():void {
			if (!U.buttonManager.moused && FlxG.mouse.justPressed() && overlapsPoint(U.mouseFlxLoc, true) && levelModule.unlocked)
				FlxG.fade(0xff000000, MenuButton.FADE_TIME, switchLevels);
		}
		
		protected function switchLevels():void {
			FlxG.switchState(new LevelState(levelModule.level));
		}
		
		protected const MODULE_DARK_GRAY:uint = 0xff404040;
	}

}