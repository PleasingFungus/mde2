package Modules {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SeenModules {
		
		private var seenList:Vector.<Boolean>;
		public function SeenModules() {
			init();
		}
		
		protected function init():void {
			seenList = new Vector.<Boolean>;
			for each (var moduleType:Class in Module.ALL_MODULES)
				seenList.push(false);
		}
		
		public function load():void {
			init();
			
			var seenString:String = U.save.data[SAVE_NAME];
			if (!seenString)
				return;
			
			var seenStringArray:Array = seenString.split(SEEN_DELIM);
			for (var i:int = 0; i < Math.min(seenStringArray.length, seenList.length); i++)
				seenList[i] = seenStringArray[i] != false+'';
		}
		
		public function moduleSeen(moduleType:Class):Boolean {
			var index:int = Module.ALL_MODULES.indexOf(moduleType);
			if (index == -1)
				throw new Error("Unknown module type!");
			
			return seenList[index];
		}
		
		public function unknownInList(moduleTypes:Vector.<Class>):Boolean {
			for each (var moduleType:Class in moduleTypes)
				if (!moduleSeen(moduleType))
					return true;
			return false;
		}
		
		public function unknownInListInCategory(moduleTypes:Vector.<Class>, Category:ModuleCategory):Boolean {
			for each (var moduleType:Class in moduleTypes) {
				if (moduleSeen(moduleType))
					continue;
				
				var archetype:Module = Module.getArchetype(moduleType);
				if (archetype.category == Category)
					return true; //unknown and in category
			}
			return false;
		}
		
		public function setSeen(moduleTypes:Vector.<Class>):void {
			var dirty:Boolean = false;
			for each (var moduleType:Class in moduleTypes) {
				var index:int = Module.ALL_MODULES.indexOf(moduleType);
				if (index == -1)
					throw new Error("Unknown module type!");
				
				if (!seenList[index])
					dirty = true;
				seenList[index] = true;
			}
			
			if (dirty)
				save();
		}
		
		private function save():void {
			var saveString:String = seenList.join(SEEN_DELIM);
			U.save.data[SAVE_NAME] = saveString;
		}
		
		private const SEEN_DELIM:String = ',';
		private const SAVE_NAME:String = 'modulesSeen';
		
		public static const SEEN:SeenModules = new SeenModules;
	}

}