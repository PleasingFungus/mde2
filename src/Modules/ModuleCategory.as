package Modules {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ModuleCategory {
		
		public var name:String;
		public var color:uint;
		public function ModuleCategory(Name:String, Color:uint = int.MAX_VALUE) {
			name = Name;
			color = Color;
		}
		
		public static function init():void {
			for each (var category:ModuleCategory in [CONTROL, STORAGE, LOGIC, ARITH, MISC])
				ALL.push(category);
		}
		
		public static const ARITH:ModuleCategory = new ModuleCategory("Arithmetic", 0xfff1d659);
		public static const LOGIC:ModuleCategory = new ModuleCategory("Logic", 0xff514f9c);
		public static const STORAGE:ModuleCategory = new ModuleCategory("Storage", 0xff4f9c64);
		public static const CONTROL:ModuleCategory = new ModuleCategory("Control", 0xff9c4f91);
		public static const MISC:ModuleCategory = new ModuleCategory("Misc.", 0xff9c4f4f);
		public static const ALL:Vector.<ModuleCategory> = new Vector.<ModuleCategory>;
	}

}