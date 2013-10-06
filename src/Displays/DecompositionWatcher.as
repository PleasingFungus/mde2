package Displays {
	import Components.Bloc;
	import Components.Link;
	import Modules.Module;
	import Modules.CustomModule;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DecompositionWatcher extends FlxGroup {
		
		private var lastMoused:DModule;
		private var bg:FlxSprite;
		private var dModules:Vector.<DModule>;
		private var dLinks:Vector.<DLink>;
		public function DecompositionWatcher() {
			super();
		}
		
		override public function update():void {
			checkMoused();
			super.update();
		}
		
		private function checkMoused():void {
			var moused:DModule = U.state.findMousedDModule();
			
			if (moused == lastMoused)
				return;
			
			if (!moused) {
				cleanup();
				return
			}
			
			if (moused.module is CustomModule) {
				buildDisplayFor(moused.module as CustomModule);
				lastMoused = moused;
			}
			
		}
		
		private function buildDisplayFor(customModule:CustomModule):void {
			bg = new FlxSprite().makeGraphic(FlxG.width / U.zoom, FlxG.height / U.zoom, 0x80ffffff);
			bg.scrollFactor = new FlxPoint;
			U.state.midLayer.add(bg);
			
			var bloc:Bloc = customModule.toBloc();
			bloc.moveTo(customModule); //should center around
			
			dModules = new Vector.<DModule>;
			for each (var module:Module in bloc.modules) {
				dModules.push(U.state.midLayer.add(module.generateDisplay()));
				module.solid = false;
			}
			dLinks = new Vector.<DLink>;
			for each (var link:Link in bloc.links)
				dLinks.push(U.state.midLayer.add(new DLink(link)));
		}
		
		private function cleanup():void {
			for each (var dModule:DModule in DModule)
				dModule.module.solid = true; //cleanup
			
			U.state.midLayer.members.splice(U.state.midLayer.members.indexOf(bg), 1 + dModules.length + dLinks.length); //can't possibly go wrong
			bg = null;
			dModules = null;
			dLinks = null;
			lastMoused = null;
			members = [];
		}
		
		override public function draw():void {
			super.draw();
			if (dModules)
				drawNodeText();
		}
		
		private function drawNodeText():void {
			for each (var dModule:DModule in dModules)
				dModule.drawNodeText();
		}
	}

}