package Displays {
	import Layouts.PortLayout;
	import Modules.Module;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DDelay extends FlxGroup {
		
		public var modules:Vector.<Module>;
		public var displayModules:Vector.<DModule>;
		
		private var sourceModule:Module;
		public function DDelay(Modules:Vector.<Module>, DisplayModules:Vector.<DModule>) {
			modules = Modules;
			displayModules = DisplayModules;
			super();
		}
		
		override public function update():void {
			checkMouse();
			super.update();
		}
		
		protected function checkMouse():void {
			var moused:Boolean;
			for each (var displayModule:DModule in displayModules)
				if (displayModule.module.exists && displayModule.overlapsPoint(U.mouseFlxLoc)) {
					if (displayModule.module != sourceModule)
						setSourceModule(displayModule.module);
					moused = true;
					break;
				}
			
			if (!moused)
				unsetSourceModule();
		}
		
		protected function setSourceModule(SourceModule:Module):void {
			sourceModule = SourceModule;
			
			var node:Object;
			var toCheck:Array = [{
				'module' : SourceModule,
				'dist' : SourceModule.delay,
				'parent' : null
			}];
			var checked:Array = [];
			
			while (toCheck.length) {
				var checking:Object = toCheck.pop();
				checked.push(checking);
				
				for each (var module:Module in modules) {
					var alreadyChecked:Boolean = false;
					for each (node in toCheck) if (node.module == module) { alreadyChecked = true; break; }
					for each (node in checked) if (node.module == module) { alreadyChecked = true; break; }
					if (alreadyChecked)
						continue;
					
					var connected:Boolean = false;
					for each (var portLayout:PortLayout in module.layout.ports) {
						if (!portLayout.port.source || portLayout.port.source.parent != checking.module)
							continue;
						
						connected = true;
						break;
					}
					
					if (!connected)
						continue;
					
					
					var dist:int = checking.dist + module.delay;
					for (var i:int = toCheck.length - 1; i >= 0; i--)
						if (toCheck[i].dist >= dist)
							break;
					toCheck.splice(i + 1, 0, {
						'module' : module,
						'dist' : dist,
						'parent' : checking
					});
				}
				
			}
			
			var maxDelay:int = int.MIN_VALUE;
			for each (node in checked)
				maxDelay = Math.max(node.dist, maxDelay);
			
			members = []
			for each (node in checked) {
				for each (var displayModule:DModule in displayModules)
					if (displayModule.module == node.module)
						break;
				
				var distFraction:Number = node.dist / maxDelay;
				var red:uint = 0xff * distFraction;
				var green:uint = 0xff - red;
				var color:uint = 0xff000040 | (red << 16) | (green << 8)
				add(new FlxSprite(displayModule.x, displayModule.y).makeGraphic(displayModule.width, displayModule.height, color));
				add(new FlxText(displayModule.x - U.GRID_DIM, displayModule.y + displayModule.height / 2 - 8, displayModule.width + U.GRID_DIM * 2, "" + node.dist).setFormat(U.FONT, U.FONT_SIZE, 0x0, 'center'));
			}
		}
		
		protected function unsetSourceModule():void {
			sourceModule = null;
			members = []
		}
		
	}

}