package Modules {
	import Components.Link;
	import Displays.DModule;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import Layouts.*;
	import Components.Port;
	import org.flixel.FlxBasic;
	import org.flixel.FlxSprite;
	import UI.FlxBounded;
	import UI.ModuleSlider;
	import UI.HighlightFormat;
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Module extends Point {
		
		public var name:String;
		public var abbrev:String;
		public var category:ModuleCategory;
		protected var symbol:Class;
		protected var largeSymbol:Class;
		public var layout:ModuleLayout;
		public var internalLayout:InternalLayout;
		
		public var inputs:Vector.<Port>;
		public var outputs:Vector.<Port>;
		public var controls:Vector.<Port>;
		
		protected var configuration:Configuration;
		public var configurableInPlace:Boolean = true;
		public var delay:int;
		public var writesToMemory:int = 0;
		public var weight:int = 1;
		public var storesData:Boolean = false;
		
		public var exists:Boolean = true;
		public var solid:Boolean = true;
		public var deployed:Boolean = false;
		
		public var FIXED:Boolean = false;
		
		public function Module(X:int, Y:int, Name:String, Category:ModuleCategory, numInputs:int, numOutputs:int, numControls:int ) {
			super(X, Y);
			
			name = Name;
			category = Category;
			makePorts(numInputs, numOutputs, numControls);
			
			setLayout();
			initialize();
		}
		
		protected function makePorts(numInputs:int, numOutputs:int, numControls:int):void {
			inputs = new Vector.<Port>; populatePorts(inputs, numInputs, false);
			outputs = new Vector.<Port>; populatePorts(outputs, numOutputs, true);
			controls = new Vector.<Port>; populatePorts(controls, numControls, false);
		}
		
		public function getConfiguration():Configuration {
			return configuration;
		}
		
		public function setLayout():void {
			layout = generateLayout();
			internalLayout = generateInternalLayout();
		}
		
		protected function generateLayout():ModuleLayout {
			return new DefaultLayout(this);
		}
		
		protected function generateInternalLayout():InternalLayout {
			return null;
		}
		
		public function generateDisplay():DModule {
			return new DModule(this);
		}
		
		public function generateSymbolDisplay():FlxSprite {
			if (!symbol)
				return null;
			var symbolDisplay:FlxSprite = new FlxSprite( -1, -1, symbol);
			symbolDisplay.color = 0x0;
			return symbolDisplay;
		}
		
		public function generateLargeSymbolDisplay():FlxSprite {
			if (!symbol && !largeSymbol)
				return null;
			var symbolDisplay:FlxSprite = new FlxSprite( -1, -1, largeSymbol ? largeSymbol : symbol);
			if (!largeSymbol)
				symbolDisplay.scale.x = symbolDisplay.scale.y = 2;
			symbolDisplay.color = 0x0;
			return symbolDisplay;
		}
		
		public function canGenerateConfigurationTool():Boolean {
			return getConfiguration() != null;
		}
		
		public function generateConfigurationTool(X:int, Y:int, MaxHeight:int):FlxBounded {
			return new ModuleSlider(X, Y, MaxHeight, this);
		}
		
		private function populatePorts(ports:Vector.<Port>, numPorts:int, isOutput:Boolean):void {
			for (var i:int = 0; i < numPorts; i++)
				ports.push(new Port(isOutput, this));
		}
		
		
		
		
		public function renderDetails():String {
			return name;
		}
		
		public function getDescription():String {
			return null;
		}
		
		public function getHighlitDescription():HighlightFormat {
			return null;
		}
		
		public function getFullDescription():String {
			var desc:String = getDescription();
			if (!desc) {
				if (U.state && U.state.level.delay && delay)
					return "DELAY: " + delay+".";
				return desc;
			}
			
			if (U.state && U.state.level.delay && delay)
				desc += " DELAY: " + delay + ".";
			return desc;
		}
		
		
		
		
		public function drive(port:Port):Value {
			return U.V_UNPOWERED;
		}
		
		public function get aggregateDelay():int {
			if (!U.state.level.delay)
				return 0;
			
			var maxDelay:int = 0;
			for each (var portLayout:PortLayout in layout.ports)
				if (!portLayout.port.isOutput)
					maxDelay = Math.max(maxDelay, portLayout.port.remainingDelay());
			return maxDelay;
		}
		
		public function initialize():void {
			if (U.state && U.state.level.delay)
				for each (var port:Port in outputs)
					port.clearDelay();
		}
		
		public function revertTo(oldValue:Value):void { }
		public function updateState():Boolean { return false; }
		public function setByConfig():void { }
		
		public function cacheValues():void {
			for each (var portLayout:PortLayout in layout.ports)
				portLayout.port.cacheValue();
		}
		
		public function clearCachedValues():void {
			for each (var portLayout:PortLayout in layout.ports)
				portLayout.port.clearCachedValue();
		}
		
		
		
		
		
		public function place():Module {
			deployed = true;
			
			var self:Module = this;
			
			iterContainedLines(function h(X:int, Y:int):void {
				U.state.grid.setLineContents(new Point(X, Y), new Point(X + 1, Y), self);
			}, function v(X:int, Y:int):void {
				U.state.grid.setLineContents(new Point(X, Y), new Point(X, Y + 1), self);
			});
			
			iterContainedPoints(function p(X:int, Y:int):void {
				U.state.grid.setPointContents(new Point(X, Y), self);
			});
			
			for each (var portLayout:PortLayout in layout.ports) {
				portLayout.register();
				portLayout.attemptConnect(); //asymmetric!
			}
			
			_lastPosition = null;
			
			return this;
		}
		
		public function manifest():Module {
			exists = true;
			
			if (!deployed)
				place();
			
			return this;
		}
		
		public function cleanup():void {
			deployed = false;
			
			for each (var portLayout:PortLayout in layout.ports)
				portLayout.port.cleanup();
			
			initialize();
		}
		
		public function lift():Module {
			for each (var portLayout:PortLayout in layout.ports)
				portLayout.deregister();
			
			iterContainedPoints(function p(X:int, Y:int):void {
				U.state.grid.setPointContents(new Point(X, Y), null);
			});
			
			iterContainedLines(function h(X:int, Y:int):void {
				U.state.grid.setLineContents(new Point(X, Y), new Point(X + 1, Y), null);
			}, function v(X:int, Y:int):void {
				U.state.grid.setLineContents(new Point(X, Y), new Point(X, Y + 1), null);
			});
			
			deployed = false;
			
			return this;
		}
		
		public function demanifest():Module {
			if (deployed)
				lift();
			
			for each (var portLayout:PortLayout in layout.ports)
				portLayout.port.disconnect(); //asymmetric!
			
			exists = false;
			
			return this;
		}
		
		private var _lastPosition:Point;
		private var _lastValid:Boolean;
		public function get validPosition():Boolean {
			if (deployed || !solid) return true;
			if (_lastPosition && equals(_lastPosition))
				return _lastValid;
			
			_lastPosition = clone();
			
			var OK:Object = { 'x' : true, 'y' : true, 'p' : true };
			var self:Module = this;
			iterContainedLines(function h(X:int, Y:int):void {
				if (!OK.x) return;
				var inLine:* = U.state.grid.lineContents(new Point(X, Y), new Point(X + 1, Y));
				OK.x = !inLine || self == inLine;
			}, function v(X:int, Y:int):void {
				if (!OK.y) return;
				var inLine:* = U.state.grid.lineContents(new Point(X, Y), new Point(X, Y + 1));
				OK.y = !inLine || self == inLine;
			});
			
			if (!OK.x || !OK.y)
				return _lastValid = false;
			
			iterContainedPoints(function p(X:int, Y:int):void {
				if (!OK.p) return;
				var point:Point = new Point(X, Y);
				if (U.state.grid.carriersAtPoint(point)) {
					OK.p = false;
					return;
				}
				var moduleAtPoint:Module = U.state.grid.moduleContentsAtPoint(point);
				OK.p = !moduleAtPoint || self == moduleAtPoint;
			});
			
			if (!OK.p)
				return _lastValid = false;
			
			for each (var portLayout:PortLayout in layout.ports)
				if (!portLayout.port.validPosition)
					return _lastValid = false;
			
			return _lastValid = true;
		}
		
		private function iterContainedLines(fH:Function, fV:Function):void {
			var topLeft:Point = this.topLeft;
			for (var X:int = topLeft.x; X < topLeft.x + layout.dim.x; X++)
				for (var Y:int = topLeft.y; Y < topLeft.y + layout.dim.y; Y++) {
					if (X < topLeft.x + layout.dim.x - 1)
						fH(X, Y);
					if (Y < topLeft.y + layout.dim.y - 1)
						fV(X, Y);
				}
		}
		
		private function iterContainedPoints(fP:Function):void {
			var topLeft:Point = this.topLeft;
			for (var X:int = topLeft.x; X < topLeft.x + layout.dim.x; X++)
				for (var Y:int = topLeft.y; Y < topLeft.y + layout.dim.y; Y++)
					fP(X, Y);
		}
		
		public function get topLeft():Point {
			return new Point(Math.ceil(x + layout.offset.x), Math.ceil(y + layout.offset.y));
		}
		
		public function getLinks():Vector.<Link> {
			var links:Vector.<Link> = new Vector.<Link>;
			for each (var port:PortLayout in layout.ports)
				for each (var link:Link in port.port.getLinks())
					links.push(link);
			return links;
		}
		
		public function getInLinks():Vector.<Link> {
			var links:Vector.<Link> = new Vector.<Link>;
			for each (var portList:Vector.<Port> in [inputs, controls])
				for each (var port:Port in portList)
					if (port.source)
						links.push(new Link(port.source, port));
			return links;
		}
		
		private const NO_CHILDREN:Vector.<Module> = new Vector.<Module>;
		public function getChildren():Vector.<Module> {
			return NO_CHILDREN;
		}
		
		
		
		public function fromConfig(type:Class, loc:Point):Module {
			var config:Configuration = getConfiguration();
			if (config)
				return new type(loc.x, loc.y, config.value);
			else
				return new type(loc.x, loc.y);
		}
		
		public function saveString():String {
			return getSaveValues().join(U.ARG_DELIM);
		}
		
		public function getSaveValues():Array {
			return [ALL_MODULES.indexOf(Object(this).constructor), x, y];
		}
		
		public function getBytes():ByteArray {
			var bytes:ByteArray = new ByteArray;
			var saveBytes:ByteArray = getSaveBytes();
			var length:int = 4 + 1 + 4 + 4 + saveBytes.length;
			bytes.writeInt(length);
			bytes.writeByte(ALL_MODULES.indexOf(Object(this).constructor));
			bytes.writeInt(x);
			bytes.writeInt(y);
			bytes.writeBytes(saveBytes);
			if (bytes.length != length)
				throw new Error("Error in length generation!");
			
			bytes.position = 0;
			return bytes;
		}
		
		protected function getSaveBytes():ByteArray {
			var bytes:ByteArray = new ByteArray();
			var saveValues:Array = getSaveValues();
			for each (var value:int in saveValues.slice(3))
				bytes.writeByte(value);
			return bytes;
		}
		
		
		
		public static function fromString(str:String, allowableTypes:Vector.<Class> = null):Module {
			if (!str.length) return null;
			
			var args:Array = str.split(U.ARG_DELIM);
			var type:Class = ALL_MODULES[C.safeInt(args[0])];
			if (type == CustomModule)
				return CustomModule.fromArgs(args.slice(1));
			if (!type || (allowableTypes && allowableTypes.indexOf(type) == -1))
				return null;
			
			var x:int = C.safeInt(args[1]);
			var y:int = C.safeInt(args[2]);
			if (args.length > 4) {
				var furtherArgs:Array = [];
				for each (var furtherArg:String in args.slice(3))
					furtherArgs.push(C.safeInt(furtherArg))
				return new type(x, y, furtherArgs)
			}
			if (args.length >= 4)
				return new type(x, y, C.safeInt(args[3]))
			return new type(x, y);
		}
		
		public static function fromBytes(bytes:ByteArray, end:int, allowableTypes:Vector.<Class> = null):Module {
			var moduleIndex:int = bytes.readByte();
			var moduleType:Class = ALL_MODULES[moduleIndex];
			if (!moduleType || (allowableTypes && allowableTypes.indexOf(moduleType) == -1))
				return null;
			
			var x:int = bytes.readInt();
			var y:int = bytes.readInt();
			if (bytes.position == end)
				return new moduleType(x, y);
			if (bytes.position == end - 1)
				return new moduleType(x, y, bytes.readByte());
			if (moduleType == InstructionDemux)
				return InstructionDemux.fromBytes(x, y, bytes, end);
			if (moduleType == CustomModule)
				return CustomModule.fromBytes(x, y, bytes, end, allowableTypes);
			throw new Error("Unknown 'special module' type!");
		}
		
		public static function modulesFromBytes(bytes:ByteArray, end:int, allowableTypes:Vector.<Class> = null):Vector.<Module> {
			var modules:Vector.<Module> = new Vector.<Module>;
			while (bytes.position < end) {
				var moduleLength:int = bytes.readInt();
				var moduleEnd:int = bytes.position - 4 + moduleLength;
				var module:Module = fromBytes(bytes, moduleEnd, allowableTypes);
				if (module)
					modules.push(module);
				if (bytes.position != moduleEnd)
					throw new Error("Unread data in module load!");
			}
			return modules;
		}
		
		
		
		
		public static function init():void {
			ModuleCategory.init();
			
			for each (var moduleClass:Class in [Adder, null, null, ConstIn, Latch,
												Equals, null, null, null, null,
												Mux, Demux, InstructionMux, InstructionDemux,
												Or, Output, And, Not, null, DataWriter,
												InstructionComparator, null, Latch, SysDelayClock,
												MagicWriter, DataReader, InstructionDecoder,
												CustomModule, Subtractor, Multiplier, Divider,
												SlowAdder, LatchQ]) {
				ALL_MODULES.push(moduleClass);
				if (!moduleClass || moduleClass == CustomModule)
					ARCHETYPES.push(null);
				else
					ARCHETYPES.push(new moduleClass( -1, -1));
			}
		}
		
		public static function getArchetype(moduleClass:Class):Module {
			return ARCHETYPES[ALL_MODULES.indexOf(moduleClass)];
		}
		
		public static const ALL_MODULES:Vector.<Class> = new Vector.<Class>;
		public static const ARCHETYPES:Vector.<Module> = new Vector.<Module>;
	}

}