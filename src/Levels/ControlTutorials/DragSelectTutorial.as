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
			super("Drag-Select Tutorial", new WireTutorialGoal());
			
			info = "Select modules, and wires, by holding " + ControlSet.DRAG_MODIFY_KEY + " and dragging; once held, pick up & place them by clicking."
			
			canDrawWires = false;
		}
		
		override public function loadIntoState(levelState:LevelState, loadFresh:Boolean = false):void {
			super.loadIntoState(levelState); //noop
			if (!loadFresh)
				return;
			
			var modules:Vector.<Module> = new Vector.<Module>;
			for each (var module:Module in [new ConstIn(10, 0, 1), new Adder(16, 2), new DataWriter(22, 14)])
				modules.push(module);
			
			var wires:Vector.<Wire> = new Vector.<Wire>;
			for each (var wire:Wire in [Wire.wireBetween(modules[0].layout.ports[0].Loc, modules[1].layout.ports[0].Loc),  //const to adder input 1
									    Wire.wireBetween(modules[1].layout.ports[0].Loc, modules[1].layout.ports[1].Loc),  //adder input 1 to adder input 2
									    Wire.wireBetween(modules[1].layout.ports[2].Loc, modules[2].layout.ports[0].Loc),  //adder to dwrite value
									    Wire.wireBetween(modules[2].layout.ports[1].Loc, modules[1].layout.ports[1].Loc)]) //adder input 2 to dwrite line
				wires.push(wire);
			
			modules[0].x -= 4;
			modules[0].y -= 6;
			modules[2].x += 6;
			modules[2].y -= 2;
			
			wires[0].shift(new Point( -4, -6));
			wires[2].shift(new Point(6, -2));
			
			for each (wire in wires)
				levelState.addWire(wire, false);
			for each (module in modules)
				levelState.addModule(module, false);
		}
		
	}

}