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
				var tip:String = mousedModule.name;
				if (mousedModule.getDescription())
					tip += ": " + mousedModule.getDescription();
				renderBuddy.text.text = tip;
				
				lastModule = mousedModule;
			}
		}
		
		override public function draw():void {
			if (!renderBuddy) return;
			position();
			super.draw();
		}
		
		private function position():void {
			renderBuddy.x = FlxG.mouse.x - FlxG.camera.scroll.x + XPAD;
			renderBuddy.y = FlxG.mouse.y - FlxG.camera.scroll.y + YPAD;
			
			if (renderBuddy.x + renderBuddy.width > FlxG.width)
				renderBuddy.x -= renderBuddy.width + XPAD;
			if (renderBuddy.y + renderBuddy.height > FlxG.height)
				renderBuddy.y -= renderBuddy.height + YPAD;
		}
		
		private var XPAD:int = 20;
		private var YPAD:int = 35;
	}

}