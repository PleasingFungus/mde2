package Menu {
	import org.flixel.*;
	import UI.*;
	import LevelStates.LevelState;
	import Levels.Level;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class TutorialMenu extends FlxState {
		
		override public function create():void {
			U.enforceButtonPriorities = false;
			
			var title:FlxText = new FlxText(0, 20, FlxG.width, "TUTORIALS");
			U.TITLE_FONT.configureFlxText(title, 0xffffff, 'center');
			add(title);
			
			var levelSelectors:Vector.<MenuButton> = new Vector.<MenuButton>;
			for each (var level:Level in U.tuts) {
				var button:TextButton = new TextButton( -1, -1, level.name, function switchTo(level:Level):void { 
					FlxG.switchState(new LevelState(level));
				});
				button.setFormat(U.LABEL_FONT.id, U.LABEL_FONT.size, 0xffffff);
				button.fades = true;
				button.setParam(level);
				levelSelectors.push(button);
			}
			levelSelectors.push(new TextStateButton(MenuState, "Back"));
			
			var levelList:ButtonList = new ButtonList(FlxG.width / 2 - 100, FlxG.height / 4 + 20, levelSelectors);
			levelList.closesOnClickOutside = false;
			add(levelList);
			
			FlxG.bgColor = 0xff000000;
			FlxG.mouse.show();
			
			FlxG.flash(0xff000000, MenuButton.FADE_TIME);
		}
		
	}

}