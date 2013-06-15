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
	public class CreditsState extends FlxState {
		
		override public function create():void {
			var title:FlxText = new FlxText(0, 20, FlxG.width, "CREDITS");
			U.TITLE_FONT.configureFlxText(title, 0xffffff, 'center');
			add(title);
			
			var me:FlxText = U.BODY_FONT.configureFlxText(new FlxText(15, title.y + title.height + 20, FlxG.width - 25, "Developer: Nicholas Feinberg")); 
			add(me);
			
			var contButton:MenuButton = new TextButton(FlxG.width / 2 - 30, FlxG.height - 50, "Back", function cont():void {
				FlxG.switchState(new MenuState);
			}).setFormat(U.LABEL_FONT.id, U.LABEL_FONT.size, 0xffffff);
			contButton.fades = true;
			add(contButton);
			
			FlxG.bgColor = 0xff000000;
			FlxG.mouse.show();
			FlxG.flash(0xff000000, MenuButton.FADE_TIME);
		}
		
	}

}