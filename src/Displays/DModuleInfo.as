package Displays {
	import Modules.Module;
	import org.flixel.*;
	import UI.FloatText;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DModuleInfo extends FloatText {
		
		private var lastModule:Module;
		public function DModuleInfo() {
			super(U.LABEL_FONT.configureFlxText(new FlxText( -1, -1, 300, " "), 0xffffff));
		}
		
		override public function update():void {
			checkMouse();
			super.update();
		}
		
		private function checkMouse():void {
			var mousedModule:Module = U.state.findMousedModule();
			visible = mousedModule != null;
			if (mousedModule && mousedModule != lastModule) {
				text.text = mousedModule.name +": "+mousedModule.getDescription();
				lastModule = mousedModule;
			}
		}
		
		override public function draw():void {
			position();
			super.draw();
		}
		
		private function position():void {
			x = FlxG.mouse.x - FlxG.camera.scroll.x + PAD;
			y = FlxG.mouse.y - FlxG.camera.scroll.y + PAD;
			
			if (x + width > FlxG.width || y + height > FlxG.height) {
				x -= width + PAD;
				y -= height + PAD;
			}
		}
		
		private var PAD:int = 20;
	}

}