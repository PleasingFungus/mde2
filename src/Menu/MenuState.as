package Menu {
	import org.flixel.*;
	import UI.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class MenuState extends FlxState {
		
		override public function create():void {
			C.setPrintReady();
			U.init();
			
			var title:FlxText = new FlxText(0, 20, FlxG.width, "MULTIDUCK\nEXTRAVAGANZA");
			U.TITLE_FONT.configureFlxText(title, 0xffffff, 'center');
			add(title);
			
			var options:Vector.<MenuButton> = new Vector.<MenuButton>;
			
			options.push(new TextStateButton(TutorialMenu, "Tutorials"),
						 new TextStateButton(LevelMenu, "Play"));
			
			var optionList:ButtonList = new ButtonList(FlxG.width / 2 - 100, FlxG.height / 4 + 20, options);
			optionList.closesOnClickOutside = false;
			add(optionList);
			
			FlxG.bgColor = 0xff000000;
			FlxG.mouse.show();
			
			FlxG.flash(0xff000000, MenuButton.FADE_TIME);
		}
		
	}

}