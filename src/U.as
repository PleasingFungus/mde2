package  {
	import Actions.Action;
	import Controls.ControlSet;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLRequestMethod;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import Layouts.Nodes.NodeTuple;
	import Levels.LevelShard;
	import Modules.*;
	import org.flixel.*;
	import Testing.Types.InstructionType;
	import UI.ButtonManager;
	import UI.FontTuple;
	import Values.FixedValue;
	import LevelStates.LevelState;
	import Levels.Level;
	import UI.ColorText;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class U {
		public static const VERSION:String = "0.833";
		public static const SAVE_VERSION:int = 4;
		
		public static const BINARY_SAVES:Boolean = true;
		public static const BLIT_ENABLED:Boolean = false;
		public static const UPPER_NODE_TEXT:Boolean = true;
		public static var PLAIN_BG:Boolean = false;
		
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
		public static const NODE_FONT_LARGE:FontTuple = new FontTuple(MUNRO_WEB, 32);
		public static const NODE_FONT_SMALL:FontTuple = new FontTuple(MUNRO_WEB, 16);
		public static function get NODE_FONT():FontTuple { return UPPER_NODE_TEXT && zoom < 1 ? NODE_FONT_SMALL : NODE_FONT_LARGE; }
		public static const MODULE_LABEL_FONT:FontTuple = new FontTuple(MUNRO_WEB, 32);
		public static const TOOLBAR_FONT:FontTuple = new FontTuple(MUNRO_WEB, 16);
		public static const MODULE_FONT_CLOSE:FontTuple = new FontTuple(SYSTEM, 16);
		public static const MODULE_FONT_FAR:FontTuple = new FontTuple(SYSTEM, 32);
		
		public static var save:FlxSave;
		
		public static var state:LevelState;
		public static var buttonManager:ButtonManager;
		public static var zoom:Number;
		public static var clipboard:String;
		
		public static const GRID_DIM:int = 16;
		
		public static const V_UNPOWERED:FixedValue = new FixedValue("-", NaN);
		public static const V_UNKNOWN:FixedValue = new FixedValue("?", NaN);
		
		public static const SAVE_DELIM:String = '~';
		public static const MAJOR_SAVE_DELIM:String = "~~";
		public static const COORD_DELIM:String = ',';
		public static const POINT_DELIM:String = ',,';
		public static const ARG_DELIM:String = ',';
		
		public static var tutorialState:int;
		public static const TUT_NEW:int = 0;
		public static const TUT_READ_HTP:int = 1;
		public static const TUT_BEAT_TUT_1:int = 2;
		public static const TUT_BEAT_TUT_2:int = 3;
		
		public static const DEMO:Boolean = false;
		public static var DEMO_LIMIT:Level;
		public static var DEMO_PERMITTED:Vector.<Level>;
		
		public static function updateTutState(newTutState:int):int {
			if (newTutState > tutorialState)
				return U.save.data['tut'] = tutorialState = newTutState;
			return tutorialState;
		}
		
		
		
		private static var initialized:Boolean = false;
		public static var checkedURL:Boolean = false;
		
		public static function init():void {			
			if (initialized)
				return;
			initialized = true;
			
			C.warmupFactors(MAX_INT);
			
			save = new FlxSave();
			save.bind("MultiduckExtravaganza");
			
			tutorialState = save.data['tut'];
			
			InstructionType.init();
			Module.init();
			LevelShard.init();
			
			Level.ALL = Level.list();
			if (FlxG.debug)
				Level.validate(Level.ALL);
			DEMO_LIMIT = Level.L_CPU_Basic;
			DEMO_PERMITTED = Level.ALL.slice(0, Level.ALL.indexOf(DEMO_LIMIT) + 1); //dubious?
			
			zoom = 1;
			
			if (!FlxG.debug)
				sendStartupInfo();
		}
		
		public static function load():void {
			ControlSet.load();
			Level.load();
		}
		
		private static function sendStartupInfo():void {
			var loader:URLLoader = new URLLoader;
			
			var variables:URLVariables = new URLVariables();  
			variables.version = VERSION;
			
			var request:URLRequest = new URLRequest("http://pleasingfungus.com/mde2/startup.php"); 
			request.method = URLRequestMethod.POST;  
			request.data = variables;
			
			loader.load(request);
			
			C.log("Sent startup request: " + request);
		}
		
		
		public static function displayVersion():String {
			if (FlxG.debug)
				return VERSION + "-DEBUG";
			if (VERSION.slice(0,2) == '0.')
				return VERSION + "-PLAYTEST";
			return VERSION;
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
		
		private static var _rect:Rectangle = new Rectangle;
		public static function screenRect():Rectangle {
			_rect.x = FlxG.camera.scroll.x;
			_rect.y = FlxG.camera.scroll.y;
			_rect.width = FlxG.width / zoom;
			_rect.height = FlxG.height / zoom;
			return _rect;
		}
		
		public static const INSERT_URL:String = "http://pleasingfungus.com/mde2/insert.php";
		public static const LOOKUP_URL:String = "http://pleasingfungus.com/mde2/lookup.php";
		
		
		public static const UNCONNECTED_COLOR:uint = 0xff0000;
		public static const HALFCONNECTED_COLOR:uint = 0xac1616;
		public static const UNPOWERED_COLOR:uint = 0x1d19d9;
		public static const UNKNOWN_COLOR:uint = 0xc219d9
		public static const HIGHLIGHTED_COLOR:uint = 0xfff03c;
		public static const SELECTION_COLOR:uint = 0x519dcf;
		public static const DEFAULT_COLOR:uint = 0x0;
		
		public static const BG_COLOR:uint = 0xffe0e0e0;
		
		public static const CONFIG_COLOR:uint = 0x89cfcf;
		
		public static const OPCODE_COLOR:uint = 0x61e263;
		public static const SOURCE:ColorText = new ColorText(0xe2618e, "source");
		public static const TARGET:ColorText = new ColorText(0xe29461, "target");
		public static const DESTINATION:ColorText = new ColorText(0x89cfcf, "destination");
		
		public static const LINE_NUM:ColorText = new ColorText(0xa461e2, "Line no.");
		
		public static const MIN_INT:int = -128;
		public static const MAX_INT:int = 127;
		public static const MIN_MEM:int = MAX_INT;
		public static const MAX_MEM:int = MIN_MEM - MIN_INT;
	}

}