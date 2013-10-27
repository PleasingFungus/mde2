package Menu {
	import flash.geom.Point;
	import Layouts.Nodes.InternalNode;
	import Levels.LevelModule;
	import Modules.Module;
	import Values.Value;
	import Displays.DNode;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class StatNode extends InternalNode {
		
		public var statType:int;
		private var levelParent:LevelModule;
		public function StatNode(Parent:Module, Offset:Point, StatType:int) {
			super(Parent, DIM_WIDE, Offset, [], null, getStat);
			statType = StatType;
			levelParent = Parent as LevelModule;
		}
		
		override public function generateDisplay():DNode {
			return new DStatNode(this);
		}
		
		private function getStat():Value {
			switch (statType) {
				case MODULE: return levelParent.moduleRecord;
				case TIME: return levelParent.tickRecord;
				default: throw new Error("Invalid stat type!");
			}
		}
		
		public static const INVALID:int = 0;
		public static const MODULE:int = 1;
		public static const TIME:int = 2;
	}

}