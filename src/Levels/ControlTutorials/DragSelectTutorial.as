package Levels.ControlTutorials {
	import Levels.Level;
	import Testing.Goals.WireTutorialGoal;
	import Modules.*;
	import Components.Wire;
	import Components.Carrier;
	import Controls.ControlSet;
	import flash.geom.Point;
	import LevelStates.LevelState;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DragSelectTutorial extends Level {
		
		public function DragSelectTutorial() {
			super(NAME, new WireTutorialGoal());
			
			info = "Select modules, and wires, by clicking and dragging. Once selected, pick them up by clicking on them, and put them down by clicking again."
			
			canDrawWires = false;
			canPickupModules = false;
			canEditModules = false;
			useModuleRecord = false;
		}
		
		override public function loadIntoState(levelState:LevelState, loadFresh:Boolean = false):void {
			super.loadIntoState(levelState); //noop
			if (!loadFresh)
				return;
			
			var modules:Vector.<Module> = new Vector.<Module>;
			for each (var module:Module in [new ConstIn(12, 0, 1), new ConstIn(10, 8, 2), new DataWriter(18, 6)])
				modules.push(module);
			
			var wires:Vector.<Wire> = new Vector.<Wire>;
			wires.push(Wire.wireBetween(modules[0].layout.ports[0].Loc, modules[2].layout.ports[1].Loc));  //const1 to dwriter port
			
			modules[0].x -= 4;
			modules[0].y -= 6;
			modules[2].x += 6;
			modules[2].y -= 2;
			
			wires[0].shift(new Point( -4, -6));
			
			for each (var wire:Wire in wires)
				levelState.addWire(wire, false);
			for each (module in modules)
				levelState.addModule(module, false);
		}
		
		public static const NAME:String = "Drag-Select Tutorial";
	}

}