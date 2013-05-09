package Helpers {
	import Controls.ControlSet;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DeleteHelper extends KeyHelper {
		
		public function DeleteHelper() {
			super(ControlSet.DELETE_KEY);
			exists = false;
		}
		
		override protected function getText():String {
			return "DEL";
		}
		
		override public function draw():void {
			x = FlxG.mouse.x - FlxG.camera.scroll.x - width - 2;
			y = FlxG.mouse.y - FlxG.camera.scroll.y - height - 2;
			super.draw();
		}
		
	}

}