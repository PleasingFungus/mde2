package Menu {
	import Components.Wire;
	import Displays.DModule;
	import Displays.DWire;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
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
		private var modulesByName:Dictionary;
		private var min:Point;
		private var max:Point;
		public function LevelDisplay() {
			super();
			init();
		}
		
		protected function init():void {
			members = [];
			addModules();
			addWires();
		}
		
		protected function addModules():void {
			levelModules = new Vector.<LevelModule>;
			modulesByName = new Dictionary;
			min = new Point(int.MAX_VALUE, int.MAX_VALUE);
			max = new Point(int.MIN_VALUE, int.MIN_VALUE);
			
			var fib:LevelModule = addLevel(Level.L_TutorialTest, 0, FlxG.height / U.GRID_DIM / 2);
			fib.x += fib.layout.dim.x;
			var wire:LevelModule = addSuccessor(Level.L_TutorialWire, fib);
			var module:LevelModule = addSuccessor(Level.L_TutorialModule, wire);
			var drag:LevelModule = addSuccessor(Level.L_TutorialSelection, module, module.layout.dim.y + MODULE_SPACING.y * 2);
			addSuccessor(Level.L_TutorialCopying, drag, MODULE_SPACING.y);
			
			var accum:LevelModule = addSuccessor(Level.L_Accumulation, module);
			var double:LevelModule = addSuccessor(Level.L_Double, accum, (accum.layout.dim.y + MODULE_SPACING.y)/2);
			var singleOp:LevelModule = addSuccessor(Level.L_SingleOp, accum, -(double.layout.dim.y + MODULE_SPACING.y)/2);
			var doubleOp:LevelModule = addSuccessor(Level.L_DoubleOp, double, -(double.layout.dim.y + MODULE_SPACING.y) / 2);
			
			addSuccessor(Level.L_Square, double, (singleOp.layout.dim.y) + (double.layout.dim.y) / 2);
			addSuccessor(Level.L_Collatz, double, (doubleOp.layout.dim.y) / 2);
			
			var cpuBasic:LevelModule = addSuccessor(Level.L_CPU_Basic, doubleOp);
			var cpuJump:LevelModule = addSuccessor(Level.L_CPU_Jump, cpuBasic, -(doubleOp.layout.dim.y + MODULE_SPACING.y));
			var cpuBranch:LevelModule = addSuccessor(Level.L_CPU_Branch, cpuJump);
			var cpuLoad:LevelModule = addSuccessor(Level.L_CPU_Load, cpuBasic, cpuBranch.layout.dim.y + MODULE_SPACING.y);
			var cpuAdvanced:LevelModule = addSuccessor(Level.L_CPU_Advanced, cpuBasic, cpuBranch.layout.dim.y + cpuLoad.layout.dim.y + MODULE_SPACING.y * 2);
			var cpuFull:LevelModule = addSuccessor(Level.L_CPU_Full, cpuBranch, doubleOp.layout.dim.y + MODULE_SPACING.y);
			
			var d0:LevelModule = addSuccessor(Level.L_DTutorial_0, cpuBasic, -(doubleOp.layout.dim.y + MODULE_SPACING.y) * 2);
			var d1:LevelModule = addSuccessor(Level.L_DTutorial_1, d0);
			var d2:LevelModule = addSuccessor(Level.L_DTutorial_2, d1);
			
			var dcpuBasic:LevelModule = addSuccessor(Level.L_DCPU_Basic, d2);
			
			var ptut1:LevelModule = addSuccessor(Level.L_PTutorial1, dcpuBasic);
			var ptut2:LevelModule = addSuccessor(Level.L_PTutorial2, ptut1);
			var ptut3:LevelModule = addSuccessor(Level.L_PTutorial3, ptut1, ptut2.layout.dim.y + MODULE_SPACING.y);
			var ptut4:LevelModule = addSuccessor(Level.L_PTutorial4, ptut3);
			
			addSuccessor(Level.L_PCPU_Basic, ptut4);
			addSuccessor(Level.L_PCPU_Jump, modulesByName[Level.L_PCPU_Basic.name], modulesByName[Level.L_CPU_Branch.name].y -  modulesByName[Level.L_PCPU_Basic.name].y);
			addSuccessor(Level.L_PCPU_Branch, modulesByName[Level.L_PCPU_Jump.name]);
			addSuccessor(Level.L_PCPU_Load, modulesByName[Level.L_PCPU_Basic.name], modulesByName[Level.L_CPU_Load.name].y -  modulesByName[Level.L_PCPU_Basic.name].y);
			addSuccessor(Level.L_PCPU_Full, modulesByName[Level.L_PCPU_Branch.name], modulesByName[Level.L_CPU_Full.name].y -  modulesByName[Level.L_PCPU_Branch.name].y);
		}
		
		protected function addSuccessor(level:Level, predecessor:LevelModule, offY:int = 0):LevelModule {
			return addLevel(level, predecessor.x + predecessor.layout.dim.x + MODULE_SPACING.x, predecessor.y + offY);
		}
		
		protected function addLevel(level:Level, X:int, Y:int):LevelModule {
			var levelModule:LevelModule = new LevelModule(X, Y, level);
			levelModules.push(levelModule);
			modulesByName[level.name] = levelModule;
			var displayModule:DModule = levelModule.generateDisplay();
			add(displayModule);
			
			//if (levelModule.unlocked) {
				min.x = Math.min(min.x, displayModule.x - MODULE_SPACING.x * U.GRID_DIM);
				min.y = Math.min(min.y, displayModule.y - MODULE_SPACING.y * U.GRID_DIM);
				max.x = Math.max(max.x, displayModule.x + displayModule.width + MODULE_SPACING.x * U.GRID_DIM);
				max.y = Math.max(max.y, displayModule.y + displayModule.height + MODULE_SPACING.y * U.GRID_DIM);
			//}
			
			if (level == Level.last) {
				FlxG.camera.scroll.x = displayModule.x + displayModule.width / 2 - FlxG.width / 2;
				FlxG.camera.scroll.y = displayModule.y + displayModule.height / 2 - FlxG.height / 2;
			}
			
			return levelModule;
		}
		
		protected function addWires():void {
			for each (var levelModule:LevelModule in levelModules)
				if (levelModule.exists)
					for each (var predecessor:Level in levelModule.level.predecessors)
						addWireBetween(levelModule, modulesByName[predecessor.name])
		}
		protected function addWireBetween(successorModule:LevelModule, predecessorModule:LevelModule):void {
			
			
			var outputPortIndex:int = indexByY(successorModule, predecessorModule.level.successors);
			var outputPort:PortLayout = predecessorModule.layout.ports[outputPortIndex + predecessorModule.inputs.length];
			var inputPortIndex:int = indexByY(predecessorModule, successorModule.level.predecessors);
			var inputPort:PortLayout = successorModule.layout.ports[inputPortIndex];
			
			outputPort.port.connections.push(inputPort.port);
			inputPort.port.connections.push(outputPort.port);
			inputPort.port.source = outputPort.port;
			
			var wire:Wire = Wire.wireBetween(inputPort.Loc, outputPort.Loc);
			wire.deployed = true;
			add(new DLevelWire(wire, predecessorModule.level.beaten));
		}
		
		protected function indexByY(module:LevelModule, levels:Vector.<Level>):int {
			var index:int = 0;
			for each (var level:Level in levels)
				if (level != module.level && (modulesByName[level.name] as LevelModule).y < module.y)
					index += 1
			return index;
		}
		
		public function get bounds():FlxRect {
			var x:int = min.x;
			var y:int = min.y;
			var w:int = max.x - min.x;
			var h:int = max.y - min.y;
			
			return new FlxRect(x, y, w, h);
		}
		
		protected const MODULE_SPACING:Point = new Point(3, 2);
	}

}