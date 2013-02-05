package  {
	import Components.Carrier;
	import Displays.DMemory;
	import Displays.DModule;
	import flash.utils.Dictionary;
	import flash.geom.Point;
	import org.flixel.*;
	import Actions.*;
	import Modules.Module;
	import Values.Value;
	import Controls.*;
	import Components.Wire
	import Displays.DWire;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class LevelState extends FlxState {
		
		protected var tick:int;
		
		public var lowerLayer:FlxGroup;
		public var midLayer:FlxGroup;
		public var upperLayer:FlxGroup;
		public var zoom:Number;
		protected var displayWires:Vector.<DWire>;
		protected var displayModules:Vector.<DModule>;
		protected var mode:int = MODE_CONNECT;
		
		public var actionStack:Vector.<Action>;
		public var reactionStack:Vector.<Action>;
		protected var currentWire:Wire;
		
		public var time:Time;
		public var wires:Vector.<Wire>;
		public var modules:Vector.<Module>;
		public var memory:Vector.<Value>;
		
		public var horizontalLines:Dictionary;
		public var verticalLines:Dictionary;
		public var carriersAtPoints:Dictionary;
		
		public var level:Level;
		public function LevelState(level:Level) {
			this.level = level;
		}
		
		override public function create():void {
			U.state = this;
			
			initLayers();
			FlxG.bgColor = 0xffe0e0e0;
			FlxG.mouse.show();
			
			displayWires = new Vector.<DWire>;
			displayModules = new Vector.<DModule>;
			
			actionStack = new Vector.<Action>;
			reactionStack = new Vector.<Action>;
			
			wires = new Vector.<Wire>;
			modules = new Vector.<Module>;
			horizontalLines = new Dictionary;
			verticalLines = new Dictionary;
			carriersAtPoints = new Dictionary;
			
			time = new Time;
			zoom = 1;
			
			for each (var module:Module in level.modules)
				addModule(module);
		}
		
		protected function initLayers():void {
			FlxG.state.add(lowerLayer = new FlxGroup());
			FlxG.state.add(midLayer = new FlxGroup());
			FlxG.state.add(upperLayer = new FlxGroup());
		}
		
		private function addModule(m:Module, fixed:Boolean = true):void {
			if (!m) return;
			
			m.FIXED = fixed;
			m.register();
			modules.push(m);
			
			var displayModule:DModule = m.generateDisplay();
			midLayer.add(displayModule);
			displayModules.push(displayModule);
		}
		
		override public function update():void {
			super.update();
			checkBuildControls();
			checkMenuState();
			forceScroll();
			
			tick++;
		}
		
		protected function checkBuildControls():void {
			if (time.moment)
				return; //no fucking around when shit is running!
			
			switch (mode) {
				case MODE_CONNECT:
					checkConnectControls();
					break;
				case MODE_MODULE:
					checkModuleControls();
					break;
				case MODE_REMOVE:
					checkRemoveControls();
					break;
			}
		}
		
		protected function checkConnectControls():void {
			
			if (FlxG.mouse.justPressed()) {
				//if (buttonMoused) //TODO
					//return;
				
				currentWire = new Wire(U.pointToGrid(U.mouseLoc))
				displayWires.push(midLayer.add(new DWire(currentWire)));
			} else if (currentWire) {
				if (FlxG.mouse.pressed())
					currentWire.attemptPathTo(U.pointToGrid(U.mouseLoc))
				else {
					new CustomAction(Wire.place, Wire.remove, currentWire).execute();
					currentWire = null;
				}
			}
			
			
			if (currentWire) {
				if (ControlSet.CANCEL_KEY.justPressed()) {
					currentWire.exists = false;
					currentWire = null;
				}
				
			} else {
				if (ControlSet.DELETE_KEY.justPressed())
					destroyWires();
			}
		}
		
		protected function checkModuleControls():void {
			//TODO
		}
		
		protected function checkRemoveControls():void {
			//TODO
		}
		
		protected function checkMenuState():void {
			//TODO
		}
		
		
		private function destroyWires():void {
			for each (var wire:DWire in displayWires)
				if (wire.exists && wire.overlapsPoint(U.mouseFlxLoc)) {
					new CustomAction(Wire.remove, Wire.place, wire.wire).execute();
					//break;
				}
		}
		
		
		protected function forceScroll(group:FlxGroup = null):void {
			group = group ? group : upperLayer;
			for each (var basic:FlxBasic in group.members)
				if (basic is FlxObject) {
					var obj:FlxObject = basic as FlxObject;
					obj.scrollFactor.x = obj.scrollFactor.y = 0;
				} else if (basic is FlxGroup)
					forceScroll(basic as FlxGroup);
		}
		
		
		public function lineToSpec(a:Point, b:Point):String {
			var horizontal:Boolean = a.x != b.x;
			var root:Point = horizontal ? a.x < b.x ? a : b : a.y < b.y ? a : b;
			return root.x + U.COORD_DELIM + root.y;
		}
		
		public function lineContents(a:Point, b:Point):* {
			var horizontal:Boolean = a.x != b.x;
			return (horizontal ? horizontalLines : verticalLines)[lineToSpec(a, b)]
		}
		
		public function setLineContents(a:Point, b:Point, newContents:*):* {
			var horizontal:Boolean = a.x != b.x;
			return (horizontal ? horizontalLines : verticalLines)[lineToSpec(a, b)] = newContents;
		}
		
		public function carriersAtPoint(p:Point):Vector.<Carrier> {
			return carriersAtPoints[p.x + U.COORD_DELIM + p.y];
		}
		
		public function addCarrierAtPoint(p:Point, carrier:Carrier):void {
			var coordStr:String = p.x + U.COORD_DELIM + p.y;
			var carriers:Vector.<Carrier> = carriersAtPoints[coordStr];
			if (!carriers) carriers = carriersAtPoints[coordStr] = new Vector.<Carrier>;
			carriers.push(carrier);
		}
		
		public function removeCarrierFromPoint(p:Point, carrier:Carrier):void {
			var coordStr:String = p.x + U.COORD_DELIM + p.y;
			var carriers:Vector.<Carrier> = carriersAtPoints[coordStr];
			carriers.splice(carriers.indexOf(carrier), 1);
			if (!carriers.length) carriersAtPoints[coordStr] = null;
		}
		
		
		override public function draw():void {
			super.draw();
			if (U.DEBUG && U.DEBUG_RENDER_COLLIDE)
				debugRenderCollision();
		}
		
		private var debugLineH:FlxSprite;
		private var debugLineV:FlxSprite;
		private function debugRenderCollision():void {
			if (!debugLineH) {
				debugLineH = new FlxSprite().makeGraphic(U.GRID_DIM, 3, 0xffff00ff);
				debugLineH.offset.y = 1;
				debugLineV = new FlxSprite().makeGraphic(3, U.GRID_DIM, 0xffff00ff);
				debugLineV.offset.x = 1;
			}
			
			var s:String, coords:Array;
			
			for (s in horizontalLines) {
				if (!horizontalLines[s]) continue;
				coords = s.split(U.COORD_DELIM);
				debugLineH.x = int(coords[0]) * U.GRID_DIM;
				debugLineH.y = int(coords[1]) * U.GRID_DIM;
				debugLineH.draw();
			}
			
			for (s in verticalLines) {
				if (!verticalLines[s]) continue;
				coords = s.split(U.COORD_DELIM);
				debugLineV.x = int(coords[0]) * U.GRID_DIM;
				debugLineV.y = int(coords[1]) * U.GRID_DIM;
				debugLineV.draw();
			}
		}
		
		
		protected const MODE_MODULE:int = 0;
		protected const MODE_CONNECT:int = 1;
		protected const MODE_REMOVE:int = 2;

		[Embed(source = "../lib/art/ui/lightbulb.png")] private const _module_sprite:Class;
		[Embed(source = "../lib/art/ui/wire.png")] private const _connect_sprite:Class;
		[Embed(source = "../lib/art/ui/remove.png")] private const _remove_sprite:Class;
		private const MODE_SPRITES:Array = [_module_sprite, _connect_sprite, _remove_sprite];
		[Embed(source = "../lib/art/ui/list.png")] private const _list_sprite:Class;
		private const HOTKEYS:Array = [new Key("ONE"), new Key("TWO"), new Key("THREE")];
		[Embed(source = "../lib/art/ui/undo.png")] private const _undo_sprite:Class;
		[Embed(source = "../lib/art/ui/redo.png")] private const _redo_sprite:Class;
		[Embed(source = "../lib/art/ui/up.png")] private const _back_sprite:Class;
		[Embed(source = "../lib/art/ui/floppy.png")] private const _save_sprite:Class;
		[Embed(source = "../lib/art/ui/yppolf.png")] private const _evas_sprite:Class;
		[Embed(source = "../lib/art/ui/maglass.png")] private const _zoom_sprite:Class;
		[Embed(source = "../lib/art/ui/x1.png")] private const _z1_sprite:Class;
		[Embed(source = "../lib/art/ui/x2.png")] private const _z2_sprite:Class;
		[Embed(source = "../lib/art/ui/x3.png")] private const _z3_sprite:Class;
		private const ZOOMS:Array = [_z1_sprite, _z2_sprite, _z3_sprite];
		[Embed(source = "../lib/art/ui/code.png")] private const _data_sprite:Class;
	}

}