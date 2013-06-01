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
			if (overlapsPoint(U.mouseFlxLoc, true))
				color = U.HIGHLIGHTED_COLOR;
			else if (!levelModule.beaten)
				color = 0xff808080;
			else
				super.getColor();
		}
		
		override public function update():void {
			super.update();
			checkClick();
		}
		
		private function checkClick():void {
			if (!FlxG.mouse.justPressed())
				return;
			
			if (U.buttonManager.moused)
				return;
			
			if (overlapsPoint(U.mouseFlxLoc, true))
				FlxG.fade(0xff000000, MenuButton.FADE_TIME, switchLevels);
		}
		
		protected function switchLevels():void {
			FlxG.switchState(new LevelState(levelModule.level));
		}
	}

}