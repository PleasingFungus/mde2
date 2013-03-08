package Displays {
	import Modules.Module;
	import org.flixel.*;
	import UI.FloatText;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DModuleInfo extends FlxBasic {
		
		private var lastModule:Module;
		private var renderBuddy:FloatText;
		public function DModuleInfo() {
			super();
		}
		
		override public function update():void {
			if (!renderBuddy)
				U.state.upperLayer.add(renderBuddy = new FloatText(U.LABEL_FONT.configureFlxText(new FlxText( -1, -1, 300, " "), 0xffffff)));
			renderBuddy.visible = U.state.VIEW_MODE_NORMAL == U.state.viewMode;
			if (renderBuddy.visible)
				checkMouse();
			super.update();
		}
		
		private function checkMouse():void {
			var mousedModule:Module = U.state.findMousedModule();
			renderBuddy.visible = mousedModule != null;
			if (mousedModule && mousedModule != lastModule) {
				renderBuddy.text.text = mousedModule.name +": "+mousedModule.getDescription();
				lastModule = mousedModule;
			}
		}
		
		override public function draw():void {
			if (!renderBuddy) return;
			position();
			super.draw();
		}
		
		private function position():void {
			renderBuddy.x = FlxG.mouse.x - FlxG.camera.scroll.x + PAD;
			renderBuddy.y = FlxG.mouse.y - FlxG.camera.scroll.y + PAD;
			
			if (renderBuddy.x + renderBuddy.width > FlxG.width || renderBuddy.y + renderBuddy.height > FlxG.height) {
				renderBuddy.x -= renderBuddy.width + PAD;
				renderBuddy.y -= renderBuddy.height + PAD;
			}
		}
		
		private var PAD:int = 20;
	}

}