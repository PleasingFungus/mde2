package Displays {
	import Components.Bloc;
	import Components.Link;
	import Controls.ControlSet;
	import Layouts.PortLayout;
	import Modules.Module;
	import Modules.CustomModule;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DecompositionWatcher extends FlxGroup {
		
		public var decomposition:DDecomposedBloc;
		
		private var currentModule:CustomModule;
		private var currentDisplayModule:DModule;
		private var bg:ScreenFilter;
		private var dModules:Vector.<DModule>;
		private var dLinks:Vector.<DLink>;
		public function DecompositionWatcher() {
			super();
		}
		
		override public function update():void {
			if (decomposition)
				checkDecomposition();
			else
				checkModule();
			
			super.update();
		}
		
		private function checkDecomposition():void {
			if (!decomposition.exists) {
				decomposition = null;
				if (currentModule.modules[0]) {
					//TODO
					unbind();
				} else {
					cleanup();
				}
			}
		}
		
		private function checkModule():void {
			if (currentModule)
				checkMoused();
			
			if (currentModule)
				checkKeys();
			else
				findMoused();
			
		}
		
		private function checkMoused():void {
			if (!currentDisplayModule.overlapsPoint(U.mouseFlxLoc) || currentDisplayModule.selected)
				cleanup();
		}
		
		private function findMoused():void {
			if (FlxG.mouse.pressed() || FlxG.mouse.justReleased())
				return;
				//don't visual-decompose if you're in selection mode
			
			var moused:DModule = U.state.findMousedDModule();
			
			if (moused && !moused.selected && moused.module is CustomModule) //don't visual-decompose if it's selected
				buildDisplayFor(moused, moused.module as CustomModule);
			
		}
		
		private function buildDisplayFor(displayModule:DModule, customModule:CustomModule):void {
			U.state.midLayer.add(bg = new ScreenFilter(0x80ffffff));
			
			var bloc:Bloc = customModule.toBloc();
			bloc.moveTo(customModule); //should center around
			
			customModule.lift();
			customModule.exists = false;
			
			dModules = new Vector.<DModule>;
			for each (var module:Module in bloc.modules) {
				for each (var port:PortLayout in module.layout.ports)
					port.port.physParent = module;
				module.setLayout();
				
				dModules.push(U.state.displayModuleFor(module));
				
				module.solid = false;
				module.exists = true;
			}
			dLinks = new Vector.<DLink>;
			for each (var link:Link in bloc.links)
				dLinks.push(U.state.midLayer.add(new DLink(link)));
			
			currentModule = customModule;
			currentDisplayModule = displayModule;
		}
		
		private function checkKeys():void {
			if (ControlSet.CUSTOM_KEY.justPressed())
				decompose();
		}
		
		private function decompose():void {
			U.state.addDBloc(decomposition = DBloc.fromDisplays(dLinks, dModules, false, DDecomposedBloc) as DDecomposedBloc);
			decomposition.customModule = currentModule;
		}
		
		
		public function ensureSafety():void {
			if (currentModule)
				cleanup();
		}
		
		private function cleanup():void {
			for each (var dModule:DModule in dModules) {
				dModule.module.solid = true; //cleanup
				dModule.module.exists = false;
			}
			
			for each (var port:PortLayout in currentModule)
				port.port.physParent = currentModule;
			currentModule.setLayout();
			
			currentModule.place();
			currentModule.exists = true;
			
			U.state.midLayer.members.splice(U.state.midLayer.members.indexOf(bg), 1 + dLinks.length); //can't possibly go wrong
			bg = null;
			unbind(); 
		}
		
		private function unbind():void {
			if (bg) {
				U.state.midLayer.members.splice(U.state.midLayer.members.indexOf(bg), 1);
				bg = null;
			}
			dModules = null;
			dLinks = null;
			currentModule = null;
			currentDisplayModule = null;
			members = [];
		}
		
		override public function draw():void {
			super.draw();
			if (dModules)
				drawNodeText();
		}
		
		private function drawNodeText():void {
			for each (var dModule:DModule in dModules)
				if (U.zoom >= 0.5)
					dModule.drawNodeText();
		}
	}

}