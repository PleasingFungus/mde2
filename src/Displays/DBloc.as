package Displays {
	import Actions.Action;
	import Actions.CustomAction;
	import Actions.DelBlocAction;
	import Actions.MigrateBlocAction;
	import Actions.PlaceBlocAction;
	import Components.Connection;
	import Components.Wire;
	import Components.Bloc;
	import Controls.ControlSet;
	import flash.geom.Point;
	import Modules.Module;
	import org.flixel.*;
	import Components.Link;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DBloc extends FlxGroup {
		
		private var tick:int;
		private var displayLinks:Vector.<DLink>;
		private var displayModules:Vector.<DModule>;
		public var bloc:Bloc;
		public function DBloc() {
			super();
		}
		
		override public function update():void {
			super.update();
			
			if (!bloc.exists) {
				setSelect(false);
				return;
			}
			
			if (bloc.rooted)
				checkRootedState();
			else
				checkUnrootedState();
			
			if (ControlSet.COPY_KEY.justPressed())
				U.clipboard = bloc.toString();
			
			tick++;
		}
		
		protected function checkRootedState():void {
			if (FlxG.mouse.justPressed()) {
				var mouseLoc:FlxPoint = U.mouseFlxLoc;
				var moused:Boolean = false;
				
				if (!U.buttonManager.moused)
					for each (var dmodule:DModule in displayModules)
						if (dmodule.overlapsPoint(mouseLoc)) {
							moused = true;
							break;
						}
				
				if (moused) {
					bloc.lift(U.pointToGrid(U.mouseLoc));
				} else
					setSelect(false);
			}
			
			if (ControlSet.CANCEL_KEY.justPressed())
				setSelect(false);
			
			if (ControlSet.DELETE_KEY.justPressed()) {
				new DelBlocAction(bloc).execute();
				setSelect(false);
				U.buttonManager.moused = true; //clunky - avoid other things being deleted
				if (ControlSet.DELETE_KEY.justPressed())
					ControlSet.DELETE_KEY.enabled = false;
			}
			
			if (ControlSet.CUT_KEY.justPressed()) {
				U.clipboard = bloc.toString();
				new DelBlocAction(bloc).execute();
				setSelect(false);
			}
		}
		
		protected function checkUnrootedState():void {
			if (!FlxG.mouse.justPressed())
				bloc.moveTo(U.pointToGrid(U.mouseLoc));
			else if (tick) {
				if (!U.buttonManager.moused && bloc.validPosition(U.pointToGrid(U.mouseLoc))) {
					FlxG.camera.shake(0.01 * U.zoom, 0.05);
					
					var placeLoc:Point = U.pointToGrid(U.mouseLoc);
					if (bloc.lastRootedLoc)
						new MigrateBlocAction(bloc, placeLoc, bloc.lastRootedLoc).execute();
					else
						new PlaceBlocAction(bloc, placeLoc).execute();
					
					setSelect(false);
				} else if (U.buttonManager.moused) {
					new DelBlocAction(bloc).execute();
					setSelect(false);
				}
			}
			
			if (ControlSet.CUT_KEY.justPressed())
				U.clipboard = bloc.toString();
			
			if (ControlSet.DELETE_KEY.justPressed() ||
				ControlSet.PASTE_KEY.justPressed() || ControlSet.CUT_KEY.justPressed()) {
				new DelBlocAction(bloc).execute();
				setSelect(false);
				if (ControlSet.DELETE_KEY.justPressed())
					ControlSet.DELETE_KEY.enabled = false;
			}
			
			if (ControlSet.CANCEL_KEY.justPressed()) {
				if (bloc.lastRootedLoc) {
					bloc.place(bloc.lastRootedLoc);
					setSelect(false);
				} else
					bloc.unravel();
			}
			
			U.buttonManager.moused = true;
		}
		
		private function setSelect(selected:Boolean = true):void {
			for each (var dmodule:DModule in displayModules)
				dmodule.selected = selected;
			for each (var dlink:DLink in displayLinks)
				dlink.selected = selected;
			bloc.exists = exists = selected;
		}
		
		public static function fromDisplays(DisplayLinks:Vector.<DLink>, DisplayModules:Vector.<DModule>, Rooted:Boolean = true):DBloc {
			var dBloc:DBloc = new DBloc;
			dBloc.displayLinks = DisplayLinks;
			dBloc.displayModules = DisplayModules;
			
			var links:Vector.<Link> = new Vector.<Link>;
			for each (var dlink:DLink in dBloc.displayLinks) {
				dlink.selected = true;
				links.push(dlink.link);
			}
			var modules:Vector.<Module> = new Vector.<Module>;
			for each (var dmodule:DModule in dBloc.displayModules) {
				dmodule.selected = true;
				modules.push(dmodule.module);
			}
			
			dBloc.bloc = new Bloc(modules, links, Rooted);
			return dBloc;
		}
		
		public static function fromString(string:String, Rooted:Boolean = false):DBloc {
			var bloc:Bloc = Bloc.fromString(string);
			if (!bloc)
				return null;
			
			var dBloc:DBloc = new DBloc;
			dBloc.bloc = bloc;
			
			dBloc.displayLinks = new Vector.<DLink>;
			for each (var link:Link in bloc.links)
				dBloc.displayLinks.push(U.state.midLayer.add(new DLink(link)));
			
			dBloc.displayModules = new Vector.<DModule>;
			for each (var module:Module in bloc.modules)
				dBloc.displayModules.push(U.state.midLayer.add(module.generateDisplay()));
			
			return dBloc;
		}
		
		public function extendDisplays(displayLinks:Vector.<DLink>, displayModules:Vector.<DModule>):void {
			for each (var dLink:DLink in this.displayLinks)
				displayLinks.push(dLink);
			for each (var dModule:DModule in this.displayModules)
				displayModules.push(dModule);
		}
		
	}

}