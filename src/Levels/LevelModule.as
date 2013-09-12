package Levels {
	import Components.Port;
	import flash.geom.Point;
	import Layouts.InternalLayout;
	import Layouts.Nodes.StandardNode;
	import Layouts.Nodes.WideNode;
	import Modules.Module;
	import Modules.ModuleCategory;
	import Layouts.DefaultLayout;
	import Layouts.ModuleLayout;
	import Values.IntegerValue;
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
			
			var successors:int = 0
			for each (var successor:Level in level.successors)
				if (shouldDisplay(successor))
					successors += 1;
			
			super(X, Y, level.unlocked() ? level.displayName : "???", ModuleCategory.MISC, level.predecessors.length, successors, 0);
			
			deployed = true;
			beaten = level.beaten;
			unlocked = level.unlocked();
			exists = shouldDisplay(level);
		}
		
		public function shouldDisplay(level:Level):Boolean {
			return !level.isBonus || level.unlocked()
		}
		
		override protected function generateLayout():ModuleLayout {
			return new DefaultLayout(this, 2, 5);
		}
		
		override protected function generateInternalLayout():InternalLayout {
			var nodes:Array = [];
			if (level.fewestModules && level.useModuleRecord) {
				var moduleValue:IntegerValue = new IntegerValue(level.fewestModules);
				nodes.push(new WideNode(this, new Point(0, -1), [], null, function getValue():Value {
					return moduleValue;
				}));
			}
			if (level.fewestTicks && level.useTickRecord) {
				var tickValue:IntegerValue = new IntegerValue(level.fewestTicks);
				nodes.push(new WideNode(this, new Point(0, 1), [], null, function getValue():Value {
					return tickValue;
				}));
			}
			return new InternalLayout(nodes);
		}
		
		override public function generateDisplay():DModule {
			return new DLevelModule(this);
		}
		
		override public function drive(port:Port):Value {
			return beaten ? BEATEN_VALUE : UNBEATEN_VALUE;
		}
		
		private const BEATEN_VALUE:Value = new IntegerValue(1);
		private const UNBEATEN_VALUE:Value = new IntegerValue(0);
	}

}