package  {
	import Actions.Action;
	import Controls.ControlSet;
	import flash.geom.Point;
	import Levels.LevelShard;
	import Modules.*;
	import org.flixel.*;
	import Testing.Types.InstructionType;
	import UI.ButtonManager;
	import UI.FontTuple;
	import Values.FixedValue;
	import LevelStates.LevelState;
	import Levels.Level;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class U {
		public static const VERSION:String = "0.01";
		public static const DEBUG:Boolean = true;
		
		public static const DEBUG_RENDER_COLLIDE:Boolean = false;
		public static const DEBUG_PRINT_TESTS:Boolean = false;
		public static const DEBUG_PRINT_CONNECTIONS:Boolean = false;
		
		public static const BLIT_ENABLED:Boolean = false;
		
		[Embed(source = "../lib/fonts/munro.ttf", fontFamily = "MUNRO")] private const _1:String;
		public static const MUNRO:String = "MUNRO";
		[Embed(source = "../lib/fonts/munro_narrow.ttf", fontFamily = "MUNRO_N")] private const _2:String;
		public static const MUNRO_NARROW:String = "MUNRO_N";
		[Embed(source = "../lib/fonts/munro_small.ttf", fontFamily = "MUNRO_S")] private const _3:String;
		public static const MUNRO_SMALL:String = "MUNRO_S";
		[Embed(source = "../lib/fonts/munro-webfont.ttf", fontFamily = "MUNRO_W")] private const _4:String;
		public static const MUNRO_WEB:String = "MUNRO_W";
		public static const SYSTEM:String = "system";
		
		public static const LABEL_FONT:FontTuple = new FontTuple(SYSTEM, 16);
		public static const BODY_FONT:FontTuple = new FontTuple(SYSTEM, 16);
		public static const TITLE_FONT:FontTuple = new FontTuple(SYSTEM, 32);
		public static const NODE_FONT:FontTuple = new FontTuple(MUNRO_WEB, 32);
		public static const MODULE_FONT_CLOSE:FontTuple = new FontTuple(SYSTEM, 16);
		public static const MODULE_FONT_FAR:FontTuple = new FontTuple(SYSTEM, 32);
		
		public static var save:FlxSave;
		public static var tuts:Vector.<Level>;
		public static var delayTuts:Vector.<Level>;
		public static var levels:Vector.<Level>;
		
		public static var state:LevelState;
		public static var buttonManager:ButtonManager;
		public static var zoom:Number;
		
		public static const GRID_DIM:int = 16;
		
		public static const V_UNPOWERED:FixedValue = new FixedValue("-", NaN);
		public static const V_UNKNOWN:FixedValue = new FixedValue("?", NaN);
		
		public static const SAVE_DELIM:String = '~';
		public static const COORD_DELIM:String = ',';
		public static const POINT_DELIM:String = ',,';
		
		public static var tutorialState:int;
		public static const TUT_NEW:int = 0;
		public static const TUT_READ_HTP:int = 1;
		public static const TUT_BEAT_TUT_1:int = 2;
		public static const TUT_BEAT_TUT_2:int = 3;
		
		public static function updateTutState(newTutState:int):int {
			if (newTutState > tutorialState)
				return U.save.data['tut'] = tutorialState = newTutState;
			return tutorialState;
		}
		
		
		
		private static var initialized:Boolean = false;
		
		public static function init():void {			
			if (initialized)
				return;
			initialized = true;
			
			save = new FlxSave();
			save.bind("MultiduckExtravaganza");
			
			tutorialState = save.data['tut'];
			
			InstructionType.init();
			Module.init();
			LevelShard.init();
			
			tuts = Level.tutorials();
			delayTuts = Level.delayTutorials();
			levels = Level.list();
			
			zoom = 1;
			
			C.warmupFactors(MAX_INT);
		}
		
		public static function load():void {
			ControlSet.load();
		}
		
		
		public static function get mouseLoc():Point {
			return new Point(FlxG.mouse.x / zoom - FlxG.camera.scroll.x * (1 / zoom - 1),
							 FlxG.mouse.y / zoom - FlxG.camera.scroll.y * (1 / zoom - 1));
		}
		
		public static function get mouseFlxLoc():FlxPoint {
			return new FlxPoint(FlxG.mouse.x / zoom - FlxG.camera.scroll.x * (1 / zoom - 1),
								FlxG.mouse.y / zoom - FlxG.camera.scroll.y * (1 / zoom - 1));
		}
		
		public static function pointOnGrid(p:Point):Point {
			return new Point(Math.round(p.x / U.GRID_DIM) * U.GRID_DIM,
							 Math.round(p.y / U.GRID_DIM) * U.GRID_DIM);
		}
		
		public static function pointToGrid(p:Point):Point {
			return new Point(Math.round(p.x / U.GRID_DIM),
							 Math.round(p.y / U.GRID_DIM));
		}
		
		
		public static const UNCONNECTED_COLOR:uint = 0xff0000;
		public static const UNPOWERED_COLOR:uint = 0x1d19d9;
		public static const UNKNOWN_COLOR:uint = 0xc219d9
		public static const HIGHLIGHTED_COLOR:uint = 0xfff03c;
		public static const DEFAULT_COLOR:uint = 0x0;
		
		
		public static const MAX_INT:int = 127;
		public static const MIN_INT:int = -128;
	}

}