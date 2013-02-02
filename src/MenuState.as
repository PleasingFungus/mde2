package  {
	import org.flixel.*;
	import Testing.Test;
	import UI.ButtonList;
	import UI.TextButton;
	import UI.MenuButton;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class MenuState extends FlxState {
		
		override public function create():void {
			C.setPrintReady();
			U.init();
			
			var title:FlxText = new FlxText(0, 20, FlxG.width, "MULTIDUCK\nEXTRAVAGANZA");
			title.setFormat(U.FONT, 32, 0xffffff, 'center');
			add(title);
			
			var levelSelectors:Vector.<MenuButton> = new Vector.<MenuButton>;
			for each (var level:Level in U.levels) {
				var button:TextButton = new TextButton( -1, -1, level.name, function switchTo(level:Level):void { 
					FlxG.switchState(new LevelState(level));
				});
				button.setFormat(U.FONT, 16, 0xffffff);
				button.fades = true;
				button.setParam(level);
				levelSelectors.push(button);
			}
			
			var levelList:ButtonList = new ButtonList(FlxG.width / 2 - 80, FlxG.height / 2 - 60, levelSelectors);
			levelList.closesOnClickOutside = false;
			add(levelList);
			
			FlxG.bgColor = 0xff000000;
			FlxG.mouse.show();
		}
		
	}

}