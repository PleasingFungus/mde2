package LevelStates {
	import flash.utils.Dictionary;
	import flash.geom.Point;
	import org.flixel.*;
	import Actions.*;
	import Controls.*;
	import Displays.*;
	import Modules.Module;
	import Testing.Goals.GeneratedGoal;
	import UI.ButtonList;
	import UI.ButtonManager;
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
	import Menu.*;
	import Levels.Level;
	
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
		public var elapsed:Number;
		
		protected var displayWires:Vector.<DWire>;
		protected var displayModules:Vector.<DModule>;
		protected var mode:int = MODE_CONNECT;
		public var viewMode:int = VIEW_MODE_NORMAL;
		protected var listOpen:int;
		protected var UIChanged:Boolean;
		protected var editEnabled:Boolean = true;
		public var goalPage:int; //for dgoal; to persist between instances
		
		protected var UIEnableKey:Key = new Key("U");
		
		protected var undoButton:MenuButton;
		protected var redoButton:MenuButton;
		protected var loadButton:MenuButton;
		protected var resetButton:MenuButton;
		
		
		protected var displayTime:DTime;
		protected var displayDelay:DDelay;
		protected var preserveModule:Boolean;
		protected var testText:FlxText;
		protected var lastRunTime:Number;
		protected var runningDisplayTest:Boolean;
		
		protected var recentModules:Vector.<Class>;
		protected var moduleCategory:String;
		protected var moduleList:ButtonList;
		protected var moduleSliders:Vector.<ModuleSlider>;
		
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
			elapsed = 0;
			
			initialMemory = level.goal.genMem(0.5);
			
			load();
			recentModules = new Vector.<Class>;
			
			makeUI();
			upperLayer.add(new DGoal(level));
			
			FlxG.flash(0xff000000, MenuButton.FADE_TIME);
		}
		
		protected function initLayers():void {
			members = [];
			add(lowerLayer = new FlxGroup());
			add(midLayer = new FlxGroup());
		}
		
		private function addWire(w:Wire, fixed:Boolean = true):void {
			w.FIXED = fixed;
			if (!Wire.place(w))
				return;
			
			var displayWire:DWire = new DWire(w);
			midLayer.add(displayWire);
			displayWires.push(displayWire);
		}
		
		private function addModule(m:Module, fixed:Boolean = true):void {
			if (!m) return;
			
			if (!m.validPosition)
				return;
			
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
			new ButtonManager;
			UIChanged = true;
			addUIActives();
			makeViewButtons();
			
			if (!editEnabled) {
				if (currentModule) {
					currentModule.exists = false;
					currentModule = null;
				}
				
				makeViewLists();
				return;
			}
			
			makeEditButtons();
			makeViewLists();
			makeEditLists();
		}
		
		protected function addUIActives():void {
			upperLayer.add(new Scroller);
			upperLayer.add(new DCurrent(displayWires, displayModules));
			upperLayer.add(new DModuleInfo(displayModules));
			if (level.delay) {
				if (!displayDelay)
					midLayer.add(displayDelay = new DDelay(modules, displayModules));
				displayDelay.interactive = MODE_DELAY == mode;
			}
		}
		
		protected function makeViewButtons():void {
			makeDataButton();
			makeInfoButton();
			makeBackButton();
			if (editEnabled)
				upperLayer.add(displayTime = new DTime(FlxG.width / 2 - 50, 10))
			else {
				upperLayer.add(displayTime);
				makeEndTestButton();
			}
		}
		
		protected function makeViewLists():void {
			LIST_ZOOM == listOpen ? makeZoomList() : makeZoomButton();
			if (level.delay)
				LIST_VIEW_MODES == listOpen ? makeViewModeMenu() : makeViewModeButton()
		}
		
		protected function makeEditButtons():void {
			makeSaveButtons();
			makeUndoButtons();
			makeTestButtons();
			if (level.delay)
				makeClockButton();
		}
		
		protected function makeEditLists():void {
			LIST_MODES == listOpen ? makeModeMenu() : makeModeButton();
			if (mode == MODE_MODULE)
				switch (listOpen) {
					case LIST_MODULES: makeModuleList(); break;
					case LIST_CATEGORIES: makeModuleCatList(); break;
					case LIST_NONE: default: makeModuleCatButton(); break;
				}
		}
		
		
		protected function makeBackButton():void {
			var backButton:GraphicButton = new GraphicButton(FlxG.width - 45, 10, _back_sprite, function back():void {
				if (U.tuts.indexOf(level) != -1)
					FlxG.switchState(new TutorialMenu);
				else if (U.delayTuts.indexOf(level) != -1)
					FlxG.switchState(new DelayTutMenu);
				else
					FlxG.switchState(new LevelMenu);
			}, "Exit to menu");
			backButton.fades = true;
			upperLayer.add(backButton);
		}
		
		protected function makeSaveButtons():void {
			loadButton = new GraphicButton(90, 50, _success_load_sprite, loadFromSuccess, "Load last successful", new Key("S"));
			upperLayer.add(loadButton);
			
			resetButton = new GraphicButton(130, 50, _reset_sprite, reset, "Erase all placed parts");
			upperLayer.add(resetButton);
		}
		
		protected function makeUndoButtons():void {
			undoButton = new GraphicButton(10, 50, _undo_sprite, undo, "Undo", new Key("Z"));
			upperLayer.add(undoButton);
			
			redoButton = new GraphicButton(50, 50, _redo_sprite, redo, "Redo", new Key("Y"));
			upperLayer.add(redoButton);
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
			
			var memoryButton:MenuButton = new GraphicButton(50, 90, _data_sprite, function _():void {
				upperLayer.add(new DMemory(memory));
			}, "View contents of memory", new Key("M"));
			upperLayer.add(memoryButton);
		}
		
		protected function makeInfoButton():void {
			var infoButton:MenuButton = new GraphicButton(10, 90, _info_sprite, function _():void {
				upperLayer.add(new DGoal(level));
			}, "Level info", new Key("I"));
			upperLayer.add(infoButton);
		}
		
		protected function makeClockButton():void {
			upperLayer.add(new DClock(130, 90));
		}
		
		protected function makeZoomButton():void {
			var zoomButton:MenuButton = new GraphicButton(50, 10, _zoom_sprite, function openList():void {
				listOpen = LIST_ZOOM;
				makeUI();
			}, "Display zoom controls", new Key("O"));
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
					
					if (listOpen == LIST_ZOOM) {
						listOpen = LIST_NONE;
						makeUI();
					}
				}, "Set zoom to "+Math.pow(2, -zoomLevel), HOTKEYS[zoomLevel]).setParam(zoomLevel).setSelected(Math.pow(2, -zoomLevel) == zoom));
			
			var zoomList:ButtonList = new ButtonList(50, 10, zoomButtons, function onListClose():void {
				if (listOpen == LIST_ZOOM)
					listOpen = LIST_NONE;
				makeUI();
			});
			zoomList.setSpacing(4);
			upperLayer.add(zoomList);
		}
		
		protected function makeTestButtons():void {
			if (level.goal.randomizedMemory) {
				var randomButton:MenuButton = new GraphicButton(90, 90, _random_sprite, function _():void {
					initialMemory = level.goal.genMem();
					memory = initialMemory.slice();
					upperLayer.add(new DMemory(memory));
				}, "Generate new memory", new Key("R"));
				upperLayer.add(randomButton);
			}
			
			if (level.goal.dynamicallyTested) {
				var testButton:MenuButton = new GraphicButton(FlxG.width / 2 - 16, 40, _test_sprite, function _():void {
					level.goal.startRun();
					lastRunTime = elapsed;
				}, "Test your machine!", new Key("T"));
				upperLayer.add(testButton);
			}
		}
		
		protected function makeEndTestButton():void {
			var testButton:MenuButton = new GraphicButton(FlxG.width / 2 - 16, 40, _inv_test_sprite, finishDisplayTest, "Finish the test!", new Key("T"));
			upperLayer.add(testButton);
		}
		
		protected function makeModeButton():void {
			var modeButton:MenuButton = new GraphicButton(10, 10, MODE_SPRITES[mode], function openList():void {
				listOpen = LIST_MODES;
				makeUI();
			}, "Display list of edit modes", new Key("TAB"));
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
					if (MODE_DELAY == mode)
						viewMode = VIEW_MODE_DELAY;
					if (listOpen == LIST_MODES) {
						listOpen = LIST_NONE;
						makeUI();
					}
				}, "Enter "+MODE_NAMES[newMode]+" mode. "+MODE_DESCRIPTIONS[newMode], HOTKEYS[newMode]).setParam(newMode).setSelected(newMode == mode));
			}
			
			var modeList:ButtonList = new ButtonList(10, 10, modeSelectButtons, function onListClose():void {
				if (listOpen == LIST_MODES)
					listOpen = LIST_NONE;
				makeUI();
			});
			modeList.setSpacing(4);
			upperLayer.add(modeList);
		}
		
		protected function makeViewModeButton():void {
			var modeButton:MenuButton = new GraphicButton(90, 10, VIEW_MODE_SPRITES[viewMode], function openList():void {
				listOpen = LIST_VIEW_MODES;
				makeUI();
			}, "Display list of view modes", new Key("V"));
			upperLayer.add(modeButton);
		}
		
		protected function makeViewModeMenu():void {
			if (currentModule) {
				currentModule.exists = false;
				currentModule = null;
			}
			
			var modeSelectButtons:Vector.<MenuButton> = new Vector.<MenuButton>;
			for each (var newMode:int in [VIEW_MODE_NORMAL, VIEW_MODE_DELAY]) {
				modeSelectButtons.push(new GraphicButton( -1, -1, VIEW_MODE_SPRITES[newMode], function selectMode(newMode:int):void {
					viewMode = newMode;
					if (listOpen == LIST_VIEW_MODES) {
						listOpen = LIST_NONE;
						makeUI();
					}
				}, "Enter "+VIEW_MODE_NAMES[newMode]+" view mode").setParam(newMode).setSelected(newMode == viewMode));
			}
			
			var modeList:ButtonList = new ButtonList(90, 10, modeSelectButtons, function onListClose():void {
				if (listOpen == LIST_VIEW_MODES)
					listOpen = LIST_NONE;
				makeUI();
			});
			modeList.setSpacing(4);
			upperLayer.add(modeList);
		}
		
		protected function makeModuleCatButton():void {
			var listButton:GraphicButton = new GraphicButton(130, 10, _list_sprite, function openList():void {
				if (currentModule) {
					currentModule.exists = false;
					currentModule = null;
				}
				
				listOpen = LIST_CATEGORIES;
				makeUI();
			}, "Choose modules", new Key("FIVE"));
			
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
				}, "Choose "+category+" modules" /*TODO: replace with category description?*/).setParam(category).setDisabled(!allowed));
			}
			
			if (recentModules.length) {
				moduleButtons.push(new TextButton( -1, -1, "<Recent>").setDisabled(true));
				for each (moduleType in recentModules) {
					moduleButtons.push(new TextButton( -1, -1, Module.getArchetype(moduleType).name, function chooseModule(moduleType:Class):void {
						archetype = Module.getArchetype(moduleType);
						if (archetype.getConfiguration())
							currentModule = new moduleType( -1, -1, archetype.getConfiguration().value);
						else
							currentModule = new moduleType( -1, -1);
						currentModule.initialize();
						
						modules.push(currentModule);
						displayModules.push(midLayer.add(new DModule(currentModule)));
						addRecentModule(moduleType);
						
						preserveModule = true;
						
						if (listOpen == LIST_CATEGORIES) {
							listOpen = LIST_NONE;
							makeUI();
						}
					}, "").setParam(moduleType).setTooltipCallback(Module.getArchetype(moduleType).getDescription));
				}
			}
			
			//put 'em in a list
			moduleList = new ButtonList(130, 10, moduleButtons, function onListClose():void {
				if (listOpen == LIST_CATEGORIES)
					listOpen = LIST_NONE;
				makeUI();
			});
			moduleList.setSpacing(4);
			upperLayer.add(moduleList);
			
			moduleSliders = new Vector.<ModuleSlider>;
			for (var i:int = 0; i < recentModules.length; i++ ) {
				moduleType = recentModules[i];
				var archetype:Module = Module.getArchetype(moduleType);
				if (archetype.getConfiguration())
					moduleSliders.push(upperLayer.add(new ModuleSlider(moduleList.x + moduleList.width, moduleButtons[i+Module.ALL_CATEGORIES.length+1], archetype)));
			}
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
					if (archetype.getConfiguration())
						currentModule = new moduleType( -1, -1, archetype.getConfiguration().value);
					else
						currentModule = new moduleType( -1, -1);
					currentModule.initialize();
					
					modules.push(currentModule);
					displayModules.push(midLayer.add(new DModule(currentModule)));
					addRecentModule(moduleType);
					
					preserveModule = true;
						
					if (listOpen == LIST_MODULES) {
						listOpen = LIST_NONE;
						makeUI();
					}
				}, "").setParam(moduleType));
				if (Module.getArchetype(moduleType).getDescription() != null)
					moduleButtons[moduleButtons.length - 1].setTooltipCallback(Module.getArchetype(moduleType).getDescription);
			}
			
			//put 'em in a list
			moduleList = new ButtonList(130, 10, moduleButtons, function onListClose():void {
				if (listOpen == LIST_MODULES)
					listOpen = LIST_NONE;
				makeUI();
			});
			moduleList.setSpacing(4);
			upperLayer.add(moduleList);
			
			//make some sliders
			moduleSliders = new Vector.<ModuleSlider>;
			for (var i:int = 0; i < moduleTypes.length; i++ ) {
				moduleType = moduleTypes[i];
				archetype = Module.getArchetype(moduleType);
				if (archetype.getConfiguration())
					moduleSliders.push(upperLayer.add(new ModuleSlider(moduleList.x + moduleList.width, moduleButtons[i+1], archetype)));
			}
		}
		
		protected function addRecentModule(moduleType:Class):void {
			if (recentModules.indexOf(moduleType) >= 0)
				recentModules.splice(recentModules.indexOf(moduleType), 1);
			else if (recentModules.length >= 3)
				recentModules.pop();
			recentModules.unshift( moduleType);
		}
		
		override public function update():void {
			elapsed += FlxG.elapsed;
			
			if (level.goal.running) {
				checkTestControls();
				if (level.goal.running) {
					var delay:Number;
					if (level.goal is GeneratedGoal)
						delay = 2 / (level.goal as GeneratedGoal).testRuns;
					else
						delay = 0;
					if (elapsed - lastRunTime > delay)
						runTest();
					if (level.goal.running)
						return;
				}
			}
			
			updateUI();
			super.update();
			checkControls();
			checkMenuState();
			checkTime();
			forceScroll();
		}
		
		protected function updateUI():void {
			U.buttonManager.update();
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
		
		protected function checkControls():void {
			if (UIEnableKey.justPressed())
				upperLayer.visible = !upperLayer.visible;
			checkBuildControls();
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
			
			if (ControlSet.DELETE_KEY.pressed() && !currentWire && !currentModule) {
				destroyModules();
				destroyWires();
			}
		}
		
		protected function checkConnectControls():void {
			if (currentWire) {
				if (FlxG.mouse.pressed())
					currentWire.attemptPathTo(U.pointToGrid(U.mouseLoc), true)
				else {
					new CustomAction(Wire.place, Wire.remove, currentWire).execute();
					currentWire = null;
				}
			} else if (FlxG.mouse.justPressed() && !U.buttonManager.moused) {
				currentWire = new Wire(U.pointToGrid(U.mouseLoc))
				displayWires.push(midLayer.add(new DWire(currentWire)));
			}
			
			
			if (currentWire && ControlSet.CANCEL_KEY.justPressed()) {
				currentWire.exists = false;
				currentWire = null;
			}
		}
		
		protected function checkModuleControls():void {
			if (currentModule) {
				var mousePoint:Point = U.pointToGrid(U.mouseLoc);
				currentModule.x = mousePoint.x;
				currentModule.y = mousePoint.y;
				
				if (FlxG.mouse.justPressed() && !preserveModule) {
					if (U.buttonManager.moused) {
						currentModule.exists = false;
						currentModule = null;
					} else if (currentModule.validPosition)
						placeModule();
				}
			} else {
				if (FlxG.mouse.justPressed() && !U.buttonManager.moused) {
					if (FlxG.keys.pressed("SHIFT"))
						addEditSliderbar();
					else
						pickUpModule();
				}
			}
		}
		
		protected function pickUpModule():void {
			var mousedModule:Module = findMousedModule();
			if (mousedModule && !mousedModule.FIXED) {
				currentModule = mousedModule;
				new CustomAction(Module.remove, Module.place, mousedModule, new Point(mousedModule.x, mousedModule.y)).execute();
				mousedModule.exists = true;
			}
		}
		
		protected function addEditSliderbar():void {
			/*var module:Module = findMousedModule();
			if (!module || module.FIXED || !module.getConfiguration() || !module.configurableInPlace)
				return;
			
			var oldValue:int = module.getConfiguration().value;
			var setValue:Function = function setValue(v:int):void {
				module.getConfiguration().value = v;
				module.setByConfig();
				module.initialize();
			};
			var sliderbar:Sliderbar = new Sliderbar(dModule.x + dModule.width / 2, dModule.y + dModule.height / 2,
													module.getConfiguration().valueRange, setValue, module.getConfiguration().value);
			sliderbar.setDieOnClickOutside(true, function onDie():void {
				var newValue:int = module.getConfiguration().value;
				if (newValue != oldValue)
					new CustomAction(function setByConfig(newValue:int, oldValue:int):Boolean {
						module.getConfiguration().value = newValue;
						module.setByConfig();
						module.initialize();
						return true;
					}, function setOldConfig(newValue:int, oldValue:int):Boolean {
						module.getConfiguration().value = oldValue;
						module.setByConfig();
						module.initialize();
						return true;
					}, newValue, oldValue).execute();
			});
			upperLayer.add(sliderbar);*/
		}
		
		protected function placeModule():void {
			new CustomAction(Module.place, Module.remove, currentModule, new Point(currentModule.x, currentModule.y)).execute();
			currentModule = null;
		}
		
		private function destroyModules():void {
			var mousedModule:Module = findMousedModule();
			if (mousedModule && !mousedModule.FIXED)
				new CustomAction(Module.remove, Module.place, mousedModule).execute();
		}
		
		public function findMousedModule():Module {
			if (U.buttonManager.moused)
				return null;
			
			for each (var dModule:DModule in displayModules)
				if (dModule.module.exists && dModule.module.deployed && dModule.overlapsPoint(U.mouseFlxLoc))
					return dModule.module;
			return null;
		}
		
		protected function checkRemoveControls():void {
			if (FlxG.mouse.pressed()) {
				destroyModules();
				destroyWires();
			}
		}
		
		protected function checkMenuState():void {
			undoButton.setExists(canUndo());
			redoButton.setExists(canRedo());
			if (loadButton) {
				var successSave:String = findSuccessSave();
				loadButton.setExists(successSave != savedString && successSave != null);
				resetButton.setExists(savedString && savedString != RESET_SAVE);
			}
			
			checkCursorState();
			
			if (mode == MODE_MODULE)
				checkModuleState();
		}
		
		protected var cursorGraphic:Class;
		protected var wasHidden:Boolean;
		protected function checkCursorState():void {
			var newGraphic:Class = null;
			var offsetX:int = 0;
			var offsetY:int = 0;
			var hide:Boolean;
			
			if (listOpen == LIST_NONE && !time.moment)
				switch (mode) {
					case MODE_CONNECT:
						if (!U.buttonManager.moused && !findMousedModule())
							newGraphic = _pen_cursor;
						break;
					case MODE_REMOVE:
						if (!U.buttonManager.moused) {
							newGraphic = _remove_cursor;
							offsetX = offsetY = -14;
						}
						break;
					case MODE_MODULE:
						if (currentModule) {
							hide = true;
							break;
						}
						
						var mousedModule:Module = findMousedModule();
						if (mousedModule && !mousedModule.FIXED) {
							newGraphic = _grab_cursor;
							offsetX = -4;
							offsetY = -3;
						}
						
						break;
					case MODE_DELAY:
						if (findMousedModule()) {
							newGraphic = _delay_cursor
							offsetX = -9;
							offsetY = -14;
						}
						break;
				}
			
			if (hide) {
				FlxG.mouse.hide();
				wasHidden = true;
			} else if (wasHidden) {
				FlxG.mouse.show(cursorGraphic, 1, offsetX, offsetY);
				wasHidden = false;
			}
			if (cursorGraphic != newGraphic) {
				FlxG.mouse.load(newGraphic, 1, offsetX, offsetY);
				cursorGraphic = newGraphic;
			}
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
				moduleList.closesOnClickOutside = true;
				for each (moduleSlider in moduleSliders)
					if (moduleSlider.overlapsPoint(FlxG.mouse)) {
						moduleList.closesOnClickOutside = false;
						break;
					}
			}
		}
		
		protected function checkTime():void {
			var editShouldBeEnabled:Boolean = time.moment == 0 && !runningDisplayTest;
			if (editShouldBeEnabled != editEnabled) {
				editEnabled = editShouldBeEnabled;
				makeUI();
			}
			
			if (runningDisplayTest && (level.goal.stateValid(this) || time.moment >= level.goal.timeLimit))
				finishDisplayTest();
		}
		
		protected function finishDisplayTest():void {
			runningDisplayTest = false;
			
			if (!level.goal.succeeded) {
				FlxG.fade(0xff000000, MenuButton.FADE_TIME*2, function switchStates():void { 
					FlxG.switchState(new FailureState(level));
				});
				return;
			}
			
			U.save.data[level.name + SUCCESS_SUFFIX] = genSaveString();
			
			if (level == U.tuts[0])
				U.updateTutState(U.TUT_BEAT_TUT_1);
			else if (level == U.tuts[1])
				U.updateTutState(U.TUT_BEAT_TUT_2);
			
			FlxG.fade(0xff000000, MenuButton.FADE_TIME*2, function switchStates():void { 
				FlxG.switchState(new SuccessState(level));
			});
		}
		
		//protected function get buttonMoused():MenuButton {
			//for each (var button:MenuButton in buttons)
				//if (button.exists && button.moused)
					//return button;
			//return null;
		//}
		
		
		private function destroyWires():void {
			if (U.buttonManager.moused)
				return;
			
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
		
		public function objTypeAtPoint(p:Point):Class {
			var contents:* = carriersAtPoints[p.x + U.COORD_DELIM + p.y];
			if (!contents)
				return null;
			if (contents is Module)
				return Module;
			return Vector;
		}
		
		public function setPointContents(p:Point, module:Module):void {
			carriersAtPoints[p.x + U.COORD_DELIM + p.y] = module;
		}
		
		public function moduleContentsAtPoint(p:Point):Module {
			return carriersAtPoints[p.x + U.COORD_DELIM + p.y];
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
			
			if (level.goal.running)
				drawTestText();
			else if (upperLayer.exists && upperLayer.visible)
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
		
		private function canUndo():Boolean {
			return actionStack.length > 0 && !currentWire && !currentModule;
		}
		
		private function canRedo():Boolean {
			return reactionStack.length > 0 && !currentWire && !currentModule;
		}
		
		
		private function undo():Action {
			if (!canUndo())
				return null;
			return actionStack.pop().revert();
		}
		
		private function redo():Action {
			if (!canRedo())
				return null;
			return reactionStack.pop().execute();
		}
		
		public function save():void {
			savedString = genSaveString();
			U.save.data[level.name] = savedString;
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
			
			if (level.delay)
				saveString += time.clockPeriod + U.SAVE_DELIM;
			
			return saveString;
		}
		
		
		protected function load(saveString:String = null):void {
			initLayers();
			displayWires = new Vector.<DWire>;
			displayModules = new Vector.<DModule>;
			
			wires = new Vector.<Wire>;
			modules = new Vector.<Module>;
			horizontalLines = new Dictionary;
			verticalLines = new Dictionary;
			carriersAtPoints = new Dictionary;
			
			time = new Time;
			
			
			if (saveString == null)
				saveString = U.save.data[level.name];
			if (saveString == null)
				saveString = findSuccessSave();
			if (saveString) {
				var saveArray:Array = saveString.split(U.SAVE_DELIM + U.SAVE_DELIM);
				
				//ordering is key
				//misc info first
				var miscStringsString:String = saveArray[2];
				if (miscStringsString.length) {
					var miscStrings:Array = miscStringsString.split(U.SAVE_DELIM);
					if (level.delay)
						time.clockPeriod = int(miscStrings[0]);
				}
				
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
			
			for each (var module:Module in level.modules) {
				module.cleanup();
				addModule(module);
			}
		}
		
		protected function loadFromSuccess():void {
			var successSave:String = findSuccessSave();
			if (successSave == savedString || successSave == null)
				return;
			
			new CustomAction(function loadSuccess(success:String = null, old:String = null):Boolean { load(success); reactionStack = new Vector.<Action>; return true; },
							 function loadOld(success:String = null, old:String = null):void { load(old); },
							 successSave, savedString).execute();
		}
		
		protected function findSuccessSave():String {
			var personalSuccess:String = U.save.data[level.name + SUCCESS_SUFFIX];
			if (personalSuccess)
				return personalSuccess;
			for each (var predecessor:Level in level.predecessors) {
				var predecessorSuccess:String = U.save.data[predecessor.name + SUCCESS_SUFFIX];
				if (predecessorSuccess)
					return predecessorSuccess;
			}
			return null;
		}
		
		protected function reset():void {
			if (RESET_SAVE == savedString || savedString == null)
				return;
			
			new CustomAction(function loadSuccess(old:String = null):Boolean { load(RESET_SAVE); reactionStack = new Vector.<Action>; return true; },
							 function loadOld(old:String = null):void { load(old); },
							 savedString).execute();
		}
		
		
		protected function runTest():void {
			level.goal.runTestStep(this);
			lastRunTime = elapsed;
			if (!level.goal.running) {
				if (level.goal.succeeded)
					C.log("Success!");
				else
					C.log("Failure!");
				runDisplayTest();
			}
		}
		
		protected function checkTestControls():void {
			if (FlxG.mouse.justPressed() || ControlSet.CANCEL_KEY.justPressed())
				level.goal.endRun();
		}
		
		protected function drawTestText():void {
			if (!testText)
				testText = U.LABEL_FONT.configureFlxText(new FlxText(0, FlxG.height / 2, FlxG.width, " "), 0x000000, 'center');
			testText.text = "TESTING" + level.goal.getProgress() + "\nClick or " + ControlSet.CANCEL_KEY.key + " to cancel";
			testText.y = FlxG.height / 2 - testText.height / 2;
			testText.draw();
		}
		
		
		protected function runDisplayTest():void {
			time.reset();
			displayTime.startPlaying();
			runningDisplayTest = true;
		}
		
		override public function destroy():void {
			super.destroy();
			
			if (cursorGraphic)
				FlxG.mouse.load();
			if (wasHidden)
				FlxG.mouse.show();
			U.buttonManager.destroy();
		}
		
		protected const MODE_MODULE:int = 0;
		protected const MODE_CONNECT:int = 1;
		protected const MODE_REMOVE:int = 2;
		protected const MODE_DELAY:int = 3;
		
		public const VIEW_MODE_NORMAL:int = 0;
		public const VIEW_MODE_DELAY:int = 1;
		
		protected const LIST_NONE:int = 0;
		protected const LIST_MODES:int = 1;
		protected const LIST_CATEGORIES:int = 2;
		protected const LIST_MODULES:int = 3;
		protected const LIST_ZOOM:int = 4;
		protected const LIST_VIEW_MODES:int = 5;
		
		protected const SUCCESS_SUFFIX:String = '-succ';
		protected const RESET_SAVE:String = U.SAVE_DELIM + U.SAVE_DELIM + U.SAVE_DELIM + U.SAVE_DELIM;

		[Embed(source = "../../lib/art/ui/module.png")] private const _module_sprite:Class;
		[Embed(source = "../../lib/art/ui/wire.png")] private const _connect_sprite:Class;
		[Embed(source = "../../lib/art/ui/remove.png")] private const _remove_sprite:Class;
		[Embed(source = "../../lib/art/ui/delay.png")] private const _delay_sprite:Class;
		private const MODE_SPRITES:Array = [_module_sprite, _connect_sprite, _remove_sprite, _delay_sprite];
		private const HOTKEYS:Array = [new Key("THREE"), new Key("ONE"), new Key("TWO"), new Key("FOUR")];
		private const MODE_NAMES:Array = ["module", "wire", "delete", "delay"];
		private const MODE_DESCRIPTIONS:Array = ["Select modules to place from the drop-down menu; click to move or press DELETE to delete.",
												 "Click and drag to place wires; place DELETE to delete them.",
												 "Click to delete modules and wires.",
												 "Mouse to see delay starting from modules; click to see delays along paths."];
		
		[Embed(source = "../../lib/art/ui/eye.png")] private const _view_normal_sprite:Class;
		[Embed(source = "../../lib/art/ui/eye_delayb.png")] private const _view_delay_sprite:Class;
		private const VIEW_MODE_SPRITES:Array = [_view_normal_sprite, _view_delay_sprite];
		private const VIEW_MODE_NAMES:Array = ["normal", "delay"];
		
		[Embed(source = "../../lib/art/ui/list.png")] private const _list_sprite:Class;
		[Embed(source = "../../lib/art/ui/undo.png")] private const _undo_sprite:Class;
		[Embed(source = "../../lib/art/ui/redo.png")] private const _redo_sprite:Class;
		[Embed(source = "../../lib/art/ui/up.png")] private const _back_sprite:Class;
		[Embed(source = "../../lib/art/ui/floppy.png")] private const _save_sprite:Class;
		[Embed(source = "../../lib/art/ui/yppolf.png")] private const _evas_sprite:Class;
		[Embed(source = "../../lib/art/ui/floppy-trophy.png")] private const _success_load_sprite:Class;
		
		[Embed(source = "../../lib/art/ui/maglass.png")] private const _zoom_sprite:Class;
		[Embed(source = "../../lib/art/ui/x1b.png")] private const _z1_sprite:Class;
		[Embed(source = "../../lib/art/ui/x1_2b.png")] private const _z2_sprite:Class;
		[Embed(source = "../../lib/art/ui/x1_4b.png")] private const _z3_sprite:Class;
		[Embed(source = "../../lib/art/ui/x1_8b.png")] private const _z4_sprite:Class;
		private const ZOOMS:Array = [_z1_sprite, _z2_sprite, _z3_sprite];
		
		[Embed(source = "../../lib/art/ui/code.png")] private const _data_sprite:Class;
		[Embed(source = "../../lib/art/ui/info.png")] private const _info_sprite:Class;
		[Embed(source = "../../lib/art/ui/random.png")] private const _random_sprite:Class;
		[Embed(source = "../../lib/art/ui/reset.png")] private const _reset_sprite:Class;
		[Embed(source = "../../lib/art/ui/test.png")] private const _test_sprite:Class;
		[Embed(source = "../../lib/art/ui/tset.png")] private const _inv_test_sprite:Class;
		
		[Embed(source = "../../lib/art/ui/pen.png")] private const _pen_cursor:Class;
		[Embed(source = "../../lib/art/ui/grabby_cursor.png")] private const _grab_cursor:Class;
		[Embed(source = "../../lib/art/ui/remove_cursor.png")] private const _remove_cursor:Class;
		[Embed(source = "../../lib/art/ui/delay_cursor.png")] private const _delay_cursor:Class;
	}

}