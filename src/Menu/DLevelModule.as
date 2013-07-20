package Menu {
	import Displays.DModule;
	import Levels.LevelModule;
	import LevelStates.LevelState;
	import org.flixel.FlxG;
	import UI.MenuButton;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DLevelModule extends DModule {
		
		protected var levelModule:LevelModule;
		public function DLevelModule(module:LevelModule) {
			levelModule = module;
			super(module);
		}
		
		override protected function getColor():void {
			if (U.DEMO && U.DEMO_PERMITTED.indexOf(levelModule.level) == -1)
				color = 0xff404040;
			else if (!levelModule.unlocked)
				color = 0xff808080;
			else if (!U.buttonManager.moused && overlapsPoint(U.mouseFlxLoc, true))
				color = U.HIGHLIGHTED_COLOR;
			else
				super.getColor();
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
	}

}