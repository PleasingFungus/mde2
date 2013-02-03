package Modules {
	//import Displays.DModule;
	import flash.geom.Point;
	import Layouts.DefaultLayout;
	import Layouts.ModuleLayout;
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
		
		public function Module(X:int, Y:int, Name:String, numInputs:int, numOutputs:int, numControls:int, Layout:ModuleLayout = null ) {
			super(X, Y);
			
			name = Name;
			inputs = new Vector.<Port>; populatePorts(inputs, numInputs, false);
			outputs = new Vector.<Port>; populatePorts(outputs, numOutputs, true);
			controls = new Vector.<Port>; populatePorts(controls, numControls, false);
			
			layout = Layout ? Layout : new DefaultLayout(this);
			
			initialize();
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
		
		public function severConnections():void {
			var port:Port;
			for each (port in inputs) if (port.connection) port.connection.removeConnection(port);
			for each (port in controls) if (port.connection) port.connection.removeConnection(port);
			for each (port in outputs)
				if (port.connection) {
					port.connection.removeConnection(port);
					port.connection.resetSource();
				}
		}
		
		public function saveString():String {
			return getSaveValues().join(DELIM) + U.SAVE_DELIM;
		}
		
		protected function getSaveValues():Array {
			return [U.ALL_MODULES.indexOf(Object(this).constructor), x, y];
		}
		
		public function initialize():void { }
		public function revertTo(oldValue:Value):void { }
		public function update():Boolean { return false; }
		public function finishUpdate():void { }
		
		
		public static function fromString(str:String):Module {
			var args:Array = str.split(DELIM);
			var type:Class = U.ALL_MODULES[int(args[0])];
			if (!type) return null;
			var x:int = int(args[1]);
			var y:int = int(args[2]);
			if (args.length > 3)
				return new type(x, y, int(args[3]))
			return new type(x, y);
		}
		
		private static const DELIM:String = ',';
		
		
		
		
	}

}