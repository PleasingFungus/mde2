package UI {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import Modules.Configuration;
	import Modules.Module;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ModuleSlider extends FlxGroup {
		
		private var x:int;
		public var parent:MenuButton;
		private var module:Module;
		private var config:Configuration;
		
		private var bg:FlxSprite;
		private var sliderbar:Sliderbar;
		public var configValue:int;
		public function ModuleSlider(X:int, Parent:MenuButton, module:Module) {
			x = X;
			parent = Parent;
			this.module = module;
			super();
			init();
		}
		
		private function init():void {
			config = module.getConfiguration();
			configValue = config.value;
			
			members = [];
			
			sliderbar = new Sliderbar(x + INNER_PAD + BORDER_WIDTH, parent.Y, config.valueRange, config.setValue, configValue);
			sliderbar.y += (parent.fullHeight + 15) / 2 - sliderbar.height / 2;
			sliderbar.create();
			
			add(bg = new FlxSprite(x, parent.Y).makeGraphic(sliderbar.width + (INNER_PAD + BORDER_WIDTH) * 2, parent.fullHeight, 0xff666666));
			add(sliderbar);
			
			bg.framePixels.fillRect(new Rectangle(BORDER_WIDTH/2, BORDER_WIDTH/2, bg.width - BORDER_WIDTH, bg.height - BORDER_WIDTH), 0xff999999);
			bg.framePixels.fillRect(new Rectangle(BORDER_WIDTH, BORDER_WIDTH, bg.width - BORDER_WIDTH*2, bg.height - BORDER_WIDTH*2), 0xff666666);
			bg.scrollFactor.x = bg.scrollFactor.y = 0;
		}
		
		public function overlapsPoint(p:FlxPoint):Boolean {
			return bg.overlapsPoint(p, true, FlxG.camera);
		}
		
		override public function update():void {
			super.update();
			if (!U.buttonManager.moused && overlapsPoint(FlxG.mouse)) 
				U.buttonManager.moused = true;
		}
		
		private const BORDER_WIDTH:int = 4;
		private const INNER_PAD:int = 4;
	}

}