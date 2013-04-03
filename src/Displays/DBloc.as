package Displays {
	import Actions.CustomAction;
	import Components.Wire;
	import Controls.ControlSet;
	import flash.geom.Point;
	import LevelStates.Bloc;
	import Modules.Module;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DBloc extends FlxGroup {
		
		private var displayWires:Vector.<DWire>;
		private var displayModules:Vector.<DModule>;
		public var bloc:Bloc;
		public function DBloc(DisplayWires:Vector.<DWire>, DisplayModules:Vector.<DModule>, Rooted:Boolean = true) {
			displayWires = DisplayWires;
			displayModules = DisplayModules;
			
			super();
			
			var wires:Vector.<Wire> = new Vector.<Wire>;
			for each (var dwire:DWire in displayWires) {
				dwire.selected = true;
				wires.push(dwire.wire);
			}
			var modules:Vector.<Module> = new Vector.<Module>;
			for each (var dmodule:DModule in displayModules) {
				dmodule.selected = true;
				modules.push(dmodule.module);
			}
			
			bloc = new Bloc(modules, wires, Rooted);
		}
		
		override public function update():void {
			super.update();
			
			if (!bloc.exists)
				return;
			
			if (bloc.rooted)
				checkRootedState();
			else
				checkUnrootedState();
		}
		
		protected function checkRootedState():void {
			if (FlxG.mouse.justPressed()) {
				var mouseLoc:FlxPoint = U.mouseFlxLoc;
				var moused:Boolean = false;
				
				if (!U.buttonManager.moused) {
					for each (var dmodule:DModule in displayModules)
						if (dmodule.overlapsPoint(mouseLoc)) {
							moused = true;
							break;
						}
					if (!moused)
						for each (var dwire:DWire in displayWires)
							if (dwire.overlapsPoint(mouseLoc)) {
								moused = true;
								break;
							}
				}
				
				if (moused) {
					new CustomAction(bloc.remove, bloc.place, U.pointToGrid(U.mouseLoc)).execute();
					bloc.mobilize();
				} else
					setSelect(false);
			}
			
			if (ControlSet.CANCEL_KEY.justPressed())
				setSelect(false);
			
			if (ControlSet.DELETE_KEY.justPressed()) {
				new CustomAction(bloc.remove, bloc.place, U.pointToGrid(U.mouseLoc)).execute();
				setSelect(false);
			}
		}
		
		protected function checkUnrootedState():void {
			if (!FlxG.mouse.justPressed())
				bloc.moveTo(U.pointToGrid(U.mouseLoc));
			else {
				if (U.buttonManager.moused || bloc.validPosition(U.pointToGrid(U.mouseLoc)))
					new CustomAction(bloc.place, bloc.remove, U.pointToGrid(U.mouseLoc)).execute();
				else {
					bloc.destroy();
					setSelect(false);
				}
			}
			
			if (ControlSet.CANCEL_KEY.justPressed()) {
				bloc.destroy();
				setSelect(false);
			}
			
			U.buttonManager.moused = true;
		}
		
		private function setSelect(selected:Boolean = true):void {
			for each (var dmodule:DModule in displayModules)
				dmodule.selected = selected;
			for each (var dwire:DWire in displayWires)
				dwire.selected = selected;
			bloc.exists = selected;
		}
		
	}

}