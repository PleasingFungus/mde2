package Menu {
	import Displays.Clock;
	import Displays.Scroller;
	import Levels.Level;
	import org.flixel.*;
	import UI.*;
	import LevelStates.LevelState
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class MenuState extends FlxState {
		
		private var lastZoom:Number;
		
		override public function create():void {
			C.setPrintReady();
			U.init();
			
			if (loadFromURL())
				return;
			
			if (!U.tutorialState && !DEBUG.SKIP_TUT) {
				FlxG.switchState(new HowToPlayState); return;
			}
			
			var title:FlxText = new FlxText(FlxG.width / 2, 20, FlxG.width * 2/4 - 10, "MULTIDUCK\nEXTRAVAGANZA");
			U.TITLE_FONT.configureFlxText(title, 0xffffff, 'center');
			add(title);
			
			var X:int = 10;
			var Y:int = 40;
			
			var howToPlayButton:MenuButton = new TextStateButton(HowToPlayState, U.tutorialState > U.TUT_READ_HTP ? "How To Play" : "Play");
			howToPlayButton.X = X;
			howToPlayButton.Y = Y;
			add(howToPlayButton);
			Y += howToPlayButton.fullHeight + 20;
			
			for each (var levelCol:Vector.<Level> in Level.columns) {
				X = 10;
				var colButtons:Vector.<MenuButton> = new Vector.<MenuButton>;
				for each (var level:Level in levelCol) {
					if (!DEBUG.UNLOCK_ALL && !level.unlocked())
						continue;
					
					var button:TextButton = new TextButton(X, Y, level.displayName, function switchTo(level:Level):void {
						U.zoom = lastZoom;
						FlxG.switchState(new LevelState(level));
					});
					button.setFormat(U.LABEL_FONT.id, U.LABEL_FONT.size, level.successSave ? U.HIGHLIGHTED_COLOR : 0xffffff);
					button.fades = true;
					button.setParam(level);
					add(button);
					colButtons.push(button);
					X += button.fullWidth + 20;
					
					if (level == Level.last) {
						FlxG.camera.scroll.x = button.X + button.fullWidth / 2 - FlxG.width / 2;
						FlxG.camera.scroll.y = button.Y + button.fullHeight / 2 - FlxG.height / 2;
					}
					
					if (level.useModuleRecord && level.fewestModules) {
						add(U.BODY_FONT.configureFlxText(new FlxText(button.X - 5, button.Y + button.fullHeight - 15, button.fullWidth, level.fewestModules.toString()), U.HIGHLIGHTED_COLOR));
					}
					if (level.useTickRecord && level.fewestTicks) {
						add(U.BODY_FONT.configureFlxText(new FlxText(button.X + 15, button.Y + button.fullHeight - 15, button.fullWidth, level.fewestTicks.toString()), U.HIGHLIGHTED_COLOR, 'right'));
					}
				}
				
				var colHeight:int = 44;
				for each (button in colButtons)
					colHeight = Math.max(colHeight, button.fullHeight);
				Y += colHeight + 20;
			}
			
			lastZoom = U.zoom;
			U.zoom = 1;
			add(new Scroller("menustate"));
			
			FlxG.bgColor = 0xff000000;
			FlxG.mouse.show();
			
			FlxG.flash(0xff000000, MenuButton.FADE_TIME);
		}
		
		private function loadFromURL():Boolean {
			if (U.checkedURL)
				return false;
			U.checkedURL = true;
			
			var path:QueryString = new QueryString;
			if (!path.parameters.lvl)
				return false;
			
			try {
				var levelIndex:int = C.safeInt(path.parameters.lvl);
			} catch (error:Error) {
				addErrorText("Bad level index!");
				return false;
			}
			
			if (levelIndex < 0 || levelIndex > U.levels.length || !U.levels[levelIndex]) {
				addErrorText("Bad level index!");
				return false;
			}
			
			var level:Level = U.levels[levelIndex];
			if (!level.unlocked() && !DEBUG.UNLOCK_ALL) {
				addErrorText("Level " + levelIndex + " not unlocked!");
				return false;
			}
			
			//TODO: grab data
			
			FlxG.switchState(new LevelState(level));
			return true;
		}
		
		private function addErrorText(error:String):void {
			add(U.BODY_FONT.configureFlxText(new FlxText(0, 0, FlxG.width, error)));
		}
		
	}

}