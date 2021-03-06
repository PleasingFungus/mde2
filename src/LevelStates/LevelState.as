package LevelStates {
	import Components.Link;
	import Components.LinkPotential;
	import Components.Port;
	import Components.PseudoPort;
	import flash.events.IOErrorEvent;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import Helpers.DeleteHelper;
	import Helpers.KeyHelper;
	import Layouts.PortLayout;
	import Levels.LevelHint;
	import Modules.Module;
	import Modules.CustomModule;
	import Modules.ModuleCategory;
	import Modules.SeenModules;
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
	
	import flash.events.Event;
	import flash.net.URLLoader;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class LevelState extends FlxState {
		
		private var savedString:String;
		private var initialString:String;
		
		public var lowerLayer:FlxGroup;
		public var midLayer:FlxGroup;
		public var upperLayer:FlxGroup;
		public var elapsed:Number;
		
		private var displayWires:Vector.<DWire>;
		private var displayLinks:Vector.<DLink>;
		private var displayModules:Vector.<DModule>;
		private var listOpen:int;
		private var UIChanged:Boolean;
		public var editEnabled:Boolean = true;
		
		private var UIEnableKey:Key = ControlSet.UI_ENABLE;
		
		private var loadButton:MenuButton;
		private var resetButton:MenuButton;
		private var linkBeingDragged:Boolean;
		
		private var deleteHint:KeyHelper;
		private var decompWatcher:DecompositionWatcher;
		
		public var infobox:Infobox;
		public var viewingComments:Boolean;
		private var displayTime:DTime;
		private var testText:FlxText;
		private var testBG:FlxBasic;
		private var lastRunTime:Number;
		private var runningDisplayTest:Boolean;
		
		private var recentModules:Vector.<Class>;
		private var moduleCategory:ModuleCategory;
		private var moduleList:ButtonList;
		private var moduleSliders:Vector.<FlxBounded>; 
		
		public var actions:ActionStack;
		private var currentLink:Link;
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
			level.setLast();
			
			actions = new ActionStack;
			
			initialMemory = level.goal.genMem();
			
			recentModules = new Vector.<Class>;
			
			loadInitial(loadData);
			makeUIInitial(loadData == null);
			loadData = null;
			
			FlxG.camera.scroll.x = (FlxG.width / 2) / 1 - (FlxG.width / 2) / U.zoom;
			FlxG.camera.scroll.y = (FlxG.height / 2) / 1 - (FlxG.height / 2) / U.zoom;
			FlxG.bgColor = U.BG_COLOR;
			FlxG.mouse.show();
			FlxG.flash(0xff000000, MenuButton.FADE_TIME);
			elapsed = 0;
		}
		
		private function makeUIInitial(makeInfobox:Boolean):void {
			if (!makeInfobox) {
				makeUI();
				return;
			}
			
			makeUI(false); //don't add UI actives yet...
			infobox = new DGoal(level);
			upperLayer.add(infobox); //because we won't be updating while the infobox is up...
			
			upperLayer.update(); //and some UI members need a single-frame update to position themselves properly
			var temp:Array = upperLayer.members; //but now we don't have the UI actives in the right place (first) in the upper layer, so...
			upperLayer.members = []; //reset the list...
			addUIActives(); //add the UI actives...
			for each (var member:FlxBasic in temp)
				upperLayer.add(member); //then add the other UI members back.
		}
		
		private function initLayers():void {
			members = [];
			add(lowerLayer = new FlxGroup());
			add(midLayer = new FlxGroup());
		}
		
		public function addLink(l:Link, fixed:Boolean = true):void {
			l.FIXED = fixed;
			Link.place(l);
		}
		
		public function addWire(w:Wire, fixed:Boolean = true):void {
			w.FIXED = fixed;
			if (!Wire.place(w))
				return;
			
			var displayWire:DWire = new DWire(w);
			midLayer.add(displayWire);
			displayWires.push(displayWire);
		}
		
		public function placeModule(m:Module, fixed:Boolean = true, addChildren:Boolean = true):void {
			if (!m || !m.validPosition)
				return;
			
			m.FIXED = fixed;
			m.place();
			registerModule(m, addChildren);
		}
		
		public function registerModule(m:Module, addChildren:Boolean = true):DModule {
			modules.push(m);
			
			var displayModule:DModule = m.generateDisplay();
			midLayer.add(displayModule);
			displayModules.push(displayModule);
			
			if (addChildren)
				for each (var module:Module in m.getChildren())
					registerModule(module);
			
			return displayModule;
		}
		
		private function makeUI(includeActives:Boolean = true):void {
			var UIEnabled:Boolean = !upperLayer || upperLayer.visible;
			upperLayer = new FlxGroup;
			upperLayer.visible = UIEnabled;
			
			new ButtonManager;
			UIChanged = true;
			if (includeActives)
				addUIActives();
			upperLayer.add(new MenuBar(60));
			makeViewButtons();
			
			var hint:LevelHint = level.makeHint();
			if (hint)
				upperLayer.add(hint);
			
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
			upperLayer.add(new DCurrent(displayWires, displayModules, displayLinks));
			upperLayer.add(new DModuleInfo(displayModules));
			if (decompWatcher)
				decompWatcher.ensureSafety();
			upperLayer.add(decompWatcher = new DecompositionWatcher());
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
			if (level.delay)
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
			backButton.setScroll(0);
			upperLayer.add(backButton);
		}
		
		private function makeShareButton():void {
			upperLayer.add(new ShareButton(FlxG.width - 100, 8));
		}
		
		private function makeSaveButtons():void {
			upperLayer.add(loadButton = new ToolbarButton(170, _success_load_sprite, loadFromSuccess, "Load", "Load last successful machine"));
			upperLayer.add(resetButton = new ToolbarButton(130, _reset_sprite, reset, "Reset", "Erase all placed parts"));
		}
		
		private function makeUndoButtons():void {
			upperLayer.add(new DUndo(actions));
		}
		
		private function makeDataButton():void {
			upperLayer.add(new ToolbarButton(FlxG.width - 180, _data_sprite, function _():void {
				upperLayer.add(infobox = new DMemory(memory, level.goal.genExpectedMem()));
			}, "Memory", runningDisplayTest ? "View memory" : "View example memory", ControlSet.MEMORY));
		}
		
		private function makeInfoButton():void {
			upperLayer.add(new ToolbarButton(FlxG.width - 220, _info_sprite, function _():void {
				upperLayer.add(infobox = new DGoal(level));
			}, "Info", "Level info", ControlSet.HELP));
		}
		
		private function makeClockButton():void {
			var clock:DClock = new DClock(210, 10);
			var extraWidth:int = 10;
			clock.add(new ToolbarText(clock.X - 10 / 2 - 1, clock.Y + clock.fullHeight - 2, clock.fullWidth + extraWidth, "Period"));
			upperLayer.add(clock);
		}
		
		private function makeZoomButton():void {
			upperLayer.add(new ToolbarButton(FlxG.width - 140, _zoom_sprite, function openList():void {
				listOpen = LIST_ZOOM;
				makeUI();
			}, "Zoom", "Display zoom controls", ControlSet.ZOOM));
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
				upperLayer.add(new ToolbarButton(FlxG.width / 2 - 16, _test_sprite, function _():void {
					level.goal.startRun();
					lastRunTime = elapsed;
				}, "Test", "Test your machine!", ControlSet.TEST));
		}
		
		private function makeEndTestButton():void {
			upperLayer.add(new ToolbarButton(FlxG.width / 2 - 16, level.goal.succeeded ? _test_success_sprite : _test_failure_sprite, finishDisplayTest,
											 "End Test", "Finish the test!", ControlSet.TEST));
		}
		
		//private function makeViewModeButton():void {
			//addToolbarButton(FlxG.width - 180, VIEW_MODE_SPRITES[viewMode], function openList():void {
				//listOpen = LIST_VIEW_MODES;
				//makeUI();
			//}, "Views", "Display list of view modes", new Key("Q"));
		//}
		
		//private function makeViewModeMenu():void {
			//ensureNothingHeld();
			//
			//var modeSelectButtons:Vector.<MenuButton> = new Vector.<MenuButton>;
			//for each (var newMode:int in [VIEW_MODE_NORMAL, VIEW_MODE_DELAY]) {
				//modeSelectButtons.push(new GraphicButton( -1, -1, VIEW_MODE_SPRITES[newMode], function selectMode(newMode:int):void {
					//viewMode = newMode;
					//if (LIST_VIEW_MODES == listOpen ) {
						//listOpen = LIST_NONE;
						//makeUI();
					//}
				//}, "Enter "+VIEW_MODE_NAMES[newMode]+" view mode", ControlSet.NUMBER_HOTKEYS[newMode+1]).setParam(newMode).setSelected(newMode == viewMode));
			//}
			//
			//var modeList:ButtonList = new ButtonList(FlxG.width - 145, 3, modeSelectButtons, function onListClose():void {
				//if (listOpen == LIST_VIEW_MODES)
					//listOpen = LIST_NONE;
				//makeUI();
			//});
			//modeList.setSpacing(4);
			//upperLayer.add(modeList);
		//}
		
		private function makeModuleCatButton():void {
			var moduleCatButton:ToolbarButton = new ToolbarButton(10, _module_sprite, function openList():void {
				ensureNothingHeld();
				listOpen = LIST_CATEGORIES;
				makeUI();
			}, "Modules", "Choose modules", ControlSet.MODULES_BACK);
			upperLayer.add(moduleCatButton);
			
			if (SeenModules.SEEN.unknownInList(level.allowedModules))
				upperLayer.add(new ButtonFlasher(moduleCatButton));
		}
		
		private function makeModuleCatList():void {
			//build a list of buttons for allowed modules/names
			var moduleButtons:Vector.<MenuButton> = new Vector.<MenuButton>;
			
			moduleButtons.push(new TextButton( -1, -1, "<Close>", function close():void {
				listOpen = LIST_NONE;
				makeUI();
			}, null, ControlSet.MODULES_BACK));
			
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
					var archetype:Module = Module.getArchetype(moduleType);
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
			
			makeModuleSliders(recentModules, moduleButtons.slice(ModuleCategory.ALL.length + 2));
			
			upperLayer.add(moduleList);
			
			for (i = 1; i < ModuleCategory.ALL.length; i++) {
				category = ModuleCategory.ALL[i-1];
				if (SeenModules.SEEN.unknownInListInCategory(level.allowedModules, category))
					upperLayer.add(new ButtonFlasher(moduleButtons[i]));
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
			}, null, ControlSet.MODULES_BACK));
			
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
			
			//make some sliders
			moduleSliders = makeModuleSliders(moduleTypes, moduleButtons.slice(1));
			
			upperLayer.add(moduleList);
			
			for (i = 0; i < moduleTypes.length; i++) {
				moduleType = moduleTypes[i];
				if (!SeenModules.SEEN.moduleSeen(moduleType))
					upperLayer.add(new ButtonFlasher(moduleButtons[i+1]));
			}
			SeenModules.SEEN.setSeen(moduleTypes);
		}
		
		private function createNewModule(moduleType:Class):void {
			var archetype:Module = Module.getArchetype(moduleType);
			
			if (archetype.writesToMemory && level.writerLimit && numMemoryWriters() >= level.writerLimit)
				return;
			
			var gridLoc:Point = U.pointToGrid(U.mouseLoc);
			var newModule:Module = archetype.fromConfig(moduleType, gridLoc);
			newModule.initialize();
			
			
			var displayModule:DModule = registerModule(newModule);
			currentBloc = addBlocFromModule(displayModule);
			addRecentModule(moduleType);
		}
		
		private function addRecentModule(moduleType:Class):void {
			if (recentModules.indexOf(moduleType) >= 0)
				recentModules.splice(recentModules.indexOf(moduleType), 1);
			else if (recentModules.length >= 3)
				recentModules.pop();
			recentModules.unshift( moduleType);
		}
		
		private function makeModuleSliders(moduleTypes:Vector.<Class>, moduleButtons:Vector.<MenuButton>):Vector.<FlxBounded> {
			moduleSliders = new Vector.<FlxBounded>;
			for (var i:int = 0; i < moduleTypes.length; i++ ) {
				var moduleType:Class = moduleTypes[i];
				var archetype:Module = Module.getArchetype(moduleType);
				if (archetype.canGenerateConfigurationTool()) {
					var button:MenuButton = moduleButtons[i];
					var slider:FlxBounded = archetype.generateConfigurationTool(moduleList.x + moduleList.width,
																				button.Y, button.fullHeight);
					moduleSliders.push(slider);
					upperLayer.add(slider.basic);
				}
			}
			return moduleSliders;
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
			checkState();
			checkTime();
			forceScroll();
			
			if (currentGrid.saveString != savedString) {
				currentGrid.init(savedString);
			}
		}
		
		private function updateUI():void {
			UIChanged = false;
			
			var members:Array = upperLayer.members.slice(); //copy, to prevent updating new members
			for (var i:int = members.length - 1; i >= 0; i--) {
				var b:FlxBasic = members[i];
				if (b && b.exists && b.active)
					b.update();
			}
		}
		
		private function checkControls():void {
			if (!ControlSet.DELETE_KEY.enabled && !ControlSet.DELETE_KEY.pressed())
				ControlSet.DELETE_KEY.enabled = true;
			checkBuildControls();
			if (UIEnableKey.justPressed())
				upperLayer.visible = !upperLayer.visible
			if (ControlSet.DEBUG_PRINT.justPressed())
				C.log(genSaveString());
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
			} else if (currentLink)
				checkLinkControls();
			else if (currentBloc && !currentBloc.rooted) {
				//currently delegated to DBloc
			} else {
				if (FlxG.mouse.justPressed() && !U.buttonManager.moused) {
					if (findMousedModule() && level.canPickupModules)
						pickUpModule();
					else {
						var mousedPort:Port = findMousedPort();
						if (level.canDrawWires && mousedPort && Link.validStart(mousedPort)) {
							currentLink = new Link(mousedPort, new PseudoPort(U.pointToGrid(U.mouseLoc)), true);
							displayLinks.push(midLayer.add(new DLink(currentLink)));
							linkBeingDragged = false;
						} else
							midLayer.add(selectionArea = new SelectionBox(displayLinks, displayModules));
					}
				}
				
				if (ControlSet.DELETE_KEY.enabled && ControlSet.DELETE_KEY.pressed() && !currentBloc) {
					decompWatcher.ensureSafety();
					destroyModules();
					destroyWires();
					destroyLinks();
				}
				
				if (ControlSet.PASTE_KEY.justPressed() && U.clipboard) {
					var pastedBloc:DBloc = DBloc.fromString(U.clipboard);
					if (pastedBloc)
						addDBloc(pastedBloc);
				}
				
				if (ControlSet.CUSTOM_KEY.justPressed() && currentBloc) //implies currentBloc.rooted, currentBloc.exists
					makeCustomModule();
			}
		}
		
		public function addDBloc(dBloc:DBloc):void {
			dBloc.extendDisplays(displayLinks, displayModules);
			
			if (currentBloc)
				currentBloc.unravel();
			currentBloc = dBloc.bloc;
			
			midLayer.add(dBloc);
		}
		
		private function checkLinkControls():void {
			if (ControlSet.CANCEL_KEY.justPressed()) {
				currentLink.deleted = true;
				currentLink = null;
				return;
			}
			
			if (FlxG.mouse.pressed() || linkBeingDragged) {
				var mouseLoc:Point = U.pointToGrid(U.mouseLoc);
				currentLink.destination.Loc.x = mouseLoc.x;
				currentLink.destination.Loc.y = mouseLoc.y;
				if (!currentLink.destination.Loc.equals(currentLink.source.Loc))
					linkBeingDragged = true;
			}
			
			if (FlxG.mouse.justReleased()) {
				if (linkBeingDragged) {
					new CustomAction(Link.place, Link.remove, currentLink).execute();
					currentLink = null;
				} else
					linkBeingDragged = true;
			}
		}
		
		private function makeCustomModule():void {
			var customModule:CustomModule = CustomModule.fromSelection(currentBloc.modules, U.pointToGrid(U.mouseLoc));
			if (!customModule)
				return;
			
			currentBloc.unravel();
			currentBloc = null;
			
			var displayModule:DModule = registerModule(customModule);
			currentBloc = addBlocFromModule(displayModule);
		}
		
		private function pickUpModule():void {
			var mousedModule:Module = findMousedModule();
			if (mousedModule && !mousedModule.FIXED) {
				decompWatcher.ensureSafety();
				currentBloc = addBlocFromModule(associatedDisplayModule(mousedModule), true);
				currentBloc.lift(U.pointToGrid(U.mouseLoc));
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
			
			var displayBloc:DBloc = DBloc.fromDisplays(new Vector.<DLink>, displayModules, Rooted);
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
				new DelModuleAction(mousedModule).execute();
		}
		
		public function findMousedDModule():DModule {
			if (U.buttonManager.moused)
				return null;
			
			for each (var dModule:DModule in displayModules)
				if (dModule.module.exists && dModule.module.deployed && dModule.overlapsPoint(U.mouseFlxLoc))
					return dModule;
			return null;
		}
		
		public function findMousedModule():Module {
			var dModule:DModule = findMousedDModule();
			if (dModule)
				return dModule.module;
			return null;
		}
		
		public function findMousedDPort():DPort {
			var mouseLoc:FlxPoint = U.mouseFlxLoc;
			for each (var dModule:DModule in displayModules)
				if (dModule.module.exists && dModule.module.deployed && dModule.onScreen())
					for each (var dPort:DPort in dModule.displayPorts)
						if (dPort.overlapsPoint(mouseLoc))
							return dPort;
			return null;
		}
		
		
		
		private function findMousedCarrier():Carrier {
			var mousedPoint:Point = U.pointToGrid(U.mouseLoc);
			var carriers:Vector.<Carrier> = grid.carriersAtPoint(mousedPoint);
			return carriers ? carriers[0] : null;
		}
		
		//UNTESTED
		public function findMousedPort():Port {
			var mousedPoint:Point = U.pointToGrid(U.mouseLoc);
			for each (var module:Module in modules)
				if (module.exists && module.deployed)
					for each (var port:PortLayout in module.layout.ports)
						if (port.Loc.equals(mousedPoint))
							return port.port;
			return null;
		}
		
		private function findMousedWire():DWire {
			if (U.buttonManager.moused)
				return null;
			
			for each (var wire:DWire in displayWires)
				if (wire.exists && wire.overlapsPoint(U.mouseFlxLoc))
					return wire;
			return null;
		}
		
		private function findMousedLink():DLink {
			if (U.buttonManager.moused)
				return null;
			
			for each (var link:DLink in displayLinks)
				if (link.link.mouseable && link.overlapsPoint(U.mouseFlxLoc))
					return link;
			return null;
		}
		
		
		public function displayModuleFor(module:Module):DModule {
			for each (var displayModule:DModule in displayModules)
				if (displayModule.module == module)
					return displayModule;
			return null;
		}
		
		
		private function checkMenuState():void {
			deleteHint.exists = canDelete();
			
			if (!decompWatcher.decomposition) {
				decompWatcher.exists = !currentLink && !currentBloc;
				if (!decompWatcher.exists)
					decompWatcher.ensureSafety(); //paranoia
			}
			
			if (loadButton) {
				var successSave:String = findSuccessSave();
				loadButton.exists = successSave != savedString && successSave != null;
				resetButton.exists = savedString && savedString != RESET_SAVE && savedString != initialString;
			}
			
			checkCursorState();
			
			checkModuleListState();
		}
		
		private function canDelete():Boolean {
			if (currentLink || currentBloc || selectionArea || runningDisplayTest)
				return false;
			
			var mousedWire:DWire = findMousedWire();
			if (mousedWire && !mousedWire.wire.FIXED)
				return true;
			
			var mousedLink:DLink = findMousedLink();
			if (mousedLink && !mousedLink.link.FIXED)
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
			
			if (currentLink)
				return Cursor.PEN;
			if (selectionArea)
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
				blocMoused = !level.canPickupModules && mousedModule && currentBloc.modules.indexOf(mousedModule) != -1;
			} 
			
			if (blocMoused)
				return Cursor.GRAB;
			if (level.canDrawWires) {
				var carrier:Carrier = findMousedCarrier();
				if (carrier && (carrier.isSource() || !carrier.getSource()))
					return Cursor.PEN;
			}
			return null;
		}
		
		private function checkModuleListState():void {
			if (moduleList && !moduleList.exists) {
				moduleList = null;
				moduleSliders = null;
				makeUI();
			} else if (moduleSliders) {
				moduleList.closesOnClickOutside = true;
				for each (var moduleSlider:FlxBounded in moduleSliders)
					if (moduleSlider.overlapsPoint(FlxG.mouse)) {
						moduleList.closesOnClickOutside = false;
						break;
					}
			}
		}
		
		private function checkState():void {
			if (Link.newLinks.length) {
				for each (var link:Link in Link.newLinks)
					if (!linkAlreadyDisplayed(link))
						displayLinks.push(midLayer.add(new DLink(link)));
				Link.newLinks = new Vector.<Link>;
			}
		}
		
		private function linkAlreadyDisplayed(link:Link):Boolean {
			for each (var dLink:DLink in displayLinks)
				if (dLink.link.equals(link))
					return true;
			return false;
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
		
		private function finishDisplayTest():void {
			if (!runningDisplayTest)
				return;
			
			runningDisplayTest = false;
			U.state.time.reset();
			displayTime.stop();
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
		
		private function destroyWires():void {
			var mousedWire:DWire = findMousedWire();
			if (mousedWire)
				new CustomAction(Wire.remove, Wire.place, mousedWire.wire).execute();
		}
		
		private function destroyLinks():void {
			var mousedLink:DLink = findMousedLink();
			if (mousedLink)
				new CustomAction(Link.remove, Link.place, mousedLink.link).execute();
		}
		
		public function ensureNothingHeld():void {
			if (currentBloc) {
				currentBloc.unravel();
				currentBloc = null;
			}
		}
		
		public function addDisplayWireFor(wire:Wire):void {
			displayWires.push(midLayer.add(new DWire(wire)));
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
			DLink.updateStatic();
			
			checkMenuState();
			
			super.draw();
			//if (DEBUG.RENDER_COLLIDE)
				//debugRenderCollision();
			//if (DEBUG.RENDER_CURRENT)
				//debugRenderCurrent();
			
			if (!matrix) {
				matrix = new Matrix;
				matrix.scale(U.zoom, U.zoom);
			}
			realBuf.draw(buf, matrix);
			FlxG.camera.buffer = realBuf;
			
			if (U.UPPER_NODE_TEXT && U.zoom < 1 && U.zoom >= 0.5)
				drawNodeText();
			
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
		
		private function drawNodeText():void {
			for each (var dModule:DModule in displayModules)
				if (dModule.exists && dModule.visible)
					dModule.drawNodeText();
		}
		
		
		
		
		
		public function hasHeldState():Boolean {
			return currentLink || (currentBloc && !currentBloc.rooted);
		}
		
		public function onStateChange():void {
			save();
			calculateModuleState();
		}
		
		public function calculateModuleState():void {
			var module:Module;
			for each (module in U.state.modules)
				module.clearCachedValues();
			for each (module in modules)
				module.cacheValues();
		}
		
		public function save():void {
			savedString = genSaveString();
			U.save.data[level.name] = savedString;
		}
		
		public function genSaveString():String {
			if (U.BINARY_SAVES)
				return genBinarySave();
			else
				return genOldFormatSave();
		}
		
		private function genBinarySave():String {
			var moduleBytes:ByteArray = new ByteArray;
			for each (var module:Module in modules)
				if (module.exists && !module.FIXED)
					moduleBytes.writeBytes(module.getBytes());
			
			var wireBytes:ByteArray = new ByteArray;
			for each (var wire:Wire in wires)
				if (wire.exists && !wire.FIXED)
					wireBytes.writeBytes(wire.getBytes());
			
			var linkBytes:ByteArray = new ByteArray;
			for each (var link:Link in getLinks())
				if (link.saveIncluded)
					linkBytes.writeBytes(link.getBytes());
			
			var miscBytes:ByteArray = new ByteArray;
			if (level.delay)
				miscBytes.writeInt(time.clockPeriod);
			
			var saveBytes:ByteArray = new ByteArray;
			saveBytes.writeInt(U.SAVE_VERSION);
			saveBytes.writeInt(4 + moduleBytes.length);
			saveBytes.writeBytes(moduleBytes);
			saveBytes.writeInt(4 + wireBytes.length);
			saveBytes.writeBytes(wireBytes);
			saveBytes.writeInt(4 + linkBytes.length);
			saveBytes.writeBytes(linkBytes);
			saveBytes.writeInt(4 + miscBytes.length);
			saveBytes.writeBytes(miscBytes);
			
			saveBytes.deflate();
			
			var b64:String = Base64.encodeByteArray(saveBytes);
			return b64;
		}
		
		private function getLinks():Vector.<Link> {
			var links:Vector.<Link> = new Vector.<Link>;
			for each (var module:Module in modules)
				if (module.exists)
					for each (var link:Link in module.getInLinks())
						links.push(link);
			return links;
		}
		
		private function genOldFormatSave():String {
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
				if (wire.exists && !wire.FIXED)
					wireStrings.push(wire.saveString());
			saveStrings.push(wireStrings.join(U.SAVE_DELIM));
			
			var miscStrings:Vector.<String> = new Vector.<String>;
			if (level.delay)
				miscStrings.push(time.clockPeriod.toString());
			saveStrings.push(miscStrings.join(U.SAVE_DELIM));
			
			var string:String = saveStrings.join(U.MAJOR_SAVE_DELIM);
			return string;
		}
		
		private function initDisplay():void {
			initLayers();
			displayWires = new Vector.<DWire>;
			displayLinks = new Vector.<DLink>;
			displayModules = new Vector.<DModule>;
		}
		
		private function initState():void {
			wires = new Vector.<Wire>;
			modules = new Vector.<Module>;
			grid = new Grid;
			currentGrid = new CurrentGrid;
			
			time = new Time;
			FlxG.globalSeed = 0.49;
		}
		
		private function loadInitial(saveString:String):void {
			initDisplay();
			initState();
			level.loadIntoState(this, true);
			initialString = genSaveString();
			
			load(saveString);
		}
		
		private function load(saveString:String = null):void {
			initDisplay();
			initState();
			
			var levelLoaded:Boolean = false;
			
			if (saveString == null)
				saveString = U.save.data[level.name];
			if (saveString == null)
				saveString = findSuccessSave();
			if (saveString) {
				var loadedData:LevelLoader = FlxG.debug ? LevelLoader.loadSimple(saveString) : LevelLoader.loadSafe(saveString);
				if (loadedData) {
					savedString = loadedData.saveString;
					time.clockPeriod = loadedData.clock;
					
					level.loadIntoState(this, false);
					levelLoaded = true;
			
					for each (var wire:Wire in loadedData.wires)
						addWire(wire, false);
					for each (var module:Module in loadedData.modules)
						placeModule(module, false, false);
					for each (var linkPotential:LinkPotential in loadedData.linkPotentials)
						addLink(linkPotential.manifestPotential(modules), false);
				} else
					savedString = null;
			}
			
			if (!levelLoaded)
				level.loadIntoState(this, savedString == RESET_SAVE || !savedString);
			
			for each (module in modules.slice())
				for each (var child:Module in module.getChildren())
					registerModule(child, false); //recursion implicit in getChildren();
			//do this later for save compat (dubious)
			
			if (wires.length && !DEBUG.PRESERVE_WIRES)
				cleanupWires();
			
			makeUI();
		}
		
		private function cleanupWires():void {
			var links:Vector.<Link> = new Vector.<Link>;
			for each (var module:Module in modules)
				if (module.exists)
					for each (var link:Link in module.getInLinks())
						links.push(link);
			
			for each (var wire:Wire in wires.slice()) //copy to avoid iterating a mutated list
				Wire.remove(wire);
			
			for each (link in links)
				Link.place(link);
		}
		
		private function loadFromSuccess():void {
			var successSave:String = findSuccessSave();
			if (successSave == savedString || successSave == null)
				return;
			
			new CustomAction(function loadSuccess(success:String = null, old:String = null):Boolean { load(success); actions.clearRedo(); return true; },
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
			
			actions.actionStack = new Vector.<Action>; //clear undo before reset
			new CustomAction(function loadSuccess(old:String = null):Boolean { load(RESET_SAVE); actions.clearRedo(); return true; },
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
				testBG = new ScreenFilter(0x80000000);
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