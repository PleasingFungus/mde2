package Controls {
	/**
	 * ...
	 * @author Nicholas Feinberg
	 */
	public class ControlSet {
		
		public static const LEFT_KEY:Key = HybridKey.fromStrings("LEFT", "A");
		public static const UP_KEY:Key = HybridKey.fromStrings("UP", "W");
		public static const RIGHT_KEY:Key = HybridKey.fromStrings("RIGHT", "D");
		public static const DOWN_KEY:Key = HybridKey.fromStrings("DOWN", "S");
		public static const DIRECTION_KEYS:Array = [LEFT_KEY, UP_KEY, RIGHT_KEY, DOWN_KEY];
		
		public static const CONFIRM_KEY:Key = new Key("ENTER");
		public static const CANCEL_KEY:Key = new Key("ESCAPE");
		public static const DRAG_MODIFY_KEY:Key = new Key("SHIFT");
		public static const CLICK_MODIFY_KEY:Key = new Key("CONTROL");
		
		public static const HOME_KEY:Key = new Key("EIGHT"); //for scrolling
		public static const UI_ENABLE:Key = new Key("NINE");
		
		public static const COPY_KEY:Key = new Key("C");
		public static const PASTE_KEY:Key = new Key("V");
		public static const CUT_KEY:Key = new Key("X");
		public static const CUSTOM_KEY:Key = new Key("M"); //for making a custom module
		public static const DELETE_KEY:Key = new HybridKey(CUT_KEY, new Key("DELETE"));
		public static const MODULES_BACK:Key = new Key("Q");
		
		public static const UNDO:Key = new Key("Z");
		public static const REDO:Key = new Key("Y");
		
		public static const FAST:Key = new Key("E");
		public static const PLAY:Key = new Key("R");
		public static const TICK:Key = new Key("T");
		public static const STOP:Key = new Key("Y");
		public static const BACKTICK:Key = new Key("U");
		public static const PLAYBACK:Key = new Key("I");
		public static const BACKFAST:Key = new Key("O");
		public static const PAUSE:Key = new Key("SPACE");
		
		public static const TEST:Key = new Key("P");
		public static const HELP:Key = new Key("H");
		public static const MEMORY:Key = new Key("J");
		public static const ZOOM:Key = new Key("K");
		public static const SHARE:Key = new Key("L");
		
		
		
		
		public static const CONFIGURABLE_CONTROLS:Array = [];
		
		
		private static const keyListeners:Array = [];
		public static function registerKeyListener(func:Function):void {
			keyListeners.push(func);
		}
		
		public static function deregisterKeyListener(func:Function):void {
			var i:int = keyListeners.indexOf(func);
			if (i > -1)
				keyListeners.splice(i, 1);
		}
		
		public static function onKeyUp(keycode:int, shiftKey:Boolean):void {
			for each (var listener:Function in keyListeners)
				listener(keycode, shiftKey);
		}
		
		public static function save():void {
			var savedKeys:Array = [];
			for each (var key:Key in CONFIGURABLE_CONTROLS)
				savedKeys.push(key.key + '+' + key.modified);
			U.save.data["Controls"] = savedKeys;
		}
		
		public static function load():void {
			reset();
			
			var savedKeys:Array = U.save.data["Controls"] as Array;
			if (savedKeys)
				for (var i:int = 0; i < savedKeys.length && i < CONFIGURABLE_CONTROLS.length; i++) {
					var rawstr:String = savedKeys[i];
					var splitstr:Array = rawstr.split('+');
					var keystr:String = splitstr[0];
					var modbool:Boolean = splitstr[1] == 'true';
					
					if (keystr == "null")
						CONFIGURABLE_CONTROLS[i].key = null;
					else {
						CONFIGURABLE_CONTROLS[i].key = keystr;
						CONFIGURABLE_CONTROLS[i].modified = modbool;
					}
				}
		}
		
		public static function reset():void {
			NUMBER_HOTKEYS = new Vector.<Key>;
			for each (var number:String in C.NUMBERS)
				NUMBER_HOTKEYS.push(new Key(number));
		}
		
		public static var NUMBER_HOTKEYS:Vector.<Key>;
	}

}