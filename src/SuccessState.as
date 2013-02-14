package  {
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SuccessState extends FlxState {
		
		public function SuccessState() {
			super();
		}
		
		override public function create():void {
			add(new FlxText(20, 20, FlxG.width - 40, "Victory!").setFormat(U.FONT, U.FONT_SIZE * 4, 0x0));
		}
		
		override public function update():void {
			super.update();
			if (FlxG.mouse.justPressed() || FlxG.keys.any())
				FlxG.switchState(new MenuState);
		}
		
	}

}