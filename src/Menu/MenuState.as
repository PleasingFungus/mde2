package Menu {
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
		
		override public function create():void {
			C.setPrintReady();
			U.init();
			
			var title:FlxText = new FlxText(FlxG.width / 2, 20, FlxG.width * 2/4 - 10, "MULTIDUCK\nEXTRAVAGANZA");
			U.TITLE_FONT.configureFlxText(title, 0xffffff, 'center');
			add(title);
			
			var X:int = 10;
			var Y:int = 10;
			
			var howToPlayButton:MenuButton = new TextStateButton(HowToPlayState, U.tutorialState > U.TUT_READ_HTP ? "How To Play" : "Play");
			howToPlayButton.X = X;
			howToPlayButton.Y = Y;
			add(howToPlayButton);
			Y += howToPlayButton.fullHeight + 20;
			
			for each (var levelCol:Vector.<Level> in Level.columns) {
				X = 10;
				var colButtons:Vector.<MenuButton> = new Vector.<MenuButton>;
				for each (var level:Level in levelCol) {
					var button:TextButton = new TextButton(X, Y, level.name, function switchTo(level:Level):void { 
						FlxG.switchState(new LevelState(level));
					});
					button.setFormat(U.LABEL_FONT.id, U.LABEL_FONT.size, 0xffffff);
					button.fades = true;
					button.setParam(level);
					add(button);
					colButtons.push(button);
					X += button.fullWidth + 20;
					
					if (level == Level.last) {
						FlxG.camera.scroll.x = button.X + button.fullWidth / 2 - FlxG.width / 2;
						FlxG.camera.scroll.y = button.Y + button.fullHeight / 2 - FlxG.height / 2;
					}
				}
				
				var colHeight:int = 0;
				for each (button in colButtons)
					colHeight = Math.max(colHeight, button.fullHeight);
				Y += colHeight + 20;
			}
			
			add(new Scroller);
			
			FlxG.bgColor = 0xff000000;
			FlxG.mouse.show();
			
			FlxG.flash(0xff000000, MenuButton.FADE_TIME);
		}
		
	}

}