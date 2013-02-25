package UI {
	import org.flixel.FlxText;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class FontTuple {
		
		public var name:String;
		public var size:int;
		public var id:String;
		public function FontTuple(Id:String, Size:int, Name:String = null) {
			id = Id;
			size = Size;
			name = Name ? Name : Id;
		}
		
		public function toString():String {
			return name +": " + size;
		}
		
		public function configureFlxText(text:FlxText, Color:uint = 0xffffff, Alignment:String = null, ShadowColor:int = 0):FlxText {
			return text.setFormat(id, size, Color, Alignment, ShadowColor);
		}
	}

}