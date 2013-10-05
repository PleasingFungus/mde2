package Menu {
	import Displays.DModule;
	import flash.geom.Rectangle;
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
		
		override public function refresh():void {
			super.refresh();
			livery = new FlxSprite(x, y).makeGraphic(width, height, 0xffffffff, true, 'livery' + width + ',' + height);
			livery.pixels.fillRect(new Rectangle(LIVERY_WIDTH, LIVERY_WIDTH, width - LIVERY_WIDTH * 2, height - LIVERY_WIDTH * 2), 0x0); //transparent
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
			if (!isNaN(levelModule.zoom))
				U.zoom = levelModule.zoom;
			FlxG.switchState(new LevelState(levelModule.level));
		}
		
		override public function draw():void {
			super.draw();
			if (levelModule.beaten) {
				livery.color = color == U.HIGHLIGHTED_COLOR ? levelModule.level.isBonus ? MODULE_RED : MODULE_BLUE : U.HIGHLIGHTED_COLOR;
				livery.x = x;
				livery.y = y;
				livery.draw();
			}
		}
		
		protected const MODULE_DARK_GRAY:uint = 0xff404040;
		protected const LIVERY_WIDTH:int = 2;
	}

}