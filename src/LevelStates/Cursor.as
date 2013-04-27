package LevelStates {
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Cursor {
		
		public var rawSprite:Class;
		public var offsetX:int;
		public var offsetY:int;
		public function Cursor(RawSprite:Class, OffsetX:int = 0, OffsetY:int = 0) {
			rawSprite = RawSprite;
			offsetX = OffsetX;
			offsetY = OffsetY;
		}
		
		public function equals(cursor:Cursor):Boolean {
			return cursor && cursor.rawSprite == rawSprite;
		}
		
		[Embed(source = "../../lib/art/ui/pen.png")] private static const _pen_cursor:Class;
		[Embed(source = "../../lib/art/ui/grabby_cursor.png")] private static const _grab_cursor:Class;
		[Embed(source = "../../lib/art/ui/wrench_cursor.png")] private static const _wrench_cursor:Class;
		[Embed(source = "../../lib/art/ui/sel.png")] private static const _select_cursor:Class;
		
		public static const PEN:Cursor = new Cursor(_pen_cursor);
		public static const GRAB:Cursor = new Cursor(_grab_cursor, -4, -3);
		public static const EDIT:Cursor = new Cursor(_wrench_cursor, -3, -3);
		public static const SEL:Cursor = new Cursor(_select_cursor);
	}

}