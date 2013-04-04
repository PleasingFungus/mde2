package Displays {
	import flash.geom.Point;
	import LevelStates.Bloc;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SelectionBox extends FlxSprite {
		
		private var clickPoint:Point;
		private var displayWires:Vector.<DWire>;
		private var displayModules:Vector.<DModule>;
		public function SelectionBox(DisplayWires:Vector.<DWire>, DisplayModules:Vector.<DModule>) {
			clickPoint = U.mouseLoc;
			displayWires = DisplayWires;
			displayModules = DisplayModules;
			super(clickPoint.x, clickPoint.y);
			
			makeGraphic(1, 1, 0xffffffff);
			color = U.SELECTION_COLOR;
			alpha = 0.6;
		}
		
		override public function update():void {
			if (FlxG.mouse.pressed())
				updateArea();
			else {
				createSelection();
				exists = false;
			}
			super.update();
		}
		
		private function updateArea():void {
			var mouseLoc:Point = U.mouseLoc;
			scale.x = Math.abs(mouseLoc.x - clickPoint.x);
			scale.y = Math.abs(mouseLoc.y - clickPoint.y);
			x = Math.min(mouseLoc.x, clickPoint.x) + scale.x / 2;
			y = Math.min(mouseLoc.y, clickPoint.y) + scale.y / 2;
		}
		
		private function createSelection():void {
			var area:FlxBasic = new FlxObject(x - scale.x / 2, y - scale.y / 2, scale.x, scale.y);
			
			var wires:Vector.<DWire> = new Vector.<DWire>;
			for each (var wire:DWire in displayWires)
				if (wire.wire.exists && wire.wire.deployed && wire.wire.path.length > 1 && !wire.wire.FIXED && wire.overlaps(area))
					wires.push(wire);
			
			var modules:Vector.<DModule> = new Vector.<DModule>;
			for each (var module:DModule in displayModules)
				if (module.module.exists && !module.module.FIXED && module.overlaps(area))
					modules.push(module);
			
			U.state.midLayer.add(DBloc.fromDisplays(wires, modules));
		}
	}

}