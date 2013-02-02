package Displays {
	import org.flixel.FlxGroup;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ModulePage extends FlxGroup {
		
		public var modules:Vector.<DModule>
		public function ModulePage() {
			super();
			modules = new Vector.<DModule>;
		}
		
		public function addModule(displayModule:DModule):void {
			add(displayModule);
			modules.push(displayModule);
		}
	}

}