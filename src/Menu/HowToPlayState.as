package Menu {
	import Levels.Level;
	import LevelStates.LevelState;
	import org.flixel.*;
	import UI.MenuButton;
	import UI.TextButton;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class HowToPlayState extends FlxState {
		
		override public function create():void {
			var title:FlxText = new FlxText(0, 20, FlxG.width, "HOW TO PLAY");
			U.TITLE_FONT.configureFlxText(title, 0xffffff, 'center');
			add(title);
			
			var howToPlay:FlxText = U.BODY_FONT.configureFlxText(new FlxText(15, title.y + title.height + 20, FlxG.width - 25, "MDE2 is made up of many levels."));
			howToPlay.text += "\n\nIn each level, your goal is to build a machine that will change memory (a long list of numbers, mostly empty) in the way the level describes."
			howToPlay.text += "\n\nGood luck!"; 
			add(howToPlay);
			
			var contButton:MenuButton = new TextButton(FlxG.width / 2 - 30, FlxG.height - 50, "Continue", function cont():void {
				if (U.tutorialState < U.TUT_BEAT_TUT_1)
					FlxG.switchState(new LevelState(Level.FIRST));
				else
					FlxG.switchState(new MenuState);
			}).setFormat(U.LABEL_FONT.id, U.LABEL_FONT.size, 0xffffff);
			contButton.fades = true;
			add(contButton);
			
			FlxG.bgColor = 0xff000000;
			FlxG.mouse.show();
			
			U.updateTutState(U.TUT_READ_HTP);
			FlxG.flash(0xff000000, MenuButton.FADE_TIME);
		}
		
	}

}