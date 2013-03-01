package LevelStates {
	import org.flixel.*;
	import Levels.Level;
	
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
			add(U.TITLE_FONT.configureFlxText(new FlxText(20, 20, FlxG.width - 40, "Timeout..."), 0x0));
		}
		
		override public function update():void {
			super.update();
			if (FlxG.mouse.justPressed() || FlxG.keys.any())
				FlxG.switchState(new LevelState(level));
		}
		
		
	}

}