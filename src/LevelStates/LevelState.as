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
		
		private var savedString:String;
		
		public var lowerLayer:FlxGroup;
		public var midLayer:FlxGroup;
		public var upperLayer:FlxGroup;
		public var elapsed:Number;
		
		private var displayWires:Vector.<DWire>;
		private var displayModules:Vector.<DModule>;
		public var viewMode:int = VIEW_MODE_NORMAL;
		private var listOpen:int;
		private var UIChanged:Boolean;
		private var editEnabled:Boolean = true;
		public var goalPage:int; //for dgoal; to persist between instances
		
		private var UIEnableKey:Key = new Key("U");
		
		private var undoButton:MenuButton;
		private var redoButton:MenuButton;
		private var loadButton:MenuButton;
		private var resetButton:MenuButton;
		
		
		private var displayTime:DTime;
		private var displayDelay:DDelay;
		private var preserveModule:Boolean;
		private var testText:FlxText;
		private var testBG:FlxSprite;
		private var lastRunTime:Number;
		private var runningDisplayTest:Boolean;
		
		private var recentModules:Vector.<Class>;
		private var moduleCategory:String;
		private var moduleList:ButtonList;
		private var moduleSliders:Vector.<ModuleSlider>;
		
		public var actionStack:Vector.<Action>;
		public var reactionStack:Vector.<Action>;
		private var currentWire:Wire;
		private var currentModule:Module;
		private var selectionArea:SelectionBox;
		
		public var time:Time;
		public var grid:Grid;
		public var wires:Vector.<Wire>;
		public var modules:Vector.<Module>;
		public var memory:Vector.<Value>;
		public var initialMemory:Vector.<Value>;
		
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
			elapsed = 0;
			
			initialMemory = level.goal.genMem();
			
			load();
			level.setLast();
			recentModules = new Vector.<Class>;
			
			makeUI();
			upperLayer.add(new DGoal(level));
			
			FlxG.flash(0xff000000, MenuButton.FADE_TIME);
		}
		
		private function initLayers():void {
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
		
		private function makeUI():void {
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
		
		private function addUIActives():void {
			upperLayer.add(new Scroller);
			upperLayer.add(new DCurrent(displayWires, displayModules));
			upperLayer.add(new DModuleInfo(displayModules));
			if (level.delay) {
				if (!displayDelay)
					midLayer.add(displayDelay = new DDelay(modules, displayModules));
				displayDelay.interactive = false; //TODO
			}
		}
		
		private function makeViewButtons():void {
			makeDataButton();
			makeInfoButton();
			makeBackButton();
			if (editEnabled)
				upperLayer.add(displayTime = new DTime(FlxG.width / 2 - 50, 10))
			else {
				upperLayer.add(displayTime);
				if (runningDisplayTest)
					makeEndTestButton();
			}
		}
		
		private function makeViewLists():void {
			LIST_ZOOM == listOpen ? makeZoomList() : makeZoomButton();
			if (level.delay)
				LIST_VIEW_MODES == listOpen ? makeViewModeMenu() : makeViewModeButton()
		}
		
		private function makeEditButtons():void {
			makeSaveButtons();
			makeUndoButtons();
			makeTestButtons();
			if (level.delay)
				makeClockButton();
		}
		
		private function makeEditLists():void {
			if (level.allowedModules.length)
				switch (listOpen) {
					case LIST_MODULES: makeModuleList(); break;
					case LIST_CATEGORIES: makeModuleCatList(); break;
					case LIST_NONE: default: makeModuleCatButton(); break;
				}
		}
		
		
		private function makeBackButton():void {
			var backButton:GraphicButton = new GraphicButton(FlxG.width - 45, 10, _back_sprite, function back():void {
				FlxG.switchState(new MenuState);
			}, "Exit to menu");
			backButton.fades = true;
			upperLayer.add(backButton);
		}
		
		private function makeSaveButtons():void {
			loadButton = new GraphicButton(90, 50, _success_load_sprite, loadFromSuccess, "Load last successful", new Key("S"));
			upperLayer.add(loadButton);
			
			resetButton = new GraphicButton(130, 50, _reset_sprite, reset, "Erase all placed parts");
			upperLayer.add(resetButton);
		}
		
		private function makeUndoButtons():void {
			undoButton = new GraphicButton(10, 50, _undo_sprite, undo, "Undo", new Key("Z"));
			upperLayer.add(undoButton);
			
			redoButton = new GraphicButton(50, 50, _redo_sprite, redo, "Redo", new Key("Y"));
			upperLayer.add(redoButton);
		}
		
		private function makeDataButton():void {			
			var memoryButton:MenuButton = new GraphicButton(50, 90, _data_sprite, function _():void {
				upperLayer.add(new DMemory(memory, level.goal.genExpectedMem()));
			}, "View contents of memory", new Key("E"));
			upperLayer.add(memoryButton);
		}
		
		private function makeInfoButton():void {
			var infoButton:MenuButton = new GraphicButton(10, 90, _info_sprite, function _():void {
				upperLayer.add(new DGoal(level));
			}, "Level info", new Key("I"));
			upperLayer.add(infoButton);
		}
		
		private function makeClockButton():void {
			upperLayer.add(new DClock(130, 90));
		}
		
		private function makeZoomButton():void {
			var zoomButton:MenuButton = new GraphicButton(50, 10, _zoom_sprite, function openList():void {
				listOpen = LIST_ZOOM;
				makeUI();
			}, "Display zoom controls", new Key("O"));
			upperLayer.add(zoomButton);
		}
		
		private function makeZoomList():void {
			var zoomButtons:Vector.<MenuButton> = new Vector.<MenuButton>;
			for (var zoomLevel:int = 0; zoomLevel < ZOOMS.length; zoomLevel++)
				zoomButtons.push(new GraphicButton( -1, -1, ZOOMS[zoomLevel], function selectZoom(zoomLevel:int):void {
					FlxG.camera.scroll.x += (FlxG.width / 2) / U.zoom;
					FlxG.camera.scroll.y += (FlxG.height / 2) / U.zoom;
					
					U.zoom = Math.pow(2, -zoomLevel);
					
					FlxG.camera.scroll.x -= (FlxG.width / 2) / U.zoom;
					FlxG.camera.scroll.y -= (FlxG.height / 2) / U.zoom;
					
					if (listOpen == LIST_ZOOM) {
						listOpen = LIST_NONE;
						makeUI();
					}
				}, "Set zoom to "+Math.pow(2, -zoomLevel), ControlSet.NUMBER_HOTKEYS[zoomLevel+1]).setParam(zoomLevel).setSelected(Math.pow(2, -zoomLevel) == U.zoom));
			
			var zoomList:ButtonList = new ButtonList(45, 5, zoomButtons, function onListClose():void {
				if (listOpen == LIST_ZOOM)
					listOpen = LIST_NONE;
				makeUI();
			});
			zoomList.setSpacing(4);
			upperLayer.add(zoomList);
		}
		
		private function makeTestButtons():void {
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
		
		private function makeEndTestButton():void {
			var testButton:MenuButton = new GraphicButton(FlxG.width / 2 - 16, 40, level.goal.succeeded ? _test_success_sprite : _test_failure_sprite,
														  finishDisplayTest, "Finish the test!", new Key("T"));
			upperLayer.add(testButton);
		}
		
		private function makeViewModeButton():void {
			var modeButton:MenuButton = new GraphicButton(90, 10, VIEW_MODE_SPRITES[viewMode], function openList():void {
				listOpen = LIST_VIEW_MODES;
				makeUI();
			}, "Display list of view modes", new Key("Q"));
			upperLayer.add(modeButton);
		}
		
		private function makeViewModeMenu():void {
			if (currentModule) {
				currentModule.exists = false;
				currentModule = null;
			}
			
			var modeSelectButtons:Vector.<MenuButton> = new Vector.<MenuButton>;
			for each (var newMode:int in [VIEW_MODE_NORMAL, VIEW_MODE_DELAY]) {
				modeSelectButtons.push(new GraphicButton( -1, -1, VIEW_MODE_SPRITES[newMode], function selectMode(newMode:int):void {
					viewMode = newMode;
					if (LIST_VIEW_MODES == listOpen ) {
						listOpen = LIST_NONE;
						makeUI();
					}
				}, "Enter "+VIEW_MODE_NAMES[newMode]+" view mode", ControlSet.NUMBER_HOTKEYS[newMode+1]).setParam(newMode).setSelected(newMode == viewMode));
			}
			
			var modeList:ButtonList = new ButtonList(85, 5, modeSelectButtons, function onListClose():void {
				if (listOpen == LIST_VIEW_MODES)
					listOpen = LIST_NONE;
				makeUI();
			});
			modeList.setSpacing(4);
			upperLayer.add(modeList);
		}
		
		private function makeModuleCatButton():void {
			var listButton:GraphicButton = new GraphicButton(10, 10, _list_sprite, function openList():void {
				if (currentModule) {
					currentModule.exists = false;
					currentModule = null;
				}
				
				listOpen = LIST_CATEGORIES;
				makeUI();
			}, "Choose modules", new Key("FIVE"));
			
			upperLayer.add(listButton);
		}
		
		private function makeModuleCatList():void {
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
					}, "").setParam(moduleType).setTooltipCallback(Module.getArchetype(moduleType).getFullDescription));
				}
			}
			
			//put 'em in a list
			moduleList = new ButtonList(5, 5, moduleButtons, function onListClose():void {
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
		
		private function makeModuleList():void {
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
				if (Module.getArchetype(moduleType).getFullDescription() != null)
					moduleButtons[moduleButtons.length - 1].setTooltipCallback(Module.getArchetype(moduleType).getFullDescription);
			}
			
			//put 'em in a list
			moduleList = new ButtonList(5, 5, moduleButtons, function onListClose():void {
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
		
		private function addRecentModule(moduleType:Class):void {
			if (recentModules.indexOf(moduleType) >= 0)
				recentModules.splice(recentModules.indexOf(moduleType), 1);
			else if (recentModules.length >= 3)
				recentModules.pop();
			recentModules.unshift( moduleType);
		}
		
		override public function update():void {
			elapsed += FlxG.elapsed;
			
			if (FlxG.camera.fading)
				return;
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
			checkDDelay();
			forceScroll();
		}
		
		private function updateUI():void {
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
		
		private function checkControls():void {
			checkBuildControls();
			if (U.DEBUG && UIEnableKey.justPressed())
				upperLayer.visible = !upperLayer.visible
		}
		
		private function checkBuildControls():void {
			if (time.moment || runningDisplayTest)
				return; //no fucking around when shit is running!
			
			if (selectionArea) {
				if (!selectionArea.exists) {
					//TODO
					selectionArea = null;
				}
			} else if (currentModule)
				checkModuleControls();
			else if (currentWire)
				checkWireControls();
			else {
				if (FlxG.mouse.justPressed() && !U.buttonManager.moused) {
					if (ControlSet.DRAG_MODIFY_KEY.pressed())
						midLayer.add(selectionArea = new SelectionBox(displayWires, displayModules));
					else if (findMousedModule()) {
						if (ControlSet.CLICK_MODIFY_KEY.pressed())
							addEditSliderbar();
						else
							pickUpModule();
					} else {
						currentWire = new Wire(U.pointToGrid(U.mouseLoc))
						displayWires.push(midLayer.add(new DWire(currentWire)));
					}
				}
				
				if (ControlSet.DELETE_KEY.justPressed()) {
					destroyModules();
					destroyWires();
				}
				
				if (ControlSet.PASTE_KEY.justPressed() && !U.buttonManager.moused && U.clipboard) {
					var pastedBloc:DBloc = DBloc.fromString(U.clipboard, level.allowedModules);
					pastedBloc.extendDisplays(displayWires, displayModules);
					midLayer.add(pastedBloc);
				}
			}
		}
		
		private function checkModuleControls():void {
			if (ControlSet.CANCEL_KEY.justPressed()) {
				currentModule.exists = false;
				currentModule = null;
				return;
			}
			
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
		}
		
		private function checkWireControls():void {
			if (ControlSet.CANCEL_KEY.justPressed()) {
				currentWire.exists = false;
				currentWire = null;
			} else if (FlxG.mouse.pressed())
				currentWire.attemptPathTo(U.pointToGrid(U.mouseLoc), true)
			else {
				new CustomAction(Wire.place, Wire.remove, currentWire).execute();
				currentWire = null;
			}
		}
		
		private function pickUpModule():void {
			var mousedModule:Module = findMousedModule();
			if (mousedModule && !mousedModule.FIXED) {
				currentModule = mousedModule;
				new CustomAction(Module.remove, Module.place, mousedModule, new Point(mousedModule.x, mousedModule.y)).execute();
				mousedModule.exists = true;
			}
		}
		
		private function addEditSliderbar():void {
			var module:Module = findMousedModule();
			if (!module || module.FIXED || !module.getConfiguration() || !module.configurableInPlace)
				return;
			
			for each (var displayModule:DModule in displayModules)
				if (displayModule.module == module) {
					upperLayer.add(new InPlaceSlider(displayModule));
					break
				}
		}
		
		private function placeModule():void {
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
		
		
		
		private function checkMenuState():void {
			undoButton.setExists(canUndo());
			redoButton.setExists(canRedo());
			if (loadButton) {
				var successSave:String = findSuccessSave();
				loadButton.setExists(successSave != savedString && successSave != null);
				resetButton.setExists(savedString && savedString != RESET_SAVE);
			}
			
			checkCursorState();
			
			checkModuleListState();
		}
		
		private var cursorGraphic:Class;
		private var wasHidden:Boolean;
		private function checkCursorState():void {
			var newGraphic:Class = null;
			var offsetX:int = 0;
			var offsetY:int = 0;
			var hide:Boolean;
			
			if (listOpen == LIST_NONE && !time.moment && !U.buttonManager.moused) {
				if (currentModule)
					hide = true;
				else {
					var mousedModule:Module = findMousedModule();
					if (!mousedModule)
						newGraphic = _pen_cursor;
					else if (!mousedModule.FIXED) {
						if (ControlSet.CLICK_MODIFY_KEY.pressed() && mousedModule.configurableInPlace && mousedModule.getConfiguration()) {
							newGraphic = _wrench_cursor;
							offsetX = offsetY = -3;
						} else {
							newGraphic = _grab_cursor;
							offsetX = -4;
							offsetY = -3;
						}
					}
				}
			}
			
			if (hide || !upperLayer.visible) {
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
		
		private function checkModuleListState():void {
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
		
		private function checkTime():void {
			var editShouldBeEnabled:Boolean = time.moment == 0 && !runningDisplayTest;
			if (editShouldBeEnabled != editEnabled) {
				editEnabled = editShouldBeEnabled;
				makeUI();
			}
			
			if (runningDisplayTest && (level.goal.stateValid(this) || time.moment >= level.goal.timeLimit))
				finishDisplayTest();
		}
		
		private function checkDDelay():void {
			if (displayDelay && !displayDelay.exists)
				midLayer.add(displayDelay = new DDelay(modules, displayModules));
		}
		
		private function finishDisplayTest():void {
			runningDisplayTest = false;
			
			if (!level.goal.succeeded) {
				U.state.time.reset();
				runningDisplayTest = false;
				makeUI();
				return;
			}
			
			level.successSave = genSaveString();
			
			if (level == U.levels[0])
				U.updateTutState(U.TUT_BEAT_TUT_1);
			else if (level == U.levels[1])
				U.updateTutState(U.TUT_BEAT_TUT_2);
			
			FlxG.fade(0xff000000, MenuButton.FADE_TIME*2, function switchStates():void { 
				FlxG.switchState(new SuccessState(level));
			});
		}
		
		//private function get buttonMoused():MenuButton {
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
		
		
		private function forceScroll(group:FlxGroup = null):void {
			group = group ? group : upperLayer;
			for each (var basic:FlxBasic in group.members)
				if (basic is FlxObject) {
					var obj:FlxObject = basic as FlxObject;
					obj.scrollFactor.x = obj.scrollFactor.y = 0;
				} else if (basic is FlxGroup)
					forceScroll(basic as FlxGroup);
		}
		
		
		
		private var buf:BitmapData;
		private var matrix:Matrix;
		private var boundRect:Rectangle;
		override public function draw():void {
			if (buf && buf.width != FlxG.width / U.zoom) {
				buf.dispose();
				buf = null;
				matrix = null;
				boundRect = null;
			}
			
			if (!buf) {
				var w:int = FlxG.width / U.zoom;
				var h:int = FlxG.height / U.zoom;
				buf = new BitmapData(FlxG.width / U.zoom, FlxG.height / U.zoom, true, FlxG.bgColor);
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
				matrix.scale(U.zoom, U.zoom);
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
		private var debugPoint:FlxSprite;
		private function debugRenderCollision():void {
			if (!debugLineH) {
				debugLineH = new FlxSprite().makeGraphic(U.GRID_DIM, 3, 0xffff00ff);
				debugLineH.offset.y = 1;
				debugLineV = new FlxSprite().makeGraphic(3, U.GRID_DIM, 0xffff00ff);
				debugLineV.offset.x = 1;
				debugPoint = new FlxSprite().makeGraphic(5, 5, 0xffff00ff);
				debugPoint.offset.x = debugPoint.offset.y = 2;
			}
			
			var s:String, coords:Array;
			
			for (s in grid.horizontalLines) {
				if (!grid.horizontalLines[s]) continue;
				coords = s.split(U.COORD_DELIM);
				debugLineH.x = int(coords[0]) * U.GRID_DIM;
				debugLineH.y = int(coords[1]) * U.GRID_DIM;
				debugLineH.draw();
			}
			
			for (s in grid.verticalLines) {
				if (!grid.verticalLines[s]) continue;
				coords = s.split(U.COORD_DELIM);
				debugLineV.x = int(coords[0]) * U.GRID_DIM;
				debugLineV.y = int(coords[1]) * U.GRID_DIM;
				debugLineV.draw();
			}
			
			for (s in grid.carriersAtPoints) {
				if (!(grid.carriersAtPoints[s] is Module)) continue;
				coords = s.split(U.COORD_DELIM);
				debugPoint.x = int(coords[0]) * U.GRID_DIM;
				debugPoint.y = int(coords[1]) * U.GRID_DIM;
				debugPoint.draw();
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
		
		private function genSaveString():String {
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
		
		
		private function load(saveString:String = null):void {
			initLayers();
			displayWires = new Vector.<DWire>;
			displayModules = new Vector.<DModule>;
			
			wires = new Vector.<Wire>;
			modules = new Vector.<Module>;
			grid = new Grid;
			
			time = new Time;
			FlxG.globalSeed = 0.49;
			
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
		
		private function loadFromSuccess():void {
			var successSave:String = findSuccessSave();
			if (successSave == savedString || successSave == null)
				return;
			
			new CustomAction(function loadSuccess(success:String = null, old:String = null):Boolean { load(success); reactionStack = new Vector.<Action>; return true; },
							 function loadOld(success:String = null, old:String = null):void { load(old); },
							 successSave, savedString).execute();
		}
		
		private function findSuccessSave():String {
			var personalSuccess:String = level.successSave;
			if (personalSuccess)
				return personalSuccess;
			return null;
		}
		
		private function reset():void {
			if (RESET_SAVE == savedString || savedString == null)
				return;
			
			new CustomAction(function loadSuccess(old:String = null):Boolean { load(RESET_SAVE); reactionStack = new Vector.<Action>; return true; },
							 function loadOld(old:String = null):void { load(old); },
							 savedString).execute();
		}
		
		
		private function runTest():void {
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
		
		private function checkTestControls():void {
			if (FlxG.mouse.justPressed() || ControlSet.CANCEL_KEY.justPressed()) {
				level.goal.endRun();
				time.reset();
			}
		}
		
		private function drawTestText():void {
			if (!testText) {
				testText = U.LABEL_FONT.configureFlxText(new FlxText(0, FlxG.height / 2, FlxG.width, " "), 0x000000, 'center');
				testText.scrollFactor.x = testText.scrollFactor.y = 0;
				testBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0x80000000);
				testBG.scrollFactor.x = testBG.scrollFactor.y = 0;
			}
			testBG.draw();
			testText.text = "TESTING" + level.goal.getProgress() + "\nClick or " + ControlSet.CANCEL_KEY.key + " to cancel";
			testText.y = FlxG.height / 2 - testText.height / 2;
			testText.draw();
		}
		
		
		private function runDisplayTest():void {
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
		
		public const VIEW_MODE_NORMAL:int = 0;
		public const VIEW_MODE_DELAY:int = 1;
		
		private const LIST_NONE:int = 0;
		private const LIST_CATEGORIES:int = 2;
		private const LIST_MODULES:int = 3;
		private const LIST_ZOOM:int = 4;
		private const LIST_VIEW_MODES:int = 5;
		
		private const RESET_SAVE:String = U.SAVE_DELIM + U.SAVE_DELIM + U.SAVE_DELIM + U.SAVE_DELIM;
		
		[Embed(source = "../../lib/art/ui/eye.png")] private const _view_normal_sprite:Class;
		[Embed(source = "../../lib/art/ui/eye_delayb.png")] private const _view_delay_sprite:Class;
		private const VIEW_MODE_SPRITES:Array = [_view_normal_sprite, _view_delay_sprite];
		private const VIEW_MODE_NAMES:Array = ["normal", "delay"];
		
		[Embed(source = "../../lib/art/ui/list.png")] private const _list_sprite:Class;
		[Embed(source = "../../lib/art/ui/undo.png")] private const _undo_sprite:Class;
		[Embed(source = "../../lib/art/ui/redo.png")] private const _redo_sprite:Class;
		[Embed(source = "../../lib/art/ui/up.png")] private const _back_sprite:Class;
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
		[Embed(source = "../../lib/art/ui/tset_success.png")] private const _test_success_sprite:Class;
		[Embed(source = "../../lib/art/ui/tset_failure.png")] private const _test_failure_sprite:Class;
		
		[Embed(source = "../../lib/art/ui/pen.png")] private const _pen_cursor:Class;
		[Embed(source = "../../lib/art/ui/grabby_cursor.png")] private const _grab_cursor:Class;
		[Embed(source = "../../lib/art/ui/remove_cursor.png")] private const _remove_cursor:Class;
		[Embed(source = "../../lib/art/ui/delay_cursor.png")] private const _delay_cursor:Class;
		[Embed(source = "../../lib/art/ui/wrench_cursor.png")] private const _wrench_cursor:Class;
	}

}