package LevelStates {
	import org.flixel.*;
	import Menu.LevelMenu;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SuccessState extends FlxState {
		
		public function SuccessState() {
			super();
		}
		
		override public function create():void {
			add(U.TITLE_FONT.configureFlxText(new FlxText(20, 20, FlxG.width - 40, "Victory!"), 0x0));
		}
		
		override public function update():void {
			super.update();
			if (FlxG.mouse.justPressed() || FlxG.keys.any())
				FlxG.switchState(new LevelMenu);
		}
		
	}

}