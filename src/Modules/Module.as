package Modules {
	//import Displays.DModule;
	import Displays.DModule;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import Layouts.DefaultLayout;
	import Layouts.ModuleLayout;
	import Layouts.PortLayout;
	//import Components.Wire;
	import Components.Port;
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Module extends Point {
		
		public var name:String;
		public var configuration:Configuration;
		public var layout:ModuleLayout;
		
		public var inputs:Vector.<Port>;
		public var outputs:Vector.<Port>;
		public var controls:Vector.<Port>;
		
		public var delay:int;
		
		public var exists:Boolean = true;
		public var FIXED:Boolean = false;
		public var dirty:Boolean;
		
		//public var display:DModule;
		
		public function Module(X:int, Y:int, Name:String, numInputs:int, numOutputs:int, numControls:int ) {
			super(X, Y);
			
			name = Name;
			inputs = new Vector.<Port>; populatePorts(inputs, numInputs, false);
			outputs = new Vector.<Port>; populatePorts(outputs, numOutputs, true);
			controls = new Vector.<Port>; populatePorts(controls, numControls, false);
			
			layout = generateLayout();
			
			initialize();
		}
		
		protected function generateLayout():ModuleLayout {
			return new DefaultLayout(this);
		}
		
		public function generateDisplay():DModule {
			return new DModule(this);
		}
		
		private function populatePorts(ports:Vector.<Port>, numPorts:int, isOutput:Boolean):void {
			for (var i:int = 0; i < numPorts; i++)
				ports.push(new Port(isOutput, this));
		}
		
		public function renderName():String {
			return name;
		}
		
		public function drive(port:Port):Value {
			return U.V_UNPOWERED;
		}
		
		public function saveString():String {
			return getSaveValues().join(DELIM) + U.SAVE_DELIM;
		}
		
		protected function getSaveValues():Array {
			return [ALL_MODULES.indexOf(Object(this).constructor), x, y];
		}
		
		public function initialize():void {
			if (U.state && U.state.level.delay)
				for each (var port:Port in outputs)
					port.clearDelay();
		}
		
		public function revertTo(oldValue:Value):void { }
		public function update():Boolean { return false; }
		
		public function register():Module {
			exists = true;
			
			var self:Module = this;
			
			iterContainedLines(function h(X:int, Y:int):void {
				U.state.setLineContents(new Point(X, Y), new Point(X + 1, Y), self);
			}, function v(X:int, Y:int):void {
				U.state.setLineContents(new Point(X, Y), new Point(X, Y + 1), self);
			});
			
			for each (var portLayout:PortLayout in layout.ports) {
				portLayout.register();
				portLayout.attemptConnect();
			}
			
			return this;
		}
		
		public static function place(m:Module):Module {
			return m.register();
		}
		
		public function deregister():Module {
			iterContainedLines(function h(X:int, Y:int):void {
				U.state.setLineContents(new Point(X, Y), new Point(X + 1, Y), null);
			}, function v(X:int, Y:int):void {
				U.state.setLineContents(new Point(X, Y), new Point(X, Y + 1), null);
			});
			
			for each (var portLayout:PortLayout in layout.ports) {
				portLayout.disconnect();
				portLayout.deregister();
			}
			
			exists = false;
			
			return this;
		}
		
		public static function remove(m:Module):Module {
			return m.deregister();
		}
		
		public function get validPosition():Boolean {
			var OK:Object = { 'x' : true, 'y' : true };
			var self:Module = this;
			iterContainedLines(function h(X:int, Y:int):void {
				if (!OK.x) return;
				var inLine:* = U.state.lineContents(new Point(X, Y), new Point(X + 1, Y));
				OK.x = !inLine || self == inLine;
			}, function v(X:int, Y:int):void {
				if (!OK.y) return;
				var inLine:* = U.state.lineContents(new Point(X, Y), new Point(X, Y + 1));
				OK.y = !inLine || self == inLine;
			});
			
			if (!OK.x || !OK.y)
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
		
		public function get topLeft():Point {
			return new Point(Math.ceil(x + layout.offset.x), Math.ceil(y + layout.offset.y));
		}
		
		
		public static function fromString(str:String):Module {
			var args:Array = str.split(DELIM);
			var type:Class = ALL_MODULES[int(args[0])];
			if (!type) return null;
			var x:int = int(args[1]);
			var y:int = int(args[2]);
			if (args.length > 3)
				return new type(x, y, int(args[3]))
			return new type(x, y);
		}
		
		private static const DELIM:String = ',';
		
		public static function init():void {
			for each (var moduleClass:Class in [Adder, ASU, Clock, ConstIn, Latch,
												Outport, Regfile, Comparator,
												InstructionMemory, DataMemory,
												Mux, Demux, InstructionMux, InstructionDemux,
												Accumulator, ProgramCounter, And, Not, Delay, LongClock]) {
				ALL_MODULES.push(moduleClass);
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