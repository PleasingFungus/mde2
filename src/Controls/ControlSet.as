package Controls {
	/**
	 * ...
	 * @author Nicholas Feinberg
	 */
	public class ControlSet {
		
		public static const LEFT_KEY:Key = new Key("LEFT");
		public static const UP_KEY:Key = new Key("UP");
		public static const RIGHT_KEY:Key = new Key("RIGHT");
		public static const DOWN_KEY:Key = new Key("DOWN");
		public static const DIRECTION_KEYS:Array = [LEFT_KEY, UP_KEY, RIGHT_KEY, DOWN_KEY];
		
		public static const CONFIRM_KEY:Key = new Key("ENTER");
		public static const CANCEL_KEY:Key = new Key("ESCAPE");
		public static const DRAG_MODIFY_KEY:Key = new Key("SHIFT");
		public static const CLICK_MODIFY_KEY:Key = new Key("CONTROL");
		
		public static const HOME_KEY:Key = new Key("H");
		public static const COPY_KEY:Key = new Key("C");
		public static const PASTE_KEY:Key = new Key("V");
		public static const CUT_KEY:Key = new Key("X");
		public static const CUSTOM_KEY:Key = new Key("W");
		public static const DELETE_KEY:Key = new HybridKey([CUT_KEY, new Key("DELETE")]);
		
		
		
		
		
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