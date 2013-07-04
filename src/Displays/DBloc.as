package Displays {
	import Actions.Action;
	import Actions.BlocLiftAction;
	import Actions.CustomAction;
	import Actions.MoveBlocAction;
	import Components.Connection;
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
		
		private var tick:int;
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
			
			tick++;
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
					bloc.lift();
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
			else if (tick) {
				if (!U.buttonManager.moused && bloc.validPosition(U.pointToGrid(U.mouseLoc))) {
					FlxG.camera.shake(0.01 * U.zoom, 0.05);
					new MoveBlocAction(bloc, U.pointToGrid(U.mouseLoc)).specialExecute();
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
					else if (bloc.modules.length == 1 && bloc.wires.length == 0 &&
							 lastAction is CustomAction && (lastAction as CustomAction).exec == Module.remove && (lastAction as CustomAction).param == bloc.modules[0])
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
		
		override public function draw():void {
			super.draw();
			checkAssociatedWires();
			if (DEBUG.RENDER_BLOC_CONNECTIONS)
				debugRenderBlocConnections();
		}
		
		private function checkAssociatedWires():void {
			if (!bloc.newAssociatedWires)
				return;
			for each (var wire:Wire in bloc.newAssociatedWires)
				U.state.addDisplayWireFor(wire);
			bloc.newAssociatedWires = null;
		}
		
		private var connectionSprite:FlxSprite;
		private function debugRenderBlocConnections():void {
			if (!connectionSprite)
				connectionSprite = new FlxSprite().makeGraphic(4, 4);
			
			connectionSprite.color = 0xb0ff00ff;
			for each (var connection:Connection in bloc.connections) {
				connectionSprite.x = connection.meeting.x * U.GRID_DIM;
				connectionSprite.y = connection.meeting.y * U.GRID_DIM;
				connectionSprite.draw();
				
			}
			
			connectionSprite.color = 0xb0ffff00;
			for each (connection in bloc.connections) {
				if (connection.origin.equals(connection.meeting))
					continue;
				
				connectionSprite.x = connection.origin.x * U.GRID_DIM;
				connectionSprite.y = connection.origin.y * U.GRID_DIM;
				connectionSprite.draw();
			}
		}
		
		private function makeBlocConnections():void {
			for each (var connection:Connection in bloc.connections)
				connection
		}
		
	}

}