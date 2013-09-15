package UI {
	import Displays.BoxedSliderbar;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import Modules.Configuration;
	import Modules.Module;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ModuleSlider extends BoxedSliderbar {
		
		private var module:Module;
		private var config:Configuration;
		public var configValue:int;
		
		public function ModuleSlider(X:int, Y:int, MaxHeight:int, module:Module) {
			this.module = module;
			maxHeight = MaxHeight;
			super(X, Y);
			init();
		}
		
		override public function init():void {
			config = module.getConfiguration();
			configValue = config.value;
			valueRange = config.valueRange;
			onChange = config.setValue;
			initialValue = configValue;
			
			super.init();
		}
	}

}