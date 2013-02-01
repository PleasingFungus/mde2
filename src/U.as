package  {
	import Actions.Action;
	import Controls.ControlSet;
	import flash.geom.Point;
	import Modules.*;
	import org.flixel.*;
	import Testing.Types.InstructionType;
	import Values.FixedValue;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class U {
		public static const VERSION:String = "0.01";
		public static const DEBUG:Boolean = true;
		
		[Embed(source = "../lib/fonts/FuturaLT.ttf", fontFamily = "FUTUR")] private const _1:String;
		public static const FONT_:String = "FUTUR";
		[Embed(source = "../lib/fonts/FuturaLT-Bold.ttf", fontFamily = "FUTURB")] private const _2:String;
		public static const FONT_BOLD:String = "FUTURB";
		[Embed(source = "../lib/fonts/FuturaLT-Condensed.ttf", fontFamily = "F")] private const _3:String;
		public static const FNT:String = "F";
		[Embed(source = "../lib/fonts/FuturaLT-CondensedBold.ttf", fontFamily = "FB")] private const _4:String;
		public static const FNT_BOLD:String = "FB";
		[Embed(source = "../lib/fonts/geneva_9.ttf", fontFamily = "GV")] private const _5:String;
		public static const GENEVA:String = "GV";
		public static var FONT:String = null;
		public static var FONT_SIZE:int = 16;
		
		public static var levels:Vector.<Level>;
		public static var level:LevelState;
		
		public static const GRID_DIM:int = 8;
		
		public static const V_UNPOWERED:FixedValue = new FixedValue("-", NaN);
		public static const V_UNKNOWN:FixedValue = new FixedValue("?", NaN);
		
		public static const SAVE_DELIM:String = '~';
		
		public static const ALL_MODULES:Array = [Adder, ASU, Clock, ConstIn, Latch,
												 Outport, Regfile, Comparator,
												 InstructionMemory, DataMemory, Mux, Demux,
												 Accumulator, ProgramCounter];
		
		public static var save:FlxSave;
		
		private static var initialized:Boolean = false;
		
		public static function init():void {			
			if (initialized)
				return;
			
			save = new FlxSave();
			save.bind("MultiduckExtravaganza");
			
			InstructionType.init();
			
			levels = new Vector.<Level>;
			Level.init();
		}
		
		public static function load():void {
			ControlSet.load();
		}
		
		public static function initLevel():void {
			
		}
		
		public static function forceScroll(group:FlxGroup = null):void {
			group = group ? group : level.upperLayer;
			for each (var basic:FlxBasic in group.members)
				if (basic is FlxObject) {
					var obj:FlxObject = basic as FlxObject;
					obj.scrollFactor.x = obj.scrollFactor.y = 0;
				} else if (basic is FlxGroup)
					forceScroll(basic as FlxGroup);
		}
		
		public static function get mouseLoc():Point {
			return new Point(FlxG.mouse.x / level.zoom - FlxG.camera.scroll.x * (1 / level.zoom - 1),
							 FlxG.mouse.y / level.zoom - FlxG.camera.scroll.y * (1 / level.zoom - 1));
		}
		
		public static function get mouseFlxLoc():FlxPoint {
			return new FlxPoint(FlxG.mouse.x / level.zoom - FlxG.camera.scroll.x * (1 / level.zoom - 1),
							 FlxG.mouse.y / level.zoom - FlxG.camera.scroll.y * (1 / level.zoom - 1));
		}
		
		public static function pointToGrid(p:Point):Point {
			return new Point(Math.round(p.x / U.GRID_DIM) * U.GRID_DIM,
								Math.round(p.y / U.GRID_DIM) * U.GRID_DIM);
		}
		
		
		
		public static function undo():Action {
			if (!level.actionStack.length)
				return null;
			return level.actionStack.pop().revert();
		}
		
		public static function redo():Action {
			if (!level.reactionStack.length)
				return null;
			return level.reactionStack.pop().execute();
		}
		
		public static const MAX_INT:int = 127;
		public static const MIN_INT:int = -128;
		
		
	}

}