package  {
	import Components.Wire;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import Modules.*;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DEBUG {
		
		public static const RENDER_COLLIDE:Boolean = FlxG.debug && false;
		public static const RENDER_CURRENT:Boolean = FlxG.debug && false;
		public static const RENDER_BLOC_CONNECTIONS:Boolean = FlxG.debug && true;
		public static const PRINT_TESTS:Boolean = FlxG.debug && false;
		public static const PRINT_CONNECTIONS:Boolean = FlxG.debug && false;
		public static const SKIP_TUT:Boolean = FlxG.debug && true;
		public static const UNLOCK_ALL:Boolean = FlxG.debug && true;
		public static const IGNORE_SAVES:Boolean = FlxG.debug && false;
		public static const FORCE_LOAD_LEVEL:Boolean = FlxG.debug && false;
		public static const FORCE_LEVEL:String = '20';
		public static const FORCE_CODE:String = "81362d9946b3bffc12ea538b26e1bd5b"
		public static const PRESERVE_WIRES:Boolean = FlxG.debug && false;
		
		public static function runDebugStuff():void {
			if (!FlxG.debug)
				return;
		}
		
	}

}