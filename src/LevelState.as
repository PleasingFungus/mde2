package  {
	import flash.utils.Dictionary;
	import flash.geom.Point;
	import org.flixel.*;
	import Actions.*;
	import Controls.*;
	import Displays.*;
	import Modules.Module;
	import UI.ButtonList;
	import UI.ModuleSlider;
	import UI.TextButton;
	import Values.Value;
	import Components.Carrier;
	import Components.Wire
	import UI.GraphicButton;
	import UI.MenuButton;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class LevelState extends FlxState {
		
		protected var tick:int;
		protected var savedString:String;
		
		public var lowerLayer:FlxGroup;
		public var midLayer:FlxGroup;
		public var upperLayer:FlxGroup;
		public var zoom:Number;
		
		protected var displayWires:Vector.<DWire>;
		protected var displayModules:Vector.<DModule>;
		protected var buttons:Vector.<MenuButton>
		protected var modeButton:GraphicButton;
		protected var modeList:ButtonList;
		protected var mode:int = MODE_CONNECT;
		protected var moduleList:ButtonList;
		protected var moduleSlider:ModuleSlider;
		
		public var actionStack:Vector.<Action>;
		public var reactionStack:Vector.<Action>;
		protected var currentWire:Wire;
		protected var currentModule:Module;
		
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
			buttons = new Vector.<MenuButton>;
			
			actionStack = new Vector.<Action>;
			reactionStack = new Vector.<Action>;
			
			memory = new Vector.<Value>;
			wires = new Vector.<Wire>;
			modules = new Vector.<Module>;
			horizontalLines = new Dictionary;
			verticalLines = new Dictionary;
			carriersAtPoints = new Dictionary;
			
			time = new Time;
			zoom = 1;
			
			for each (var module:Module in level.modules)
				addModule(module);
			load();
			
			makeUI();
		}
		
		protected function initLayers():void {
			add(lowerLayer = new FlxGroup());
			add(midLayer = new FlxGroup());
			add(upperLayer = new FlxGroup());
		}
		
		private function addWire(w:Wire, fixed:Boolean = true):void {
			w.FIXED = fixed;
			Wire.place(w);
			
			var displayWire:DWire = new DWire(w);
			midLayer.add(displayWire);
			displayWires.push(displayWire);
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
		
		protected function makeUI():void {
			buttons = new Vector.<MenuButton>;
			remove(upperLayer, true);
			add(upperLayer = new FlxGroup);
			tick = 0;
			
			makeModeButtons();
			makeBackButton();
			makeSaveButton();
			makeUndoButtons();
			makeZoomButtons();
			makeDataButton();
			
			if (mode == MODE_MODULE)
				makeModuleButton();
			
			upperLayer.add(new DTime(FlxG.width / 2 - 50, 10));
			upperLayer.add(new Scroller);
		}
		
		protected function makeBackButton():void {
			var backButton:GraphicButton = new GraphicButton(90, 10, _back_sprite, function back():void { FlxG.switchState(new MenuState); }, new Key("ESCAPE"));
			backButton.fades = true;
			upperLayer.add(backButton);
		}
		
		protected function makeSaveButton():void {
			var saveButton:GraphicButton = new GraphicButton(130, 10, _save_sprite, save, new Key("S"));
			buttons.push(upperLayer.add(saveButton));
		}
		
		protected function makeUndoButtons():void {
			var undoButton:GraphicButton = new GraphicButton(FlxG.width - 85, 10, _undo_sprite, undo, new Key("Z"));
			buttons.push(upperLayer.add(undoButton));
			
			var redoButton:GraphicButton = new GraphicButton(FlxG.width - 45, 10, _redo_sprite, redo, new Key("Y"));
			buttons.push(upperLayer.add(redoButton));
		}
		
		protected function makeModeButtons():void {
			upperLayer.add(modeButton = new GraphicButton(10, 10, MODE_SPRITES[mode], function deployMenu():void {
				if (!tick) return;
				
				if (currentModule) {
					currentModule.exists = false;
					currentModule = null;
				}
				
				exists = false;
				//if (zoomList)
					//zoomList.exists = false;
				
				var modeSelectButtons:Vector.<MenuButton> = new Vector.<MenuButton>;
				for (var newMode:int = 0; newMode <= MODE_REMOVE; newMode++) {
					modeSelectButtons.push(new GraphicButton( -1, -1, MODE_SPRITES[newMode], function selectMode(newMode:int):void {
						if (!tick) return;
						mode = newMode;
						makeUI();
					}, HOTKEYS[newMode]).setParam(newMode).setSelected(newMode == mode));
					
					for each (var button:MenuButton in modeSelectButtons)
						buttons.push(button);
				}
				
				modeList = new ButtonList(modeButton.X, modeButton.Y, modeSelectButtons);
				modeList.setSpacing(4);
				modeList.justDie = true;
				upperLayer.add(modeList);
				
				tick = 0;
			}, new Key("TAB")));
			
			buttons.push(modeButton);
		}
		
		protected function makeZoomButtons():void {
			//TODO
			/*if (zoomButton)
				zoomButton.exists = false;
			
			upperLayer.add(zoomButton = new GraphicButton(FlxG.width - 45, 90, _zoom_sprite, function deployMenu():void {
				if (!tick) return;
				
				exists = false;
				//if (moduleBox)
					//moduleBox.exists = false;
				if (modeList)
					modeList.exists = false;
				
				var zoomButtons:Vector.<MenuButton> = new Vector.<MenuButton>;
				for (var zoomLevel:int = 0; zoomLevel <= 2; zoomLevel++)
					zoomButtons.push(new GraphicButton( -1, -1, ZOOMS[zoomLevel], function selectZoom(zoomLevel:int):void {
						if (!tick) return;
						
						FlxG.camera.scroll.x += (FlxG.width / 2) / U.zoom;
						FlxG.camera.scroll.y += (FlxG.height / 2) / U.zoom;
						
						C.log(zoomLevel, U.FONT, U.FONT_SIZE);
						U.zoom = Math.pow(2, -zoomLevel);
						//U.FONT = zoomLevel == 2 ? U.GENEVA : null;
						U.FONT_SIZE = zoomLevel == 2 ? 32 : 16;
						C.log(zoomLevel, U.FONT, U.FONT_SIZE);
						
						FlxG.camera.scroll.x -= (FlxG.width / 2) / U.zoom;
						FlxG.camera.scroll.y -= (FlxG.height / 2) / U.zoom;
						
						zoomList.exists = false;
					}, HOTKEYS[zoomLevel]).setParam(zoomLevel).setSelected(Math.pow(2, -zoomLevel) == U.zoom));
				
				zoomList = new ButtonList(zoomButton.X, zoomButton.Y, zoomButtons);
				zoomList.setSpacing(4);
				zoomList.justDie = true;
				U.upperLayer.add(zoomList);
				
				tick = 0;
			}, new Key("PLUS")));*/
		}
		
		protected function makeModuleButton():void {
			var listButton:GraphicButton = new GraphicButton(50, 10, _list_sprite, function listModules():void {
				if (!tick) return;
				
				if (currentModule) {
					currentModule.exists = false;
					currentModule = null;
				}
				
				//build a list of buttons for allowed modules/names
				var moduleButtons:Vector.<MenuButton> = new Vector.<MenuButton>;
				for each (var moduleType:Class in level.allowedModules)
					moduleButtons.push(new TextButton( -1, -1, Module.getArchetype(moduleType).name, function chooseModule(moduleType:Class):void {
						if (!tick) return;
						
						modules.push(currentModule = new moduleType( -1, -1));
						displayModules.push(midLayer.add(new DModule(currentModule)));
						tick = 0;
					}).setParam(moduleType));
				
				//put 'em in a list
				moduleList = new ButtonList(listButton.X, listButton.Y, moduleButtons);
				moduleList.setSpacing(4);
				moduleList.justDie = true;
				upperLayer.add(moduleList);
				
				tick = 0;
			}, new Key("FOUR"));
			
			buttons.push(upperLayer.add(listButton));
		}
		
		protected function makeDataButton():void {
			if (memory.length)
				buttons.push(upperLayer.add(new GraphicButton(FlxG.width - 45, 50, _data_sprite, function _():void {
					upperLayer.add(new DMemory(memory));
				}, new Key("C"))));
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
				if (buttonMoused) //TODO
					return;
				
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
			if (currentModule && ControlSet.CANCEL_KEY.justPressed()) {
				currentModule.exists = false;
				currentModule = null;
			}
			
			if (moduleSlider && moduleSlider.overlapsPoint(FlxG.mouse))
				moduleList.exists = true;
			
			var moduleButtonMoused:Boolean;
			if (moduleList && !moduleList.exists)
				moduleList = null;
			else if (moduleList)
				for each (var button:MenuButton in moduleList.buttons)
					if (button.moused && Module.getArchetype(button.callWithParam as Class).configuration != null) {
						moduleButtonMoused = true;
						if (moduleSlider && moduleSlider.parent != button)
							moduleSlider.exists = false;
						upperLayer.add(moduleSlider = new ModuleSlider(button)); //TODO
						break;
					}
			
			if (moduleSlider && !moduleButtonMoused) {
				moduleSlider.exists = false;
				moduleSlider = null;
			}
			
			if (!tick) return;
			
			if (currentModule) {
				var mousePoint:Point = U.pointToGrid(U.mouseLoc);
				currentModule.x = mousePoint.x;
				currentModule.y = mousePoint.y;
				
				if (FlxG.mouse.justPressed()) {
					if (buttonMoused) {
						currentModule.exists = false;
						currentModule = null;
					} else if (currentModule.validPosition)
						placeModule();
				}
			} else {
				if (ControlSet.DELETE_KEY.justPressed())
					destroyModules();
			}
		}
		
		protected function placeModule():void {
			new CustomAction(Module.place, Module.remove, currentModule).execute();
			currentModule = null;
		}
		
		private function destroyModules():void {
			for each (var dModule:DModule in displayModules)
				if (dModule.module.exists && dModule.overlapsPoint(U.mouseFlxLoc) && !dModule.module.FIXED) {
					new CustomAction(Module.remove, Module.place, dModule.module).execute();
					//break;
				}
		}
		
		protected function checkRemoveControls():void {
			if (FlxG.mouse.pressed() || ControlSet.DELETE_KEY.pressed()) {
				destroyModules();
				destroyWires();
			}
		}
		
		protected function checkMenuState():void {
			if (modeList && !modeList.exists) modeList = null;
			modeButton.exists = !modeList;
		}
		
		protected function get buttonMoused():MenuButton {
			for each (var button:MenuButton in buttons)
				if (button.exists && button.moused)
					return button;
			return null;
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
		
		
		private function undo():Action {
			if (!actionStack.length)
				return null;
			return actionStack.pop().revert();
		}
		
		private function redo():Action {
			if (!reactionStack.length)
				return null;
			return reactionStack.pop().execute();
		}
		
		protected function save():void {
			savedString = genSaveString();
			U.save.data[level.name] = savedString;
			C.log(savedString);
		}
		
		protected function genSaveString():String {
			var saveString:String = "";
			
			//save modules
			var modulesExist:Boolean;
			for each (var module:Module in modules)
				if (module.exists && !module.FIXED) {
					saveString += module.saveString();
					modulesExist = true;
				}
			saveString += U.SAVE_DELIM;
			if (!modulesExist)
				saveString += U.SAVE_DELIM;
			
			//save wires
			var wiresExist:Boolean;
			for each (var wire:Wire in wires)
				if (wire.exists) {
					saveString += wire.saveString();
					wiresExist = true;
				}
			
			saveString += U.SAVE_DELIM;
			if (!wiresExist)
				saveString += U.SAVE_DELIM;
			
			return saveString;
		}
		
		
		protected function load():void {
			var saveString:String = U.save.data[level.name];
			if (!saveString)
				return;
			
			var saveArray:Array = saveString.split(U.SAVE_DELIM + U.SAVE_DELIM);
			
			//load modules
			var moduleStrings:String = saveArray[0];
			if (moduleStrings.length)
				for each (var moduleString:String in moduleStrings.split(U.SAVE_DELIM))
					addModule(Module.fromString(moduleString), false);
			
			//load wires
			var wireStrings:String = saveArray[1];
			if (wireStrings.length)
				for each (var wireString:String in wireStrings.split(U.SAVE_DELIM))
					addWire(Wire.fromString(wireString), false);
			
			savedString = saveString;
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