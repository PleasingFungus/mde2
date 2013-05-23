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
		
		public var parent:MenuButton;
		private var module:Module;
		private var config:Configuration;
		public var configValue:int;
		
		public function ModuleSlider(X:int, Parent:MenuButton, module:Module) {
			parent = Parent;
			this.module = module;
			super(X, parent.Y);
			init();
		}
		
		override public function init():void {
			y = parent.Y;
			config = module.getConfiguration();
			configValue = config.value;
			valueRange = config.valueRange;
			onChange = config.setValue;
			initialValue = configValue;
			maxHeight = parent.fullHeight;
			
			super.init();
		}
	}

}