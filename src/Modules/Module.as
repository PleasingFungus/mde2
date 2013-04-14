package Modules {
	import Displays.DModule;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import Layouts.*;
	import Components.Port;
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Module extends Point {
		
		public var name:String;
		public var category:String;
		protected var configuration:Configuration;
		public var configurableInPlace:Boolean;
		public var layout:ModuleLayout;
		public var internalLayout:InternalLayout;
		public var writesToMemory:Boolean = false;
		public var storesData:Boolean = false;
		
		public var inputs:Vector.<Port>;
		public var outputs:Vector.<Port>;
		public var controls:Vector.<Port>;
		
		public var delay:int;
		
		public var exists:Boolean = true;
		public var deployed:Boolean = false;
		public var FIXED:Boolean = false;
		public var dirty:Boolean;
		
		public function Module(X:int, Y:int, Name:String, Category:String, numInputs:int, numOutputs:int, numControls:int ) {
			super(X, Y);
			
			name = Name;
			category = Category;
			makePorts(numInputs, numOutputs, numControls);
			
			layout = generateLayout();
			internalLayout = generateInternalLayout();
			
			configurableInPlace = true;
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
		
		protected function generateLayout():ModuleLayout {
			return new DefaultLayout(this);
		}
		
		protected function generateInternalLayout():InternalLayout {
			return null;
		}
		
		public function generateDisplay():DModule {
			return new DModule(this);
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
		
		public function saveString():String {
			return getSaveValues().join(U.ARG_DELIM);
		}
		
		public function getSaveValues():Array {
			return [ALL_MODULES.indexOf(Object(this).constructor), x, y];
		}
		
		public function initialize():void {
			if (U.state && U.state.level.delay)
				for each (var port:Port in outputs)
					port.clearDelay();
		}
		
		public function revertTo(oldValue:Value):void { }
		public function updateState():Boolean { return false; }
		public function setByConfig():void { }
		
		public function updateDelays():void {
			for each (var port:Port in outputs)
				port.updateDelay();
		}
		
		public function lastMinuteInit():void {
			for each (var port:Port in outputs)
				port.lastMinuteInit();
		}
		
		public function cacheValues():void {
			for each (var portLayout:PortLayout in layout.ports)
				portLayout.port.cacheValue();
		}
		
		public function clearCachedValues():void {
			for each (var portLayout:PortLayout in layout.ports)
				portLayout.port.clearCachedValue();
		}
		
		
		public function register():Module {
			exists = true;
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
				portLayout.attemptConnect();
			}
			
			return this;
		}
		
		public static function place(m:Module, at:Point = null):Module {
			if (at) {
				m.x = at.x;
				m.y = at.y;
			}
			return m.register();
		}
		
		public function cleanup():void {
			deployed = false;
			exists = false;
			
			for each (var portLayout:PortLayout in layout.ports)
				portLayout.port.cleanup();
		}
		
		public function deregister():Module {
			for each (var portLayout:PortLayout in layout.ports) {
				portLayout.disconnect();
				portLayout.deregister();
			}
			
			iterContainedPoints(function p(X:int, Y:int):void {
				U.state.grid.setPointContents(new Point(X, Y), null);
			});
			
			iterContainedLines(function h(X:int, Y:int):void {
				U.state.grid.setLineContents(new Point(X, Y), new Point(X + 1, Y), null);
			}, function v(X:int, Y:int):void {
				U.state.grid.setLineContents(new Point(X, Y), new Point(X, Y + 1), null);
			});
			
			deployed = false;
			exists = false;
			
			return this;
		}
		
		public static function remove(m:Module, at:Point = null):Module {
			return m.deregister();
		}
		
		public function get validPosition():Boolean {
			if (deployed) return true;
			
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
				return false;
			
			iterContainedPoints(function p(X:int, Y:int):void {
				if (!OK.p) return;
				var point:Point = new Point(X, Y);
				var pointContents:Class = U.state.grid.objTypeAtPoint(point);
				if (pointContents != Module) {
					if (pointContents != null)
						OK.p = false;
					return;
				}
				OK.p = self == U.state.grid.moduleContentsAtPoint(point);
			});
			
			if (!OK.p)
				return false;
			
			for each (var portLayout:PortLayout in layout.ports)
				if (!portLayout.validPosition)
					return false;
			
			return true;
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
		
		public static function init():void {
			for each (var moduleClass:Class in [Adder, ASU, Clock, ConstIn, Latch,
												Equals, Regfile, Comparator,
												InstructionMemory, DataMemory,
												Mux, Demux, InstructionMux, InstructionDemux,
												Or, Output, And, Not, Delay, DataWriter,
												InstructionComparator, MDU, BabyLatch, SysDelayClock,
												MagicWriter, DataReader, DataWriterT, InstructionDecoder,
												CustomModule]) {
				ALL_MODULES.push(moduleClass);
				if (moduleClass != CustomModule)
					ARCHETYPES.push(new moduleClass( -1, -1));
			}
			
			for each (var category:String in [CAT_CONTROL, CAT_STORAGE, CAT_LOGIC, CAT_ARITH, CAT_MISC])
				ALL_CATEGORIES.push(category);
		}
		
		public static function getArchetype(moduleClass:Class):Module {
			return ARCHETYPES[ALL_MODULES.indexOf(moduleClass)];
		}
		
		public static const ALL_MODULES:Vector.<Class> = new Vector.<Class>;
		public static const ARCHETYPES:Vector.<Module> = new Vector.<Module>;
		
		public static const CAT_ARITH:String = "Arithmetic";
		public static const CAT_LOGIC:String = "Logic";
		public static const CAT_STORAGE:String = "Storage";
		public static const CAT_CONTROL:String = "Control";
		public static const CAT_MISC:String = "Misc.";
		public static const ALL_CATEGORIES:Vector.<String> = new Vector.<String>;
	}

}