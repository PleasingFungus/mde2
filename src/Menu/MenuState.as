package Menu {
	import Displays.Scroller;
	import flash.net.URLLoader;
	import Levels.Level;
	import Levels.LevelModule;
	import org.flixel.*;
	import UI.*;
	import LevelStates.LevelState
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class MenuState extends FlxState {
		
		private var lastZoom:Number;
		
		override public function create():void {
			C.setPrintReady();
			U.init();
			DEBUG.runDebugStuff();
			
			if (loadFromURL())
				return;
			
			if (U.tutorialState == U.TUT_NEW && !DEBUG.SKIP_TUT) {
				FlxG.switchState(new HowToPlayState); return;
			}
			
			add(new ButtonManager);
			var levelDisplay:LevelDisplay = new LevelDisplay;
			add(levelDisplay);
			add(new MenuSidebar(MENU_BAR_WIDTH));
			
			lastZoom = U.zoom;
			U.zoom = 1;
			setBounds(levelDisplay.bounds);
			add(new Scroller("menustate"));
			
			FlxG.bgColor = U.BG_COLOR;
			FlxG.mouse.show();
			
			FlxG.flash(0xff000000, MenuButton.FADE_TIME);
		}
		
		protected function setBounds(bounds:FlxRect):void {
			var screenWidth:int = FlxG.width;// - MENU_BAR_WIDTH;
			var screenHeight:int = FlxG.height - MENU_BAR_WIDTH;
			bounds.height += MENU_BAR_WIDTH;
			
			if (bounds.width < screenWidth) {
				bounds.x -= (screenWidth - bounds.width) / 2;
				bounds.width = screenWidth;
			}
			if (bounds.height < screenHeight) {
				bounds.y -= (screenHeight - bounds.height) / 2;
				bounds.height = screenHeight;
			}
			
			FlxG.camera.bounds = bounds;
		}
		
		private function loadFromURL():Boolean {
			if (U.checkedURL)
				return false;
			U.checkedURL = true;
			
			var lvl:String, code:String;
			if (DEBUG.FORCE_LOAD_LEVEL) {
				lvl = DEBUG.FORCE_LEVEL;
				code = DEBUG.FORCE_CODE;
			} else {
				var path:QueryString = new QueryString;
				lvl = path.parameters.lvl;
				code = path.parameters.code;
			}
			
			if (!lvl)
				return false;
			
			try {
				var levelIndex:int = C.safeInt(lvl);
			} catch (error:Error) {
				addErrorText("Bad level index!");
				return false;
			}
			
			if (levelIndex < 0 || levelIndex > Level.ALL.length || !Level.ALL[levelIndex]) {
				addErrorText("Bad level index!");
				return false;
			}
			
			var level:Level = Level.ALL[levelIndex];
			if (!level.unlocked() && !DEBUG.UNLOCK_ALL) {
				addErrorText("Level " + levelIndex + " not unlocked!");
				return false;
			}
			
			if (!code) {			
				FlxG.switchState(new LevelState(level));
				return true;
			}
			
			var loader:URLLoader = C.sendRequest(U.LOOKUP_URL, { 'hash' : code }, function onLoad(e : Event):void {
				var response:String = loader.data;
				if (response.indexOf("ERROR") == 0) {
					addErrorText(response);
					return;
				}
				
				FlxG.switchState(new LevelState(level, response));
			});
			
			add(U.BODY_FONT.configureFlxText(new FlxText(0, 20, FlxG.width, "Waiting for server...")));
			return true;
		}
		
		private function addErrorText(error:String, y:int=0):void {
			add(U.BODY_FONT.configureFlxText(new FlxText(0, y, FlxG.width, error)));
		}
		
		override public function update():void {
			if (FlxG.camera.fading)
				return;
			
			super.update();
		}
		
		private const MENU_BAR_WIDTH:int = 60;
	}

}