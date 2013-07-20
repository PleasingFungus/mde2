package Levels {
	import flash.geom.Point;
	import org.flixel.FlxSprite;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class LevelHint extends FlxSprite {
		
		public var checkVanish:Function;
		public function LevelHint(X:int, Y:int, Graphic:Class, CheckVanish:Function = null) {
			super(X, Y, Graphic);
			checkVanish = CheckVanish;
		}
		
		override public function update():void {
			super.update();
			if (checkVanish != null && checkVanish()) {
				U.state.level.hintDone = true;
				exists = false;
			}
		}
	}

}