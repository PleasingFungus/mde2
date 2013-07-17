package Displays {
	import flash.geom.Point;
	import Modules.Configuration;
	import Modules.Module;
	import org.flixel.FlxBasic;
	import org.flixel.FlxObject;
	import UI.Sliderbar;
	import Actions.CustomAction;
	import org.flixel.FlxG;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InPlaceSlider extends BoxedSliderbar {
		
		private var displayModule:DModule;
		public function InPlaceSlider(DisplayModule:DModule) {
			displayModule = DisplayModule;
			var module:Module = displayModule.module;
			
			var config:Configuration = module.getConfiguration();
			var oldValue:int = config.value;
			var setValue:Function = function setValue(v:int):void {
				module.getConfiguration().setValue(v);
				module.setByConfig();
				module.initialize();
			};
			
			super(displayModule.x + displayModule.width / 2, displayModule.y + displayModule.height,
				  config.valueRange, setValue, config.value);
			if (U.zoom >= 0.5)
				setLabeled(false);
			
			setDieOnClickOutside(true, function onDie():void {
				var newValue:int = module.getConfiguration().value;
				if (newValue != oldValue)
					new CustomAction(function setByConfig(newValue:int, oldValue:int):Boolean {
						module.getConfiguration().value = newValue;
						module.setByConfig();
						module.initialize();
						return true;
					}, function setOldConfig(newValue:int, oldValue:int):Boolean {
						module.getConfiguration().value = oldValue;
						module.setByConfig();
						module.initialize();
						return true;
					}, newValue, oldValue).execute();
			});
		}
		
		override public function draw():void {
			var z:Number = U.zoom;
			sliderbar.x = (displayModule.x + displayModule.width / 2 - FlxG.camera.scroll.x) * z - sliderbar.width / 2;
			sliderbar.y = (displayModule.y + displayModule.height - FlxG.camera.scroll.y) * z - sliderbar.height;
			sliderbar.positionElements();
			bg.x = sliderbar.x - (BORDER_WIDTH + INNER_PAD);
			bg.y = sliderbar.y - (BORDER_WIDTH + INNER_PAD);
			
			super.draw();
		}
		
	}

}