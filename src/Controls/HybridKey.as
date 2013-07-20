package Controls {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class HybridKey extends Key {
		
		public var keys:Vector.<Key>;
		public function HybridKey(...Keys) {
			keys = new Vector.<Key>;
			for each (var key:Key in Keys)
				keys.push(key);
			super(keys[0].key, keys[0].modified);
		}
		
		override public function pressed():Boolean {
			for each (var key:Key in keys)
				if (key.pressed())
					return true;
			return false;
		}
		
		override public function justPressed():Boolean {
			for each (var key:Key in keys)
				if (key.justPressed())
					return true;
			return false;
		}
		
		override public function justReleased():Boolean {
			for each (var key:Key in keys)
				if (key.justReleased())
					return true;
			return false;
		}
		
		override public function toString():String {
			return keys[0].toString(); //eh
		}
		
		public static function fromStrings(...strings):HybridKey {
			var key:HybridKey = new HybridKey(new Key(strings[0]));
			for (var i:int = 1; i < strings.length; i++)
				key.keys.push(new Key(strings[i]));
			return key;
		}
	}

}