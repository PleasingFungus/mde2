package Displays {
	import Components.Wire;
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
		
		private var lastModulesExt:Vector.<Boolean>;
		private var lastWiresExt:Vector.<Boolean>;
		
		private var sourceModule:Module;
		private var moduleDistances:Dictionary;
		private var clickedModules:Array;
		public function DDelay(Modules:Vector.<Module>, DisplayModules:Vector.<DModule>) {
			modules = Modules;
			displayModules = DisplayModules;
			makeExtLists();
			clickedModules = [];
			super();
		}
		
		protected function makeExtLists():void {
			lastModulesExt = new Vector.<Boolean>;
			for each (var module:Module in modules)
				lastModulesExt.push(module.deployed);
			
			lastWiresExt = new Vector.<Boolean>;
			for each (var wire:Wire in U.state.wires)
				lastWiresExt.push(wire.exists);
		}
		
		protected function findExtMatch():Boolean {
			if (modules.length != lastModulesExt.length ||
				U.state.wires.length != lastWiresExt.length)
				return false;
			
			for (var i:int = 0; i < modules.length; i++)
				if (modules[i].deployed != lastModulesExt[i])
					return false;
			
			for (i = 0; i < U.state.wires.length; i++)
				if (U.state.wires[i].exists != lastWiresExt[i])
					return false;
			
			return true;
		}
		
		override public function update():void {
			visible = U.state.VIEW_MODE_DELAY == U.state.viewMode;
			if (visible) {
				checkMouse();
				if (!findExtMatch()) {
					generate();
					makeExtLists();
				}
			}
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
			generate();
		}
		
		protected function generate():void {
			members = [];
			if (sourceModule) {
				for (var i:int = 0; i < clickedModules.length; i++)
					if (!clickedModules[i].module.deployed)
						clickedModules = i ? clickedModules.slice(i - 1) : []; //breaks implicitly!
				generateFromSource();
			} else
				generateGeneric();
		}
		
		protected function generateFromSource():void {
			var baseDelay:int = 0;
			if (clickedModules.length)
				baseDelay = clickedModules[clickedModules.length - 1].dist;
			
			var node:Object;
			var toCheck:Array = [{
				'module' : sourceModule,
				'dist' : sourceModule.delay + baseDelay,
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
			var node:Object;
			
			var font:FontTuple = U.zoom >= 0.5 ? U.MODULE_FONT_CLOSE : U.MODULE_FONT_FAR;
			
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
				var color:uint = 0xcc000040 | (red << 16) | (green << 8)
				add(new FlxSprite(displayModule.x, displayModule.y).makeGraphic(displayModule.width, displayModule.height, color));
				add(new FlxText(displayModule.x - U.GRID_DIM, displayModule.y + displayModule.height / 2 - 8, displayModule.width + U.GRID_DIM * 2, "" + node.dist).setFormat(font.id, font.size, 0x0, 'center'));
			}
		}
		
		protected function unsetSourceModule():void {
			sourceModule = null;
			generate();
		}
		
		protected function generateGeneric():void {
			var font:FontTuple = U.zoom >= 0.5 ? U.MODULE_FONT_CLOSE : U.MODULE_FONT_FAR;
			
			var maxDelay:int;
			for each (var module:Module in modules)
				if (module.deployed)
					maxDelay = Math.max(module.delay, maxDelay);
			
			for each (var displayModule:DModule in displayModules) {
				if (!displayModule.module.deployed)	
					continue;
				
				var distFraction:Number = displayModule.module.delay / maxDelay;
				var red:uint = 0xff * distFraction;
				var green:uint = 0xff - red;
				var color:uint = 0xcc000040 | (red << 16) | (green << 8)
				add(new FlxSprite(displayModule.x, displayModule.y).makeGraphic(displayModule.width, displayModule.height, color));
				add(new FlxText(displayModule.x - U.GRID_DIM, displayModule.y + displayModule.height / 2 - 8, displayModule.width + U.GRID_DIM * 2, "" + displayModule.module.delay).setFormat(font.id, font.size, 0x0, 'center'));
			}
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