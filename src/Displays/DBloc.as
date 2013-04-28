package Displays {
	import Actions.Action;
	import Actions.BlocLiftAction;
	import Actions.CustomAction;
	import Actions.MoveBlocAction;
	import Components.Wire;
	import Components.Bloc;
	import Controls.ControlSet;
	import flash.geom.Point;
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
					new BlocLiftAction(bloc, U.pointToGrid(U.mouseLoc)).execute();
					bloc.mobilize();
					bloc.exists = true;
				} else
					setSelect(false);
			}
			
			if (ControlSet.CANCEL_KEY.justPressed())
				setSelect(false);
			
			if (ControlSet.DELETE_KEY.justPressed()) {
				new CustomAction(bloc.remove, bloc.place, U.pointToGrid(U.mouseLoc)).execute();
				setSelect(false);
				U.buttonManager.moused = true; //clunky - avoid other things being deleted
			}
			
			if (ControlSet.CUT_KEY.justPressed()) {
				U.clipboard = bloc.toString();
				new CustomAction(bloc.remove, bloc.place, U.pointToGrid(U.mouseLoc)).execute();
				setSelect(false);
			}
		}
		
		protected function checkUnrootedState():void {
			if (!FlxG.mouse.justPressed())
				bloc.moveTo(U.pointToGrid(U.mouseLoc));
			else {
				if (!U.buttonManager.moused && bloc.validPosition(U.pointToGrid(U.mouseLoc))) {
					FlxG.camera.shake(0.01 * U.zoom, 0.05);
					new MoveBlocAction(bloc, U.pointToGrid(U.mouseLoc));
					setSelect(true);
				} else if (U.buttonManager.moused) {
					bloc.destroy();
					setSelect(false);
				}
			}
			
			if (ControlSet.CUT_KEY.justPressed())
				U.clipboard = bloc.toString();
			
			if (ControlSet.DELETE_KEY.justPressed() ||
				ControlSet.PASTE_KEY.justPressed() || ControlSet.CUT_KEY.justPressed()) {
				bloc.destroy();
				setSelect(false);
			}
			
			if (ControlSet.CANCEL_KEY.justPressed()) {
				if (U.state.actionStack.length) {
					var lastAction:Action = U.state.actionStack.pop();
					if (lastAction is BlocLiftAction && (lastAction as BlocLiftAction).bloc == bloc)
						lastAction.revert();
					else {
						U.state.actionStack.push(lastAction);
						bloc.destroy();
					}
				} else
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
			bloc.exists = exists = selected;
		}
		
		public static function fromDisplays(DisplayWires:Vector.<DWire>, DisplayModules:Vector.<DModule>, Rooted:Boolean = true):DBloc {
			var dBloc:DBloc = new DBloc;
			dBloc.displayWires = DisplayWires;
			dBloc.displayModules = DisplayModules;
			
			var wires:Vector.<Wire> = new Vector.<Wire>;
			for each (var dwire:DWire in dBloc.displayWires) {
				dwire.selected = true;
				wires.push(dwire.wire);
			}
			var modules:Vector.<Module> = new Vector.<Module>;
			for each (var dmodule:DModule in dBloc.displayModules) {
				dmodule.selected = true;
				modules.push(dmodule.module);
			}
			
			dBloc.bloc = new Bloc(modules, wires, Rooted);
			return dBloc;
		}
		
		public static function fromString(string:String, Rooted:Boolean = false):DBloc {
			var bloc:Bloc = Bloc.fromString(string);
			if (!bloc)
				return null;
			
			var dBloc:DBloc = new DBloc;
			dBloc.bloc = bloc;
			
			dBloc.displayWires = new Vector.<DWire>;
			for each (var wire:Wire in bloc.wires)
				dBloc.displayWires.push(U.state.midLayer.add(new DWire(wire)));
			
			dBloc.displayModules = new Vector.<DModule>;
			for each (var module:Module in bloc.modules)
				dBloc.displayModules.push(U.state.midLayer.add(module.generateDisplay()));
			
			return dBloc;
		}
		
		public function extendDisplays(displayWires:Vector.<DWire>, displayModules:Vector.<DModule>):void {
			for each (var dWire:DWire in this.displayWires)
				displayWires.push(dWire);
			for each (var dModule:DModule in this.displayModules)
				displayModules.push(dModule);
		}
		
	}

}