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
			if (FlxG.mouse.justPressed()) {
				//clicked on a module?
				//clicked on a wire?
				//else...
				setSelect(false);
			}
			
			if (ControlSet.CANCEL_KEY.justPressed())
				setSelect(false);
			
			if (ControlSet.DELETE_KEY.justPressed()) {
				new CustomAction(bloc.remove, bloc.place, U.pointToGrid(U.mouseLoc)).execute();
				setSelect(false);
			}
		}
		
		private function setSelect(selected:Boolean = true):void {
			for each (var dmodule:DModule in displayModules)
				dmodule.selected = selected;
			for each (var dwire:DWire in displayWires)
				dwire.selected = selected;
			exists = selected;
		}
		
	}

}