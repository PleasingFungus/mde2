package LevelStates {
	import flash.utils.Dictionary;
	import Helpers.DeleteHelper;
	import Helpers.KeyHelper;
	import Modules.Module;
	import Modules.CustomModule;
	import Modules.ModuleCategory;
	import Modules.SysDelayClock;
	import org.flixel.*;
	import Actions.*;
	import Controls.*;
	import Displays.*;
	import UI.*;
	import Menu.*;
	import Infoboxes.*;
	import Testing.Goals.GeneratedGoal;
	import Values.FixedValue;
	import Values.Value;
	import Components.Bloc;
	import Components.Carrier;
	import Components.Wire
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.geom.Point;
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
		public var editEnabled:Boolean = true;
		
		private var UIEnableKey:Key = new Key("U");
		
		private var undoButton:GraphicButton;
		private var redoButton:GraphicButton;
		private var loadButton:MenuButton;
		private var resetButton:MenuButton;
		
		private var deleteHint:KeyHelper;
		
		
		public var infobox:Infobox;
		public var viewingComments:Boolean;
		private var displayTime:DTime;
		private var displayDelay:DDelay;
		private var preserveModule:Boolean;
		private var testText:FlxText;
		private var testBG:FlxSprite;
		private var lastRunTime:Number;
		private var runningDisplayTest:Boolean;
		
		private var recentModules:Vector.<Class>;
		private var moduleCategory:ModuleCategory;
		private var moduleList:ButtonList;
		private var moduleSliders:Vector.<ModuleSlider>;
		
		public var actionStack:Vector.<Action>;
		public var reactionStack:Vector.<Action>;
		private var currentWire:Wire;
		private var selectionArea:SelectionBox;
		private var currentBloc:Bloc;
		
		public var time:Time;
		public var grid:Grid;
		public var currentGrid:CurrentGrid;
		public var wires:Vector.<Wire>;
		public var modules:Vector.<Module>;
		public var memory:Vector.<Value>;
		public var initialMemory:Vector.<Value>;
		
		public var level:Level;
		public var loadData:String;
		public function LevelState(level:Level, loadData:String = null) {
			this.level = level;
			this.loadData = loadData;
		}
		
		override public function create():void {
			U.state = this;
			
			FlxG.bgColor = U.BG_COLOR;
			FlxG.mouse.show();
			
			actionStack = new Vector.<Action>;
			reactionStack = new Vector.<Action>;
			elapsed = 0;
			
			initialMemory = level.goal.genMem();
			
			load(loadData);
			loadData = null;
			level.setLast();
			recentModules = new Vector.<Class>;
			
			makeUI(false);
			upperLayer.add(infobox = new DMemory(memory, level.goal.genExpectedMem()));
			
			FlxG.camera.scroll.x = (FlxG.width / 2) / 1 - (FlxG.width / 2) / U.zoom;
			FlxG.camera.scroll.y = (FlxG.height / 2) / 1 - (FlxG.height / 2) / U.zoom;
			upperLayer.update(); //hack to avoid scroll issues
			addUIActives(); //likewise part of the hack
			
			FlxG.flash(0xff000000, MenuButton.FADE_TIME);
		}
		
		private function initLayers():void {
			members = [];
			add(lowerLayer = new FlxGroup());
			add(midLayer = new FlxGroup());
		}
		
		public function addWire(w:Wire, fixed:Boolean = true):void {
			w.FIXED = fixed;;
			if (!Wire.place(w))
				return;
			
			var displayWire:DWire = new DWire(w);
			midLayer.add(displayWire);
			displayWires.push(displayWire);
		}
		
		public function addModule(m:Module, fixed:Boolean = true):void {
			if (!m || !m.validPosition)
				return;
			
			m.FIXED = fixed;
			m.register();
			m.initialize();
			modules.push(m);
			
			var displayModule:DModule = m.generateDisplay();
			midLayer.add(displayModule);
			displayModules.push(displayModule);
		}
		
		private function makeUI(includeActives:Boolean = true):void {
			var UIEnabled:Boolean = !upperLayer || upperLayer.visible;
			upperLayer = new FlxGroup;
			upperLayer.visible = UIEnabled;
			
			new ButtonManager;
			UIChanged = true;
			upperLayer.add(new MenuBar(60));
			if (includeActives)
				addUIActives();
			makeViewButtons();
			
			if (!editEnabled) {
				ensureNothingHeld();
				makeViewLists();
				return;
			}
			
			makeEditButtons();
			makeViewLists();
			makeEditLists();
			
			checkMenuState();
		}
		
		private function addUIActives():void {
			upperLayer.add(new Scroller("levelstate"));
			upperLayer.add(new Zoomer);
			upperLayer.add(deleteHint = new DeleteHelper);
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
			makeShareButton();
			makeBackButton();
			if (runningDisplayTest) {
				upperLayer.add(displayTime);
				makeEndTestButton();
			}
		}
		
		private function makeViewLists():void {
			LIST_ZOOM == listOpen ? makeZoomList() : makeZoomButton();
			//if (level.delay)
				//LIST_VIEW_MODES == listOpen ? makeViewModeMenu() : makeViewModeButton()
		}
		
		private function makeEditButtons():void {
			makeSaveButtons();
			makeUndoButtons();
			makeTestButtons();
			if (level.delay && level.allowedModules.indexOf(SysDelayClock) != -1)
				makeClockButton();
		}
		
		private function makeEditLists():void {
			if (level.canPlaceModules && level.allowedModules.length)
				switch (listOpen) {
					case LIST_MODULES: makeModuleList(); break;
					case LIST_CATEGORIES: makeModuleCatList(); break;
					case LIST_NONE: default: makeModuleCatButton(); break;
				}
		}
		
		
		private function makeBackButton():void {
			var backButton:GraphicButton = new GraphicButton(FlxG.width - 32, -4, _back_sprite, function back():void {
				FlxG.switchState(new MenuState);
			}, "Exit to menu");
			backButton.fades = true;
			upperLayer.add(backButton);
		}
		
		private function makeShareButton():void {
			upperLayer.add(new ShareButton(FlxG.width - 100, 8));
		}
		
		private function makeSaveButtons():void {
			loadButton = addToolbarButton(170, _success_load_sprite, loadFromSuccess, "Load", "Load last successful machine", new Key("S"));
			resetButton = addToolbarButton(130, _reset_sprite, reset, "Reset", "Erase all placed parts");
		}
		
		private function makeUndoButtons():void {
			undoButton = addToolbarButton(50, _undo_sprite, undo, "Undo", "Undo", new Key("Z"));
			redoButton = addToolbarButton(90, _redo_sprite, redo, "Redo", "Redo", new Key("Y"));
		}
		
		private function makeDataButton():void {
			addToolbarButton(FlxG.width - 180, _data_sprite, function _():void {
				upperLayer.add(infobox = new DMemory(memory, level.goal.genExpectedMem()));
			}, "Memory", runningDisplayTest ? "View memory" : "View example memory", new Key("E"));
		}
		
		private function makeInfoButton():void {
			addToolbarButton(FlxG.width - 220, _info_sprite, function _():void {
				upperLayer.add(infobox = new DGoal(level));
			}, "Info", "Level info", new Key("I"));
		}
		
		private function makeClockButton():void {
			upperLayer.add(new DClock(210, 10));
		}
		
		private function makeZoomButton():void {
			addToolbarButton(FlxG.width - 140, _zoom_sprite, function openList():void {
				listOpen = LIST_ZOOM;
				makeUI();
			}, "Zoom", "Display zoom controls", new Key("O"));
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
			
			var zoomList:ButtonList = new ButtonList(FlxG.width - 145, 3, zoomButtons, function onListClose():void {
				if (listOpen == LIST_ZOOM)
					listOpen = LIST_NONE;
				makeUI();
			});
			zoomList.setSpacing(4);
			upperLayer.add(zoomList);
		}
		
		private function makeTestButtons():void {
			if (level.goal.dynamicallyTested)
				addToolbarButton(FlxG.width / 2 - 16, _test_sprite, function _():void {
					level.goal.startRun();
					lastRunTime = elapsed;
				}, "Test", "Test your machine!", new Key("T"));
		}
		
		private function makeEndTestButton():void {
			addToolbarButton(FlxG.width / 2 - 16, level.goal.succeeded ? _test_success_sprite : _test_failure_sprite, finishDisplayTest, "End Test", "Finish the test!", new Key("T"));
		}
		
		private function makeViewModeButton():void {
			addToolbarButton(FlxG.width - 180, VIEW_MODE_SPRITES[viewMode], function openList():void {
				listOpen = LIST_VIEW_MODES;
				makeUI();
			}, "Views", "Display list of view modes", new Key("Q"));
		}
		
		private function makeViewModeMenu():void {
			ensureNothingHeld();
			
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
			
			var modeList:ButtonList = new ButtonList(FlxG.width - 145, 3, modeSelectButtons, function onListClose():void {
				if (listOpen == LIST_VIEW_MODES)
					listOpen = LIST_NONE;
				makeUI();
			});
			modeList.setSpacing(4);
			upperLayer.add(modeList);
		}
		
		private function makeModuleCatButton():void {
			addToolbarButton(10, _module_sprite, function openList():void {
				ensureNothingHeld();
				listOpen = LIST_CATEGORIES;
				makeUI();
			}, "Modules", "Choose modules", new Key("FIVE"));
		}
		
		private function makeModuleCatList():void {
			//build a list of buttons for allowed modules/names
			var moduleButtons:Vector.<MenuButton> = new Vector.<MenuButton>;
			var i:int = 1;
			for each (var category:ModuleCategory in ModuleCategory.ALL) {
				var allowed:Boolean = false;
				for each (var moduleType:Class in level.allowedModules)
					if (Module.getArchetype(moduleType).category == category) {
						allowed = true;
						break;
					}
				
				moduleButtons.push(new TextButton( -1, -1, category.name, function chooseCategory(category:ModuleCategory):void {
					listOpen = LIST_MODULES;
					moduleCategory = category;
					makeUI();
				}, "Choose "+category.name+" modules" /*TODO: replace with category description?*/, ControlSet.NUMBER_HOTKEYS[i++]).setFormat(null, 16, category.color).setParam(category).setDisabled(!allowed));
			}
			
			if (recentModules.length) {
				moduleButtons.push(new TextButton( -1, -1, "---").setDisabled(true));
				for each (moduleType in recentModules) {
					archetype = Module.getArchetype(moduleType);
					moduleButtons.push(new TextButton( -1, -1, archetype.name, function chooseModule(moduleType:Class):void {
						createNewModule(moduleType);
						
						if (listOpen == LIST_CATEGORIES) {
							listOpen = LIST_NONE;
							makeUI();
						}
					}, "", ControlSet.NUMBER_HOTKEYS[i++]).setParam(moduleType).setTooltipCallback(archetype.getFullDescription).setDisabled(archetype.writesToMemory && level.writerLimit && numMemoryWriters() >= level.writerLimit));
				}
			}
			
			//put 'em in a list
			moduleList = new ButtonList(5, 3, moduleButtons, function onListClose():void {
				if (listOpen == LIST_CATEGORIES)
					listOpen = LIST_NONE;
				makeUI();
			});
			moduleList.setSpacing(4);
			upperLayer.add(moduleList);
			
			moduleSliders = new Vector.<ModuleSlider>;
			for (i = 0; i < recentModules.length; i++ ) {
				moduleType = recentModules[i];
				var archetype:Module = Module.getArchetype(moduleType);
				if (archetype.getConfiguration())
					moduleSliders.push(upperLayer.add(new ModuleSlider(moduleList.x + moduleList.width, moduleButtons[i+ModuleCategory.ALL.length+1], archetype)));
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
			
			var i:int = 1;
			for each (moduleType in moduleTypes) {
				archetype = Module.getArchetype(moduleType);
				moduleButtons.push(new TextButton( -1, -1, archetype.name, function chooseModule(moduleType:Class):void {
					createNewModule(moduleType);
						
					if (listOpen == LIST_MODULES) {
						listOpen = LIST_NONE;
						makeUI();
					}
				}, "", ControlSet.NUMBER_HOTKEYS[i++]).setParam(moduleType).setDisabled(archetype.writesToMemory && level.writerLimit && numMemoryWriters() >= level.writerLimit));
				if (archetype.getFullDescription() != null)
					moduleButtons[moduleButtons.length - 1].setTooltipCallback(archetype.getFullDescription);
			}
			
			//put 'em in a list
			moduleList = new ButtonList(5, 3, moduleButtons, function onListClose():void {
				if (listOpen == LIST_MODULES)
					listOpen = LIST_NONE;
				makeUI();
			});
			moduleList.setSpacing(4);
			upperLayer.add(moduleList);
			
			//make some sliders
			moduleSliders = new Vector.<ModuleSlider>;
			for (i = 0; i < moduleTypes.length; i++ ) {
				moduleType = moduleTypes[i];
				archetype = Module.getArchetype(moduleType);
				if (archetype.getConfiguration())
					moduleSliders.push(upperLayer.add(new ModuleSlider(moduleList.x + moduleList.width, moduleButtons[i+1], archetype)));
			}
		}
		
		private function createNewModule(moduleType:Class):void {
			var archetype:Module = Module.getArchetype(moduleType);
			if (!archetype.writesToMemory || !level.writerLimit || numMemoryWriters() < level.writerLimit) {
				var newModule:Module;
				if (archetype.getConfiguration())
					newModule = new moduleType( -1, -1, archetype.getConfiguration().value);
				else
					newModule = new moduleType( -1, -1);
				newModule.initialize();
				
				modules.push(newModule);
				var displayModule:DModule = newModule.generateDisplay();
				displayModules.push(midLayer.add(displayModule));
				currentBloc = addBlocFromModule(displayModule);
				addRecentModule(moduleType);
				
				preserveModule = true;
			}
		}
		
		private function addRecentModule(moduleType:Class):void {
			if (recentModules.indexOf(moduleType) >= 0)
				recentModules.splice(recentModules.indexOf(moduleType), 1);
			else if (recentModules.length >= 3)
				recentModules.pop();
			recentModules.unshift( moduleType);
		}
		
		private function addToolbarButton(X:int, Sprite:Class, Callback:Function, ShortName:String, LongName:String = null, Hotkey:Key = null):GraphicButton {
			if (!LongName)
				LongName = ShortName;
			var button:GraphicButton = new GraphicButton(X, 8, Sprite, Callback, LongName, Hotkey);
			upperLayer.add(button);
			
			var extraWidth:int = 10;
			var labelText:FlxText = new FlxText(X - extraWidth / 2 - 1, button.Y + button.fullHeight - 2, button.fullWidth + extraWidth, ShortName);
			U.TOOLBAR_FONT.configureFlxText(labelText, 0xffffff, 'center');
			labelText.scrollFactor.x = labelText.scrollFactor.y = 0;
			button.add(labelText);
			
			return button;
		}
		
		
		
		
		
		
		
		
		
		
		override public function update():void {
			elapsed += FlxG.elapsed;
			
			if (FlxG.camera.fading)
				return;
			
			U.buttonManager.update();
			
			if (infobox && infobox.exists) {
				infobox.update();
				return;
			}
			
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
			checkTime();
			checkDDelay();
			forceScroll();
			
			if (currentGrid.saveString != savedString) {
				currentGrid.init(savedString);
			}
		}
		
		private function updateUI():void {
			UIChanged = false;
			preserveModule = false;
			
			var members:Array = upperLayer.members.slice(); //copy, to prevent updating new members
			for (var i:int = members.length - 1; i >= 0; i--) {
				var b:FlxBasic = members[i];
				if (b && b.exists && b.active)
					b.update();
			}
		}
		
		private function checkControls():void {
			checkBuildControls();
			if (UIEnableKey.justPressed())
				upperLayer.visible = !upperLayer.visible
		}
		
		private function checkBuildControls():void {
			if (time.moment || runningDisplayTest)
				return; //no fucking around when shit is running!
			
			if (currentBloc && !currentBloc.exists)
				currentBloc = null;
			
			if (selectionArea) {
				if (!selectionArea.exists) {
					if (selectionArea.displayBloc) {
						midLayer.add(selectionArea.displayBloc);
						currentBloc = selectionArea.displayBloc.bloc;
					}
					selectionArea = null;
				}
			} else if (currentWire)
				checkWireControls();
			else if (currentBloc && !currentBloc.rooted) {
				//currently delegated to DBloc
			} else {
				if (FlxG.mouse.justPressed() && !U.buttonManager.moused) {
					if (ControlSet.DRAG_MODIFY_KEY.pressed())
						midLayer.add(selectionArea = new SelectionBox(displayWires, displayModules));
					else if (findMousedModule() && level.canPickupModules)
						pickUpModule();
					else if (level.canDrawWires && findMousedCarrier()) {
						currentWire = new Wire(U.pointToGrid(U.mouseLoc))
						displayWires.push(midLayer.add(new DWire(currentWire)));
					}
				}
				
				if (ControlSet.DELETE_KEY.justPressed() && !currentBloc) {
					destroyModules();
					destroyWires();
				}
				
				if (ControlSet.PASTE_KEY.justPressed() && U.clipboard) {
					var pastedBloc:DBloc = DBloc.fromString(U.clipboard);
					if (!pastedBloc)
						return;
					
					pastedBloc.extendDisplays(displayWires, displayModules);
					
					if (currentBloc)
						currentBloc.unravel();
					currentBloc = pastedBloc.bloc;
					
					midLayer.add(pastedBloc);
				}
				
				if (ControlSet.CUSTOM_KEY.justPressed() && currentBloc) //implies currentBloc.rooted, currentBloc.exists
					makeCustomModule();
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
		
		private function makeCustomModule():void {
			var customModule:CustomModule = CustomModule.fromSelection(currentBloc.modules);
			if (!customModule)
				return;
			
			currentBloc.unravel();
			currentBloc = null;
			
			modules.push(customModule);
			
			var displayModule:DModule = customModule.generateDisplay();
			midLayer.add(displayModule);
			displayModules.push(displayModule);
			
			currentBloc = addBlocFromModule(displayModule);
		}
		
		private function pickUpModule():void {
			var mousedModule:Module = findMousedModule();
			if (mousedModule && !mousedModule.FIXED) {
				currentBloc = addBlocFromModule(associatedDisplayModule(mousedModule), true);
				new BlocLiftAction(currentBloc, U.pointToGrid(U.mouseLoc)).execute();
				currentBloc.mobilize();
				currentBloc.exists = true;
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
		
		private function addBlocFromModule(displayModule:DModule, Rooted:Boolean = false):Bloc {
			var displayModules:Vector.<DModule> = new Vector.<DModule>;
			displayModules.push(displayModule);
			
			var displayBloc:DBloc = DBloc.fromDisplays(new Vector.<DWire>, displayModules, Rooted);
			displayBloc.bloc.origin = U.pointToGrid(U.mouseLoc);
			midLayer.add(displayBloc);
			
			return displayBloc.bloc;
		}
		
		private function associatedDisplayModule(module:Module):DModule {
			for each (var displayModule:DModule in displayModules)
				if (displayModule.module == module)
					return displayModule;
			return null;
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
			undoButton.exists = actionStack.length > 0;
			undoButton.active = canUndo(); 
			redoButton.exists = reactionStack.length > 0;
			redoButton.active = canRedo();
			var undoAlpha:Number = currentWire || (currentBloc && !currentBloc.rooted) ? 0.3 : 1;
			undoButton.setAlpha(undoAlpha);
			redoButton.setAlpha(undoAlpha);
			
			deleteHint.exists = canDelete();
			
			if (loadButton) {
				var successSave:String = findSuccessSave();
				loadButton.exists = successSave != savedString && successSave != null;
				resetButton.exists = savedString && savedString != RESET_SAVE;
			}
			
			checkCursorState();
			
			checkModuleListState();
		}
		
		private function canDelete():Boolean {
			if (currentWire || currentBloc || selectionArea || runningDisplayTest)
				return false;
			if (findMousedWire())
				return true;
			var module:Module = findMousedModule();
			return module && !module.FIXED;
		}
		
		private var cursor:Cursor;
		private var wasHidden:Boolean;
		private function checkCursorState():void {
			var newCursor:Cursor = getCursor();
			
			if (cursorHidden() || !upperLayer.visible) {
				FlxG.mouse.hide();
				wasHidden = true;
			} else if (wasHidden) {
				if (newCursor)
					FlxG.mouse.show(newCursor.rawSprite, 1, newCursor.offsetX, newCursor.offsetY);
				else
					FlxG.mouse.show();
				wasHidden = false;
			}
			
			if (cursor) {
				if (cursor.equals(newCursor))
					return;
			} else if (!newCursor)
				return;
			
			if (newCursor)
				FlxG.mouse.load(newCursor.rawSprite, 1, newCursor.offsetX, newCursor.offsetY);
			else
				FlxG.mouse.load();
			cursor = newCursor;
		}
		
		private function cursorHidden():Boolean {
			return listOpen == LIST_NONE && !time.moment && !U.buttonManager.moused && currentBloc && !currentBloc.rooted;
		}
		
		private function getCursor():Cursor {
			if (listOpen != LIST_NONE || runningDisplayTest || (infobox && infobox.exists) || U.buttonManager.moused)
				return null;
			
			if (currentWire)
				return Cursor.PEN;
			if (ControlSet.DRAG_MODIFY_KEY.pressed() || selectionArea)
				return Cursor.SEL;
			
			var mousedModule:Module = findMousedModule();
			if (mousedModule) {
				if (mousedModule.FIXED)
					return null;
				if (level.canPickupModules)
					return Cursor.GRAB;
			}
			
			var blocMoused:Boolean = false;
			if (currentBloc) { //implies currentBloc.rooted
				for each (var dwire:DWire in displayWires)
					if (currentBloc.wires.indexOf(dwire.wire) != -1 && dwire.overlapsPoint(U.mouseFlxLoc)) {
						blocMoused = true;
						break;
					}
				blocMoused = blocMoused || (!level.canPickupModules && mousedModule && currentBloc.modules.indexOf(mousedModule) != -1);
			} 
			
			if (blocMoused)
				return Cursor.GRAB;
			if (level.canDrawWires && findMousedCarrier())
				return Cursor.PEN;
			return null;
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
			if (!runningDisplayTest)
				return;
			
			runningDisplayTest = false;
			U.state.time.reset();
			editEnabled = true;
			makeUI();
			
			if (!level.goal.succeeded)
				return;
			
			level.successSave = genSaveString();
			level.setHighScore(modulesUsed());
			
			if (level == Level.ALL[0])
				U.updateTutState(U.TUT_BEAT_TUT_1);
			else if (level == Level.ALL[1])
				U.updateTutState(U.TUT_BEAT_TUT_2);
			
			upperLayer.add(infobox = new SuccessInfobox(level, modulesUsed()));
		}
		
		
		public function numMemoryWriters():int {
			var num:int = 0;
			for each (var module:Module in modules)
				if (module.exists && module.writesToMemory)
					num += module.writesToMemory;
			return num;
		}
		
		private function modulesUsed():int { 
			var used:int = 0;
			for each (var module:Module in modules)
				if (module.exists)
					used += module.weight;
			return used;
		}
		
		private function findMousedCarrier():Carrier {
			var mousedPoint:Point = U.pointToGrid(U.mouseLoc);
			if (grid.objTypeAtPoint(mousedPoint) != Vector)
				return null;
			
			return grid.carriersAtPoint(mousedPoint)[0];
		}
		
		private function findMousedWire():DWire {
			if (U.buttonManager.moused)
				return null;
			
			for each (var wire:DWire in displayWires)
				if (wire.exists && wire.overlapsPoint(U.mouseFlxLoc))
					return wire;
			return null;
		}
		
		private function destroyWires():void {
			var mousedWire:DWire = findMousedWire();
			if (mousedWire)
				new CustomAction(Wire.remove, Wire.place, mousedWire.wire).execute();
		}
		
		private function ensureNothingHeld():void {
			if (currentBloc) {
				currentBloc.unravel();
				currentBloc = null;
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
			
			var realBuf:BitmapData = FlxG.camera.buffer;
			FlxG.camera.buffer = buf;
			
			FlxG.camera.width = buf.width;
			FlxG.camera.height = buf.height;
			
			fillBG();
			
			DWire.updateStatic();
			
			checkMenuState();
			
			super.draw();
			if (DEBUG.RENDER_COLLIDE)
				debugRenderCollision();
			if (DEBUG.RENDER_CURRENT)
				debugRenderCurrent();
			
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
		
		private var boundRect:Rectangle;
		private var bgTile:FlxSprite;
		private function fillBG():void {
			if (U.PLAIN_BG) {
				if (!boundRect)
					boundRect = new Rectangle(0, 0, buf.width, buf.height);
				buf.fillRect(boundRect, FlxG.bgColor);
				return;
			}
			
			if (!bgTile)
				bgTile = new FlxSprite().loadGraphic(_bg);
			var screenRect:Rectangle = U.screenRect();
			for (bgTile.x = Math.floor(screenRect.x / bgTile.width) * bgTile.width; bgTile.x < screenRect.right; bgTile.x += bgTile.width)
				for (bgTile.y = Math.floor(screenRect.y / bgTile.height) * bgTile.height; bgTile.y < screenRect.bottom; bgTile.y += bgTile.height)
					bgTile.draw();
		}
		
		private var debugLineH:FlxSprite;
		private var debugLineV:FlxSprite;
		private var debugPoint:FlxSprite;
		private function debugRenderCollision():void {
			if (!debugLineH) {
				debugLineH = new FlxSprite().makeGraphic(U.GRID_DIM, 3, 0xffffffff);
				debugLineH.offset.y = 1;
				debugLineV = new FlxSprite().makeGraphic(3, U.GRID_DIM, 0xffffffff);
				debugLineV.offset.x = 1;
				debugPoint = new FlxSprite().makeGraphic(5, 5, 0xffffffff);
				debugPoint.offset.x = debugPoint.offset.y = 2;
			}
			debugLineH.color = debugLineV.color = debugPoint.color = 0x80ff00ff;
			
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
		private function debugRenderCurrent():void {
			if (!debugLineH) {
				debugLineH = new FlxSprite().makeGraphic(U.GRID_DIM, 3, 0xffffffff);
				debugLineH.offset.y = 1;
				debugLineV = new FlxSprite().makeGraphic(3, U.GRID_DIM, 0xffffffff);
				debugLineV.offset.x = 1;
				debugPoint = new FlxSprite().makeGraphic(5, 5, 0xffffffff);
				debugPoint.offset.x = debugPoint.offset.y = 2;
			}
			debugLineH.color = debugLineV.color = debugPoint.color = 0x8000eeff;
			
			var s:String, coords:Array;
			
			for (s in currentGrid.horizontalLines) {
				if (!currentGrid.horizontalLines[s]) continue;
				coords = s.split(U.COORD_DELIM);
				debugLineH.x = int(coords[0]) * U.GRID_DIM;
				debugLineH.y = int(coords[1]) * U.GRID_DIM;
				debugLineH.draw();
			}
			
			for (s in currentGrid.verticalLines) {
				if (!currentGrid.verticalLines[s]) continue;
				coords = s.split(U.COORD_DELIM);
				debugLineV.x = int(coords[0]) * U.GRID_DIM;
				debugLineV.y = int(coords[1]) * U.GRID_DIM;
				debugLineV.draw();
			}
			
			for (s in grid.carriersAtPoints) {
				if (!(grid.carriersAtPoints[s] is Vector.<Carrier>)) continue;
				coords = s.split(U.COORD_DELIM);
				debugPoint.x = int(coords[0]) * U.GRID_DIM;
				debugPoint.y = int(coords[1]) * U.GRID_DIM;
				debugPoint.draw();
			}
		}
		
		private function canUndo():Boolean {
			return actionStack.length > 0 && !currentWire && (!currentBloc || currentBloc.rooted);
		}
		
		private function canRedo():Boolean {
			return reactionStack.length > 0 && !currentWire && (!currentBloc || currentBloc.rooted);
		}
		
		
		private function undo():Action {
			if (!canUndo())
				return null;
			if (currentBloc) {
				currentBloc.unravel();
				currentBloc = null;
			}
			return actionStack.pop().revert();
		}
		
		private function redo():Action {
			if (!canRedo())
				return null;
			if (currentBloc) {
				currentBloc.unravel();
				currentBloc = null;
			}
			return reactionStack.pop().execute();
		}
		
		public function save():void {
			savedString = genSaveString();
			U.save.data[level.name] = savedString;
		}
		
		public function genSaveString():String {
			var saveStrings:Vector.<String>  = new Vector.<String>;
			
			//save modules
			var moduleStrings:Vector.<String> = new Vector.<String>;
			for each (var module:Module in modules)
				if (module.exists && !module.FIXED)
					moduleStrings.push(module.saveString());
			saveStrings.push(moduleStrings.join(U.SAVE_DELIM));
			
			//save wires
			var wireStrings:Vector.<String> = new Vector.<String>;
			for each (var wire:Wire in wires)
				if (wire.exists)
					wireStrings.push(wire.saveString());
			saveStrings.push(wireStrings.join(U.SAVE_DELIM));
			
			var miscStrings:Vector.<String> = new Vector.<String>;
			if (level.delay)
				miscStrings.push(time.clockPeriod.toString());
			saveStrings.push(miscStrings.join(U.SAVE_DELIM));
			
			var string:String = saveStrings.join(U.MAJOR_SAVE_DELIM);
			return string;
		}
		
		
		private function load(saveString:String = null):void {
			initLayers();
			displayWires = new Vector.<DWire>;
			displayModules = new Vector.<DModule>;
			
			wires = new Vector.<Wire>;
			modules = new Vector.<Module>;
			grid = new Grid;
			currentGrid = new CurrentGrid;
			
			time = new Time;
			FlxG.globalSeed = 0.49;
			
			if (saveString == null)
				saveString = U.save.data[level.name];
			if (saveString == null)
				saveString = findSuccessSave();
			if (saveString) {
				var saveArray:Array = saveString.split(U.MAJOR_SAVE_DELIM);
				
				//ordering is key
				//misc info first
				var miscStringsString:String = saveArray[2];
				if (miscStringsString.length) {
					var miscStrings:Array = miscStringsString.split(U.SAVE_DELIM);
					if (level.delay)
						time.clockPeriod = C.safeInt(miscStrings[0]);
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
			
			level.loadIntoState(this, saveString == RESET_SAVE || !saveString);
			
			makeUI();
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
			if (!level.goal.running)
				runDisplayTest();
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
			upperLayer.add(displayTime = new DTime(10, 10))
			displayTime.startPlaying();
			runningDisplayTest = true;
		}
		
		override public function destroy():void {
			super.destroy();
			
			if (cursor)
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
		
		private const RESET_SAVE:String = U.MAJOR_SAVE_DELIM + U.MAJOR_SAVE_DELIM;
		
		[Embed(source = "../../lib/art/ui/eye.png")] private const _view_normal_sprite:Class;
		[Embed(source = "../../lib/art/ui/eye_delayb.png")] private const _view_delay_sprite:Class;
		private const VIEW_MODE_SPRITES:Array = [_view_normal_sprite, _view_delay_sprite];
		private const VIEW_MODE_NAMES:Array = ["normal", "delay"];
		
		[Embed(source = "../../lib/art/ui/module.png")] private const _module_sprite:Class;
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
		[Embed(source = "../../lib/art/ui/reset.png")] private const _reset_sprite:Class;
		[Embed(source = "../../lib/art/ui/test.png")] private const _test_sprite:Class;
		[Embed(source = "../../lib/art/ui/tset_success.png")] private const _test_success_sprite:Class;
		[Embed(source = "../../lib/art/ui/tset_failure.png")] private const _test_failure_sprite:Class;
		
		[Embed(source = "../../lib/art/display/bg.png")] private const _bg:Class;
	}

}