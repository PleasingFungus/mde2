package UI {
	import org.flixel.FlxBasic;
	import org.flixel.FlxPoint;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public interface FlxBounded {
		function overlapsPoint(p:FlxPoint):Boolean;
		function get basic():FlxBasic;
	}
	
}