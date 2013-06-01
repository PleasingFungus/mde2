package Menu {
	import Components.Wire;
	import Displays.DModule;
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
			
			var wire:LevelModule = addLevel(Level.L_TutorialWire, 0, FlxG.height / U.GRID_DIM / 2);
			wire.x += wire.layout.dim.x;
			var module:LevelModule = addSuccessor(Level.L_TutorialModule, wire);
			var drag:LevelModule = addSuccessor(Level.L_TutorialSelection, module, module.layout.dim.y + MODULE_SPACING.y);
			addSuccessor(Level.L_TutorialCopying, drag);
			
			var accum:LevelModule = addSuccessor(Level.L_Accumulation, module);
			var singleOp:LevelModule = addSuccessor(Level.L_SingleOp, accum);
			var doubleOp:LevelModule = addSuccessor(Level.L_DoubleOp, singleOp);
			
			var cpuBasic:LevelModule = addSuccessor(Level.L_CPU_Basic, doubleOp);
			var cpuAdvanced:LevelModule = addSuccessor(Level.L_CPU_Advanced, cpuBasic, -(MODULE_SPACING.y));
			cpuAdvanced.y -= cpuAdvanced.layout.dim.y;
			var cpuJump:LevelModule = addSuccessor(Level.L_CPU_Jump, cpuBasic);
			var cpuBranch:LevelModule = addSuccessor(Level.L_CPU_Branch, cpuJump);
			var cpuLoad:LevelModule = addSuccessor(Level.L_CPU_Load, cpuBasic, cpuBranch.layout.dim.y + MODULE_SPACING.y);
			var cpuFull:LevelModule = addSuccessor(Level.L_CPU_Full, cpuBranch);
		}
		
		protected function addSuccessor(level:Level, predecessor:LevelModule, offY:int = 0):LevelModule {
			return addLevel(level, predecessor.x + predecessor.layout.dim.x + MODULE_SPACING.x, predecessor.y + offY);
		}
		
		protected function addLevel(level:Level, X:int, Y:int):LevelModule {
			var levelModule:LevelModule = new LevelModule(X, Y, level);
			levelModules.push(levelModule);
			var displayModule:DModule = levelModule.generateDisplay();
			add(displayModule);
			
			for each (var predecessor:Level in level.predecessors) {
				var predecessorModule:LevelModule = levelModules[predecessor.index];
				
				var outputPort:PortLayout = predecessorModule.layout.ports[predecessor.successors.indexOf(level) + predecessorModule.inputs.length]; //FIXME
				var inputPort:PortLayout = levelModule.layout.ports[level.predecessors.indexOf(predecessor)];
				
				outputPort.port.connections.push(inputPort.port);
				inputPort.port.connections.push(outputPort.port);
				inputPort.port.source = outputPort.port;
				
				var wire:Wire = Wire.wireBetween(inputPort.Loc, outputPort.Loc);
				wire.deployed = true;
				add(new DLevelWire(wire, predecessor.beaten));
				
				
			}
			
			if (level == Level.last) {
				FlxG.camera.scroll.x = displayModule.x + displayModule.width / 2 - FlxG.width / 2;
				FlxG.camera.scroll.y = displayModule.y + displayModule.height / 2 - FlxG.height / 2;
			}
			
			return levelModule;
		}
		
		protected const MODULE_SPACING:Point = new Point(3, 2);
	}

}