package Displays {
	import Controls.ControlSet;
	import Modules.Module;
	import org.flixel.*;
	import UI.Sliderbar;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ModuleBox extends FlxGroup {
		
		private var availableParts:Array;
		private var parts:Vector.<DModule>;
		private var pages:Vector.<ModulePage>;
		private var page:ModulePage;
		private var bg:FlxSprite;
		private var select:Function;
		public function ModuleBox(AvailableParts:Array, Select:Function) {
			super();
			
			availableParts = AvailableParts;
			select = Select;
			
			makeBG();
			makeModules();
		}
		
		protected function makeBG():void {
			var width:int = FlxG.width * WIDTH_FACTOR;
			var height:int = FlxG.height * HEIGHT_FACTOR;
			bg = new FlxSprite((FlxG.width - width) / 2, (FlxG.height - height) / 2).makeGraphic(width, height, 0xff202020);
			var raisedBorderWidth:int = 2;
			
			var light:FlxSprite = new FlxSprite().makeGraphic(width - raisedBorderWidth * 2, height - raisedBorderWidth * 2, 0xff666666)
			bg.stamp(light, raisedBorderWidth, raisedBorderWidth);
			
			var innerDark:FlxSprite = new FlxSprite().makeGraphic(width - raisedBorderWidth * 4, height - raisedBorderWidth * 4, 0xff202020)
			bg.stamp(innerDark, raisedBorderWidth * 2, raisedBorderWidth * 2);
			
			//bg.alpha = 0.67;
			add(bg);
		}
		
		
		protected function makeModules():void {
			parts = new Vector.<DModule>;
			pages = new Vector.<ModulePage>;
			pages.push(add(page = new ModulePage));
			
			var rows:int = 1;
			var cols:int = 4;
			var row:int, col:int;
			for each (var part:Class in availableParts) {
				if (col >= cols) {
					col = 0;
					//row ++;
					pages.push(add(page = new ModulePage));
					page.exists = false;
				}
				
				var displayModule:DModule = new DModule(new part(bg.x + (col + 0.5) * (WIDTH_FACTOR * FlxG.width / cols),
																 bg.y + (row + 0.5) * (HEIGHT_FACTOR * FlxG.height / rows)));
				displayModule.module.initialize();
				page.addModule(displayModule);
				parts.push(displayModule);
				
				if (displayModule.module.configuration) {
					var sliderbarSpace:int = 15;
					
					var sliderBar:Sliderbar = new Sliderbar(displayModule.x + displayModule.width / 2, displayModule.y + displayModule.height / 2,
															displayModule.module.configuration.valueRange, displayModule.module.configuration.setValue);
					sliderBar.x -= sliderBar.width / 2;
					
					displayModule.y -= (sliderBar.height + sliderbarSpace) / 2;
					sliderBar.y += (sliderBar.height + sliderbarSpace) / 2;
					
					sliderBar.create();
					page.add(sliderBar);
				}
				
				col++;
			}
			
			if (pages.length > 1) {
				var pageControl:Sliderbar = new Sliderbar(bg.x + bg.width / 2, bg.y + 2, new Range(1, pages.length), function switchPage(newPage:int):void {
					for (var i:int = 0; i < pages.length; i++)
						pages[i].exists = i == newPage - 1;
					page = pages[newPage - 1];
				});
				pageControl.x -= pageControl.width / 2;
				pageControl.create();
				pageControl.forceValue(1);
				add(pageControl);
				page = pages[0];
			}
		}
		
		private var tick:int;
		
		override public function update():void {
			super.update();
			checkClick();
			checkControls();
			tick++;
		}
		
		protected function checkClick():void {
			if (!tick || !FlxG.mouse.justPressed())
				return;
			
			var adjMouse:FlxPoint = new FlxPoint(FlxG.mouse.x + FlxG.camera.scroll.x * (bg.scrollFactor.x - 1), 
												 FlxG.mouse.y + FlxG.camera.scroll.y * (bg.scrollFactor.y - 1));
			
			if (!bg.overlapsPoint(adjMouse))
				exists = false;
			
			for each (var module:DModule in page.modules)
				if (module.overlapsPoint(adjMouse)) {
					select(module.module);
					exists = false;
					return;
				}
		}
		
		protected function checkControls():void {
			if (ControlSet.CANCEL_KEY.justPressed())
				exists = false;
		}
		
		private const WIDTH_FACTOR:Number = 3 / 4;
		private const HEIGHT_FACTOR:Number = 3 / 4;
	}

}