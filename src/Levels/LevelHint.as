package Levels {
	import flash.geom.Point;
	import org.flixel.FlxSprite;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class LevelHint {
		
		public var graphic:Class;
		public var position:Point;
		public var checkVanish:Function;
		public function LevelHint(Graphic:Class, Position:Point, CheckVanish:Function  = null) {
			graphic = Graphic;
			position = Position;
			checkVanish = CheckVanish;
		}
		
		public function instantiate():FlxSprite {
			return new FlxSprite(position.x, position.y, graphic);
		}
		
	}

}