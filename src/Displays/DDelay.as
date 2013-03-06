package Displays {
	import flash.utils.Dictionary;
	import Layouts.PortLayout;
	import Modules.Module;
	import org.flixel.*;
	import UI.FontTuple;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DDelay extends FlxGroup {
		
		public var modules:Vector.<Module>;
		public var displayModules:Vector.<DModule>;
		public var interactive:Boolean;
		
		private var sourceModule:Module;
		private var moduleDistances:Dictionary;
		private var clickedModules:Array;
		public function DDelay(Modules:Vector.<Module>, DisplayModules:Vector.<DModule>) {
			modules = Modules;
			displayModules = DisplayModules;
			clickedModules = [];
			super();
		}
		
		override public function update():void {
			visible = U.state.VIEW_MODE_DELAY == U.state.viewMode;
			if (visible)
				checkMouse();
			super.update();
		}
		
		protected function checkMouse():void {
			var mousedModule:Module = U.state.findMousedModule();
			if (!mousedModule) {
				if (clicked && clickedModules.length)
					clickedModules = [];
				
				if (!clickedModules.length)
					unsetSourceModule();
				else if (lastClicked != sourceModule)
					setSourceModule(lastClicked);
			} else if (!lastDistances || lastDistances[moduleId(mousedModule)] != null) {
				if (mousedModule != sourceModule)
					setSourceModule(mousedModule);
				if (clicked && lastClicked != mousedModule)
					clickedModules.push( { 'module' : mousedModule, 'dist' : lastDistances ? lastDistances[moduleId(mousedModule)].dist : mousedModule.delay,
										   'moduleDistances' : moduleDistances})
			}
		}
		
		protected function setSourceModule(SourceModule:Module):void {
			sourceModule = SourceModule;
			
			var baseDelay:int = 0;
			if (clickedModules.length)
				baseDelay = clickedModules[clickedModules.length - 1].dist;
			
			var node:Object;
			var toCheck:Array = [{
				'module' : SourceModule,
				'dist' : SourceModule.delay + baseDelay,
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
			
			moduleDistances = new Dictionary;
			for each (node in checked)
				moduleDistances[moduleId(node.module)] = node;
			
			renderDistances(moduleDistances);
		}
		
		protected function renderDistances(moduleDistances:Dictionary):void {
			members = []
			var node:Object;
			
			var font:FontTuple = U.state.zoom >= 0.5 ? U.MODULE_FONT_CLOSE : U.MODULE_FONT_FAR;
			
			var maxDelay:int = int.MIN_VALUE;
			for each (node in moduleDistances)
				maxDelay = Math.max(node.dist, maxDelay);
			
			for each (node in moduleDistances) {
				for each (var displayModule:DModule in displayModules)
					if (displayModule.module == node.module)
						break;
				
				var distFraction:Number = node.dist / maxDelay;
				var red:uint = 0xff * distFraction;
				var green:uint = 0xff - red;
				var color:uint = 0xff000040 | (red << 16) | (green << 8)
				add(new FlxSprite(displayModule.x, displayModule.y).makeGraphic(displayModule.width, displayModule.height, color));
				add(new FlxText(displayModule.x - U.GRID_DIM, displayModule.y + displayModule.height / 2 - 8, displayModule.width + U.GRID_DIM * 2, "" + node.dist).setFormat(font.id, font.size, 0x0, 'center'));
			}
		}
		
		protected function unsetSourceModule():void {
			sourceModule = null;
			members = [];
		}
		
		protected function get lastClicked():Module {
			if (clickedModules.length)
				return clickedModules[clickedModules.length - 1].module;
			return null;
		}
		
		protected function get lastDistances():Dictionary {
			if (clickedModules.length)
				return clickedModules[clickedModules.length - 1].moduleDistances;
			return null;
		}
		
		protected function get clicked():Boolean {
			return interactive && !U.buttonManager.moused && FlxG.mouse.justPressed();
		}
		
		protected function moduleId(module:Module):int {
			return U.state.modules.indexOf(module);
		}
	}

}