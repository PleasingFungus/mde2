package Levels {
	import Components.Port;
	import Modules.Module;
	import Modules.ModuleCategory;
	import Layouts.DefaultLayout;
	import Layouts.ModuleLayout;
	import Values.NumericValue;
	import Values.Value;
	import Menu.DLevelModule;
	import Displays.DModule;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class LevelModule extends Module {
		
		public var level:Level;
		public var beaten:Boolean;
		public var unlocked:Boolean;
		public function LevelModule(X:int, Y:int, level:Level) {
			this.level = level;
			super(X, Y, level.unlocked() ? level.displayName : "???", ModuleCategory.MISC, level.predecessors.length, level.successors.length, 0);
			deployed = true;
			beaten = level.beaten;
			unlocked = level.unlocked();
		}
		
		override protected function generateLayout():ModuleLayout {
			return new DefaultLayout(this, 2, 5);
		}
		
		override public function generateDisplay():DModule {
			return new DLevelModule(this);
		}
		
		override public function drive(port:Port):Value {
			return beaten ? BEATEN_VALUE : UNBEATEN_VALUE;
		}
		
		private const BEATEN_VALUE:Value = new NumericValue(1);
		private const UNBEATEN_VALUE:Value = new NumericValue(0);
	}

}