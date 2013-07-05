package Displays {
	import Modules.Module;
	import org.flixel.*;
	import UI.ColorText;
	import UI.FloatText;
	import UI.HighlightFormat;
	import UI.HighlightText;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DModuleInfo extends FlxBasic {
		
		private var renderBuddy:FloatText;
		private var displayModules:Vector.<DModule>;
		public function DModuleInfo(DisplayModules:Vector.<DModule>) {
			super();
			displayModules = DisplayModules;
		}
		
		override public function update():void {
			if (!renderBuddy)
				U.state.upperLayer.add(
					renderBuddy = new FloatText(
						U.LABEL_FONT.configureFlxText(
							new HighlightText( -1, -1, 300, " ", new Vector.<ColorText>),
							0xffffff)
						)
					);
			
			var mousedDModule:DModule = U.state.findMousedDModule();
			renderBuddy.visible = mousedDModule != null;
			if (mousedDModule)
				mousedDModule.descriptionAt(U.mouseFlxLoc).update(renderBuddy.text as HighlightText);
			
			super.update();
		}
		
		override public function draw():void {
			if (!renderBuddy || !renderBuddy.visible) return;
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