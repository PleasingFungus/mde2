package Helpers {
	import org.flixel.*;
	import Controls.Key;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class KeyHelper extends FlxSprite {
		
		public var key:Key;
		public var presses:int;
		public var pressTime:Number;
		public function KeyHelper(key:Key) {
			super();
			this.key = key;
			generate();
			presses = 0;
			pressTime = 0;
		}
		
		public function generate():void {
			if (key.key == "SPACE") {
				loadGraphic(spaceKey);
				return;
			}
			
			loadGraphic(keyBase, false, false, 32, 32, true, key.key);
			if (!key.key) //unbound
				return; //blank key
			
			var keySpr:FlxSprite;
			
			var dir:int = ARROWS_BY_NAME.indexOf(key.key);
			if (dir != -1) {
				keySpr = new FlxSprite().loadGraphic(arrow_pngs[dir]);
				stamp(keySpr, 8, 8);
			} else {
				keySpr = new FlxText(0, 0, width, getText()).setFormat(U.MUNRO, 16, 0x1, 'center');
				stamp(keySpr, 0, 4);
			}
			
		}
		
		protected function getText():String {
			return key.toString();
		}
		
		override public function update():void {
			super.update();
			if (key.pressed()) {
				pressTime += FlxG.elapsed;
				if (key.justPressed())
					presses++;
			}
		}
		
		override public function draw():void {
			alpha = key.pressed() ? 1 : 0.5;
			super.draw();
		}
		
		
		public static const ARROWS_BY_NAME:Array = ["LEFT", "UP", "RIGHT", "DOWN"];
		
		[Embed(source = "../../lib/art/help/key.png")] private static const keyBase:Class;
		[Embed(source = "../../lib/art/help/spacekey.png")] private static const spaceKey:Class;
		
		[Embed(source = "../../lib/art/help/leftarrow.png")] private static const _key_left:Class;
		[Embed(source = "../../lib/art/help/uparrow.png")] private static const _key_up:Class;
		[Embed(source = "../../lib/art/help/rightarrow.png")] private static const _key_right:Class;
		[Embed(source = "../../lib/art/help/downarrow.png")] private static const _key_down:Class;
		private static const arrow_pngs:Array = [_key_left, _key_up, _key_right, _key_down];
	}

}