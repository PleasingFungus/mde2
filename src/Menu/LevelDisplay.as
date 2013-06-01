package Menu {
	import Components.Wire;
	import Displays.DWire;
	import flash.geom.Point;
	import Layouts.PortLayout;
	import Levels.ControlTutorials.*;
	import Levels.Level;
	import Levels.LevelModule;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class LevelDisplay extends FlxGroup {
		
		public var levelModules:Vector.<LevelModule>;
		public function LevelDisplay() {
			super();
			init();
		}
		
		protected function init():void {
			levelModules = new Vector.<LevelModule>;
			var wire:LevelModule = addLevel(WireTutorial.NAME, 0, FlxG.height / U.GRID_DIM / 2);
			wire.x += wire.layout.dim.x;
			var module:LevelModule = addSuccessor(ModuleTutorial.NAME, wire);
			var drag:LevelModule = addSuccessor(DragSelectTutorial.NAME, module, module.layout.dim.y + MODULE_SPACING.y);
			addSuccessor(CopyingTutorial.NAME, drag);
		}
		
		protected function addSuccessor(levelName:String, predecessor:LevelModule, offY:int = 0):LevelModule {
			return addLevel(levelName, predecessor.x + predecessor.layout.dim.x + MODULE_SPACING.x, predecessor.y + offY);
		}
		
		protected function addLevel(levelName:String, X:int, Y:int):LevelModule {
			var level:Level = Level.byName(levelName);
			var levelModule:LevelModule = new LevelModule(X, Y, level);
			levelModules.push(levelModule);
			add(levelModule.generateDisplay());
			
			
			for each (var predecessor:Level in level.predecessors) {
				var predecessorModule:LevelModule = levelModules[predecessor.index];
				
				var outputPort:PortLayout = predecessorModule.layout.ports[predecessor.successors.indexOf(level) + predecessorModule.inputs.length]; //FIXME
				var inputPort:PortLayout = levelModule.layout.ports[level.predecessors.indexOf(predecessor)];
				
				outputPort.port.connections.push(inputPort.port);
				inputPort.port.connections.push(outputPort.port);
				inputPort.port.source = outputPort.port;
				
				var wire:Wire = Wire.wireBetween(inputPort.Loc, outputPort.Loc);
				wire.deployed = true;
				add(new DLevelWire(wire, level.beaten));
				
				
			}
			
			return levelModule;
		}
		
		protected const MODULE_SPACING:Point = new Point(3, 2);
	}

}