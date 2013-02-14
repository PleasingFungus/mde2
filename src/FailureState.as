package  {
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class FailureState extends FlxState {
		
		private var level:Level
		public function FailureState(level:Level) {
			this.level = level;
		}
		
		override public function create():void {
			add(new FlxText(20, 20, FlxG.width - 40, "Timeout...").setFormat(U.FONT, U.FONT_SIZE * 4, 0x0));
		}
		
		override public function update():void {
			super.update();
			if (FlxG.mouse.justPressed() || FlxG.keys.any())
				FlxG.switchState(new LevelState(level));
		}
		
		
	}

}