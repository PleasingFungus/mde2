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
	import UI.Sliderbar;
	import UI.TextButton;
	import Values.FixedValue;
	import Values.Value;
	import Components.Carrier;
	import Components.Wire
	import UI.GraphicButton;
	import UI.MenuButton;
	import flash.display.BitmapData
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class LevelState extends FlxState {
		
		protected var savedString:String;
		
		public var lowerLayer:FlxGroup;
		public var midLayer:FlxGroup;
		public var upperLayer:FlxGroup;
		public var zoom:Number;
		
		protected var displayWires:Vector.<DWire>;
		protected var displayModules:Vector.<DModule>;
		//protected var buttons:Vector.<MenuButton>
		protected var mode:int = MODE_CONNECT;
		protected var listOpen:int;
		protected var UIChanged:Boolean;
		protected var editEnabled:Boolean = true;
		
		protected var undoButton:MenuButton;
		protected var redoButton:MenuButton;
		
		protected var displayTime:DTime;
		protected var preserveModule:Boolean;
		protected var runningTest:Boolean;
		
		protected var moduleCategory:String;
		protected var moduleList:ButtonList;
		protected var moduleSliders:Vector.<ModuleSlider>;
		protected var displayDelay:DDelay;
		
		public var actionStack:Vector.<Action>;
		public var reactionStack:Vector.<Action>;
		protected var currentWire:Wire;
		protected var currentModule:Module;
		
		public var time:Time;
		public var wires:Vector.<Wire>;
		public var modules:Vector.<Module>;
		public var memory:Vector.<Value>;
		public var initialMemory:Vector.<Value>;
		
		public var horizontalLines:Dictionary;
		public var verticalLines:Dictionary;
		public var carriersAtPoints:Dictionary;
		
		public var level:Level;
		public function LevelState(level:Level) {
			this.level = level;
		}
		
		override public function create():void {
			U.state = this;
			
			FlxG.bgColor = 0xffe0e0e0;
			FlxG.mouse.show();
			
			actionStack = new Vector.<Action>;
			reactionStack = new Vector.<Action>;
			zoom = 1;
			
			initialMemory = level.goal.genMem(0.5);
			
			load();
			
			makeUI();
			upperLayer.add(new DGoal(level));
			U.enforceButtonPriorities = true;
		}
		
		protected function initLayers():void {
			members = [];
			add(lowerLayer = new FlxGroup());
			add(midLayer = new FlxGroup());
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
			m.initialize();
			modules.push(m);
			
			var displayModule:DModule = m.generateDisplay();
			midLayer.add(displayModule);
			displayModules.push(displayModule);
		}
		
		protected function makeUI():void {
			upperLayer = new FlxGroup;
			UIChanged = true;
			
			upperLayer.add(editEnabled ? displayTime = new DTime(FlxG.width / 2 - 50, 10) : displayTime);
			upperLayer.add(new Scroller);
			upperLayer.add(new DCurrent(displayWires, displayModules));
			makeDataButton();
			makeInfoButton();
			makeBackButton();
			
			if (mode == MODE_DELAY) {
				if (!displayDelay || !displayDelay.exists)
					midLayer.add(displayDelay = new DDelay(modules, displayModules));
			} else if (displayDelay)
				displayDelay.exists = false;
			
			if (!editEnabled) {
				listOpen = LIST_NONE;
				if (currentModule) {
					currentModule.exists = false;
					currentModule = null;
				}
				return;
			}
			
			listOpen == LIST_MODES ? makeModeMenu() : makeModeButton();
			listOpen == LIST_ZOOM ? makeZoomList() : makeZoomButton();
			if (mode == MODE_MODULE)
				switch (listOpen) {
					case LIST_MODULES: makeModuleList(); break;
					case LIST_CATEGORIES: makeModuleCatList(); break;
					case LIST_NONE: default: makeModuleCatButton(); break;
				}
			makeSaveButton();
			makeUndoButtons();
			makeTestButtons();
		}
		
		protected function makeBackButton():void {
			var backButton:GraphicButton = new GraphicButton(FlxG.width - 45, 10, _back_sprite, function back():void {
				save();
				FlxG.switchState(new MenuState);
			});
			backButton.fades = true;
			upperLayer.add(backButton);
		}
		
		protected function makeSaveButton():void {
			var saveButton:GraphicButton = new GraphicButton(FlxG.width - 85, 50, _save_sprite, save, new Key("S"));
			upperLayer.add(saveButton);
		}
		
		protected function makeUndoButtons():void {
			undoButton = new GraphicButton(FlxG.width - 165, 50, _undo_sprite, undo, new Key("Z"));
			upperLayer.add(undoButton);
			
			redoButton = new GraphicButton(FlxG.width - 125, 50, _redo_sprite, redo, new Key("Y"));
			upperLayer.add(redoButton);
			
			var resetButton:GraphicButton = new GraphicButton(FlxG.width - 45, 90, _reset_sprite, reset);
			upperLayer.add(resetButton);
		}
		
		protected function makeDataButton():void {
			if (!memory || !memory.length) return;
			var nonNull:Boolean = false;
			for each (var value:Value in memory)
				if (value != FixedValue.NULL) {
					nonNull = true;
					break;
				}
			if (!nonNull)
				return;
			
			var memoryButton:MenuButton = new GraphicButton(FlxG.width - 125, 10, _data_sprite, function _():void {
				upperLayer.add(new DMemory(memory));
			}, new Key("C"));
			upperLayer.add(memoryButton);
		}
		
		protected function makeInfoButton():void {
			var infoButton:MenuButton = new GraphicButton(FlxG.width - 45, 50, _info_sprite, function _():void {
				upperLayer.add(new DGoal(level));
			}, new Key("I"));
			upperLayer.add(infoButton);
		}
		
		protected function makeZoomButton():void {
			var zoomButton:MenuButton = new GraphicButton(90, 10, _zoom_sprite, function openList():void {
				listOpen = LIST_ZOOM;
				makeUI();
			}, new Key("PLUS"));
			upperLayer.add(zoomButton);
		}
		
		protected function makeZoomList():void {
			var zoomButtons:Vector.<MenuButton> = new Vector.<MenuButton>;
			for (var zoomLevel:int = 0; zoomLevel < ZOOMS.length; zoomLevel++)
				zoomButtons.push(new GraphicButton( -1, -1, ZOOMS[zoomLevel], function selectZoom(zoomLevel:int):void {
					FlxG.camera.scroll.x += (FlxG.width / 2) / zoom;
					FlxG.camera.scroll.y += (FlxG.height / 2) / zoom;
					
					zoom = Math.pow(2, -zoomLevel);
					
					FlxG.camera.scroll.x -= (FlxG.width / 2) / zoom;
					FlxG.camera.scroll.y -= (FlxG.height / 2) / zoom;
				}, HOTKEYS[zoomLevel]).setParam(zoomLevel).setSelected(Math.pow(2, -zoomLevel) == zoom));
			
			var zoomList:ButtonList = new ButtonList(90, 10, zoomButtons, function onListClose():void {
				if (listOpen == LIST_ZOOM)
					listOpen = LIST_NONE;
				makeUI();
			});
			zoomList.setSpacing(4);
			zoomList.justDie = true;
			upperLayer.add(zoomList);
		}
		
		protected function makeTestButtons():void {
			if (level.goal.randomizedMemory) {
				var randomButton:MenuButton = new GraphicButton(FlxG.width - 165, 10, _random_sprite, function _():void {
					initialMemory = level.goal.genMem();
					memory = initialMemory.slice();
				}, new Key("R"));
				upperLayer.add(randomButton);
			}
			
			if (level.goal.dynamicallyTested) {
				var kludge:LevelState = this;
				var testButton:MenuButton = new GraphicButton(FlxG.width - 85, 10, _test_sprite, function _():void {
					level.goal.runTest(kludge);
				}, new Key("T"));
				upperLayer.add(testButton);
			}
		}
		
		protected function makeModeButton():void {
			var modeButton:MenuButton = new GraphicButton(10, 10, MODE_SPRITES[mode], function openList():void {
				listOpen = LIST_MODES;
				makeUI();
			}, new Key("TAB"));
			upperLayer.add(modeButton);
		}
		
		protected function makeModeMenu():void {
			if (currentModule) {
				currentModule.exists = false;
				currentModule = null;
			}
			
			var modes:Array = [MODE_CONNECT, MODE_REMOVE];
			if (level.allowedModules.length)
				modes.push(MODE_MODULE);
			if (level.delay)
				modes.push(MODE_DELAY);
			
			var modeSelectButtons:Vector.<MenuButton> = new Vector.<MenuButton>;
			for each (var newMode:int in modes) {
				modeSelectButtons.push(new GraphicButton( -1, -1, MODE_SPRITES[newMode], function selectMode(newMode:int):void {
					mode = newMode;
				}, HOTKEYS[newMode]).setParam(newMode).setSelected(newMode == mode));
			}
			
			var modeList:ButtonList = new ButtonList(10, 10, modeSelectButtons, function onListClose():void {
				if (listOpen == LIST_MODES)
					listOpen = LIST_NONE;
				makeUI();
			});
			modeList.setSpacing(4);
			modeList.justDie = true;
			upperLayer.add(modeList);
		}
		
		protected function makeModuleCatButton():void {
			var listButton:GraphicButton = new GraphicButton(50, 10, _list_sprite, function openList():void {
				if (currentModule) {
					currentModule.exists = false;
					currentModule = null;
				}
				
				listOpen = LIST_CATEGORIES;
				makeUI();
			}, new Key("FIVE"));
			
			upperLayer.add(listButton);
		}
		
		protected function makeModuleCatList():void {
			//build a list of buttons for allowed modules/names
			var moduleButtons:Vector.<MenuButton> = new Vector.<MenuButton>;
			for each (var category:String in Module.ALL_CATEGORIES) {
				var allowed:Boolean = false;
				for each (var moduleType:Class in level.allowedModules)
					if (Module.getArchetype(moduleType).category == category) {
						allowed = true;
						break;
					}
				
				moduleButtons.push(new TextButton( -1, -1, category, function chooseCategory(category:String):void {
					listOpen = LIST_MODULES;
					moduleCategory = category;
					makeUI();
				}).setParam(category).setDisabled(!allowed));
			}
			
			//put 'em in a list
			moduleList = new ButtonList(50, 10, moduleButtons, function onListClose():void {
				if (listOpen == LIST_CATEGORIES)
					listOpen = LIST_NONE;
				makeUI();
			});
			moduleList.setSpacing(4);
			moduleList.justDie = true;
			upperLayer.add(moduleList);
		}
		
		protected function makeModuleList():void {
			var moduleType:Class, archetype:Module;
			
			var moduleTypes:Vector.<Class>  = new Vector.<Class>;
			for each (moduleType in level.allowedModules)
				if (Module.getArchetype(moduleType).category == moduleCategory)
					moduleTypes.push(moduleType);
			
			//build a list of buttons for allowed modules/names
			var moduleButtons:Vector.<MenuButton> = new Vector.<MenuButton>;
			moduleButtons.push(new TextButton( -1, -1, "<Back>", function goBack():void {
				listOpen = LIST_CATEGORIES;
				makeUI();
			}));
			
			for each (moduleType in moduleTypes) {
				moduleButtons.push(new TextButton( -1, -1, Module.getArchetype(moduleType).name, function chooseModule(moduleType:Class):void {
					archetype = Module.getArchetype(moduleType);
					if (archetype.configuration)
						currentModule = new moduleType( -1, -1, archetype.configuration.value);
					else
						currentModule = new moduleType( -1, -1);
					currentModule.initialize();
					
					modules.push(currentModule);
					displayModules.push(midLayer.add(new DModule(currentModule)));
					
					preserveModule = true;
				}).setParam(moduleType));
			}
			
			//put 'em in a list
			moduleList = new ButtonList(50, 10, moduleButtons, function onListClose():void {
				if (listOpen == LIST_MODULES)
					listOpen = LIST_NONE;
				makeUI();
			});
			moduleList.setSpacing(4);
			moduleList.justDie = true;
			upperLayer.add(moduleList);
			
			//make some sliders
			moduleSliders = new Vector.<ModuleSlider>;
			for (var i:int = 0; i < moduleTypes.length; i++ ) {
				moduleType = moduleTypes[i];
				archetype = Module.getArchetype(moduleType);
				if (archetype.configuration)
					moduleSliders.push(upperLayer.add(new ModuleSlider(moduleList.x + moduleList.width, moduleButtons[i+1], archetype)));
			}
		}
		
		override public function update():void {
			updateUI();
			super.update();
			checkBuildControls();
			checkMenuState();
			checkTime();
			forceScroll();
		}
		
		protected function updateUI():void {
			MenuButton.buttonClicked = false;
			UIChanged = false;
			preserveModule = false;
			
			var members:Array = upperLayer.members.slice(); //copy, to prevent updating new members
			for (var i:int = members.length - 1; i >= 0; i--) {
				var b:FlxBasic = members[i];
				if (b && b.exists && b.active) {
					b.update();
				}
			}
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
				if (MenuButton.buttonClicked)
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
			if (currentModule) {
				var mousePoint:Point = U.pointToGrid(U.mouseLoc);
				currentModule.x = mousePoint.x;
				currentModule.y = mousePoint.y;
				
				if (FlxG.mouse.justPressed() && !preserveModule) {
					if (MenuButton.buttonClicked) {
						currentModule.exists = false;
						currentModule = null;
					} else if (currentModule.validPosition)
						placeModule();
				}
			} else {
				if (FlxG.mouse.justPressed() && !MenuButton.buttonClicked)
					for each (var dModule:DModule in displayModules)
						if (dModule.module.exists && dModule.overlapsPoint(U.mouseFlxLoc)) {
							if (!dModule.module.configuration || !dModule.module.configurableInPlace || dModule.module.FIXED)
								break;
							
							var module:Module = dModule.module;
							var oldValue:int = module.configuration.value;
							var setValue:Function = function setValue(v:int):void {
								module.configuration.value = v;
								module.setByConfig();
								module.initialize();
							};
							var sliderbar:Sliderbar = new Sliderbar(dModule.x + dModule.width / 2, dModule.y + dModule.height / 2,
																	module.configuration.valueRange, setValue, module.configuration.value);
							sliderbar.setDieOnClickOutside(true, function onDie():void {
								var newValue:int = module.configuration.value;
								if (newValue != oldValue)
									new CustomAction(function setByConfig(newValue:int, oldValue:int):Boolean {
										module.configuration.value = newValue;
										module.setByConfig();
										module.initialize();
										return true;
									}, function setOldConfig(newValue:int, oldValue:int):Boolean {
										module.configuration.value = oldValue;
										module.setByConfig();
										module.initialize();
										return true;
									}, newValue, oldValue).execute();
							});
							upperLayer.add(sliderbar);
						}
				
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
			undoButton.exists = actionStack.length > 0;
			redoButton.exists = reactionStack.length > 0;
			if (mode == MODE_MODULE)
				checkModuleState();
		}
		
		protected function checkModuleState():void {
			if (currentModule && ControlSet.CANCEL_KEY.justPressed()) {
				currentModule.exists = false;
				currentModule = null;
			}
			
			var moduleSlider:ModuleSlider;
			if (moduleList && !moduleList.exists) {
				moduleList = null;
				moduleSliders = null;
				makeUI();
			} else if (moduleSliders) {
				moduleList.justDie = moduleList.closesOnClickOutside = true;
				for each (moduleSlider in moduleSliders)
					if (moduleSlider.overlapsPoint(FlxG.mouse)) {
						moduleList.justDie = moduleList.closesOnClickOutside = false;
						break;
					}
			}
		}
		
		protected function checkTime():void {
			if (editEnabled != time.moment == 0) {
				editEnabled = time.moment == 0;
				makeUI();
			}
			
			if (runningTest) {
				if (!time.moment && !displayTime.isPlaying)
					runningTest = false; //?
				else if (level.goal.stateValid(this))
					FlxG.switchState(new SuccessState);
				else if (time.moment >= level.goal.timeLimit)
					FlxG.switchState(new FailureState(level));
			}
		}
		
		//protected function get buttonMoused():MenuButton {
			//for each (var button:MenuButton in buttons)
				//if (button.exists && button.moused)
					//return button;
			//return null;
		//}
		
		
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
		
		
		
		private var buf:BitmapData;
		private var matrix:Matrix;
		private var boundRect:Rectangle;
		override public function draw():void {
			if (buf && buf.width != FlxG.width / zoom) {
				buf.dispose();
				buf = null;
				matrix = null;
				boundRect = null;
			}
			
			if (!buf) {
				var w:int = FlxG.width / zoom;
				var h:int = FlxG.height / zoom;
				buf = new BitmapData(FlxG.width / zoom, FlxG.height / zoom, true, FlxG.bgColor);
			}
			if (!boundRect)
				boundRect = new Rectangle(0, 0, buf.width, buf.height);
			buf.fillRect(boundRect, FlxG.bgColor);
			
			var realBuf:BitmapData = FlxG.camera.buffer;
			FlxG.camera.buffer = buf;
			
			FlxG.camera.width = buf.width;
			FlxG.camera.height = buf.height;
			
			super.draw();
			if (U.DEBUG && U.DEBUG_RENDER_COLLIDE)
				debugRenderCollision();
			
			if (!matrix) {
				matrix = new Matrix;
				matrix.scale(zoom, zoom);
			}
			realBuf.draw(buf, matrix);
			FlxG.camera.buffer = realBuf;
			
			upperLayer.draw();
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
		}
		
		protected function reset():void {
			for each (var module:Module in level.modules)
				if (module.FIXED)
					module.deregister();
			
			savedString = U.SAVE_DELIM + U.SAVE_DELIM + U.SAVE_DELIM + U.SAVE_DELIM;
			U.save.data[level.name] = savedString;
			load();
			//TODO: transform into a custom action!
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
			initLayers();
			displayWires = new Vector.<DWire>;
			displayModules = new Vector.<DModule>;
			
			wires = new Vector.<Wire>;
			modules = new Vector.<Module>;
			horizontalLines = new Dictionary;
			verticalLines = new Dictionary;
			carriersAtPoints = new Dictionary;
			
			time = new Time;
			
			
			
			var saveString:String = U.save.data[level.name];
			if (saveString) {
				var saveArray:Array = saveString.split(U.SAVE_DELIM + U.SAVE_DELIM);
				
				//load wires
				var wireStrings:String = saveArray[1];
				if (wireStrings.length)
					for each (var wireString:String in wireStrings.split(U.SAVE_DELIM))
						addWire(Wire.fromString(wireString), false);
				
				//load modules
				var moduleStrings:String = saveArray[0];
				if (moduleStrings.length)
					for each (var moduleString:String in moduleStrings.split(U.SAVE_DELIM))
						addModule(Module.fromString(moduleString), false);
				
				
				savedString = saveString;
			}
			
			for each (var module:Module in level.modules)
				addModule(module);
		}
		
		
		public function runTest():void {
			save();
			displayTime.startPlaying();
			runningTest = true;
		}
		
		protected const MODE_MODULE:int = 0;
		protected const MODE_CONNECT:int = 1;
		protected const MODE_REMOVE:int = 2;
		protected const MODE_DELAY:int = 3;
		
		protected const LIST_NONE:int = 0;
		protected const LIST_MODES:int = 1;
		protected const LIST_CATEGORIES:int = 2;
		protected const LIST_MODULES:int = 3;
		protected const LIST_ZOOM:int = 4;

		[Embed(source = "../lib/art/ui/lightbulb.png")] private const _module_sprite:Class;
		[Embed(source = "../lib/art/ui/wire.png")] private const _connect_sprite:Class;
		[Embed(source = "../lib/art/ui/remove.png")] private const _remove_sprite:Class;
		[Embed(source = "../lib/art/ui/delay.png")] private const _delay_sprite:Class;
		private const MODE_SPRITES:Array = [_module_sprite, _connect_sprite, _remove_sprite, _delay_sprite];
		[Embed(source = "../lib/art/ui/list.png")] private const _list_sprite:Class;
		private const HOTKEYS:Array = [new Key("THREE"), new Key("ONE"), new Key("TWO"), new Key("FOUR")];
		[Embed(source = "../lib/art/ui/undo.png")] private const _undo_sprite:Class;
		[Embed(source = "../lib/art/ui/redo.png")] private const _redo_sprite:Class;
		[Embed(source = "../lib/art/ui/up.png")] private const _back_sprite:Class;
		[Embed(source = "../lib/art/ui/floppy.png")] private const _save_sprite:Class;
		[Embed(source = "../lib/art/ui/yppolf.png")] private const _evas_sprite:Class;
		[Embed(source = "../lib/art/ui/maglass.png")] private const _zoom_sprite:Class;
		[Embed(source = "../lib/art/ui/x1b.png")] private const _z1_sprite:Class;
		[Embed(source = "../lib/art/ui/x1_2b.png")] private const _z2_sprite:Class;
		[Embed(source = "../lib/art/ui/x1_4b.png")] private const _z3_sprite:Class;
		[Embed(source = "../lib/art/ui/x1_8b.png")] private const _z4_sprite:Class;
		private const ZOOMS:Array = [_z1_sprite, _z2_sprite, _z3_sprite];
		[Embed(source = "../lib/art/ui/code.png")] private const _data_sprite:Class;
		[Embed(source = "../lib/art/ui/info.png")] private const _info_sprite:Class;
		[Embed(source = "../lib/art/ui/random.png")] private const _random_sprite:Class;
		[Embed(source = "../lib/art/ui/reset.png")] private const _reset_sprite:Class;
		[Embed(source = "../lib/art/ui/test.png")] private const _test_sprite:Class;
	}

}