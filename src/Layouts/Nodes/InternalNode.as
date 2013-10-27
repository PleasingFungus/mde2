package Layouts.Nodes {
	import Components.Port;
	import Components.Wire;
	import Displays.DNode;
	import flash.geom.Rectangle;
	import Modules.Module;
	import flash.geom.Point;
	import Values.Value;
	import Layouts.InternalWire;
	import Layouts.PortLayout;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InternalNode implements Node {
		
		public var name:String;
		public var type:NodeType;
		public var parent:Module;
		public var connections:Vector.<Node>
		public var controlTuples:Vector.<NodeTuple>;
		public var internalWires:Vector.<InternalWire>;
		public var GetValue:Function;
		public var dim:Point;
		public var offset:Point;
		public var param:*;
		public var isSource:Boolean;
		public function InternalNode(Parent:Module, Dim:Point, Offset:Point, Connections:Array,
									 ControlTuples:Array = null, GetValue:Function = null, Name:String = null,
									 IsSource:Boolean = false, Param:* = null) {
			name = Name;
			type = NodeType.DEFAULT;
			dim = Dim;
			this.GetValue = GetValue;
			isSource = IsSource;
			param = Param;
			parent = Parent;
			offset = Offset;
			
			connections = new Vector.<Node>;
			if (Connections)
				for each (var node:Node in Connections)
					connections.push(node);
			
			controlTuples = new Vector.<NodeTuple>;
			if (ControlTuples)
				for each (var controlTuple:NodeTuple in ControlTuples)
					controlTuples.push(controlTuple);
			
			internalWires = buildConnections();
		}
		
		public function getLabel():String {
			var out:String = "";
			
			if (name != null)
				out += name;
			
			if (GetValue != null) {
				if (out)
					out += ": "
				
				out += getValue();
			}
			
			if (U.state.level.delay) {
				var delay:int = inputDelay();
				if (delay)
					out += " (D" + delay + ")";
			}
			
			return out;
		}
		
		public function generateDisplay():DNode {
			return new DNode(this);
		}
		
		public function get Loc():Point {
			return parent.add(offset);
		}
		
		protected function buildConnections():Vector.<InternalWire> {
			var wires:Vector.<InternalWire> = new Vector.<InternalWire>;
			var bounds:Rectangle = parent.layout.getBounds();
			
			for each (var connection:Node in connections) {
				var wire:InternalWire;
				var reversed:Boolean = Loc.x > connection.Loc.x;
				var start:Point = reversed ? connection.Loc : Loc;
				var end:Point = reversed ? Loc : connection.Loc;
				if (connection is PortLayout) {
					var pLayout:PortLayout = connection as PortLayout;
					wire = new InternalWire(start, end, bounds,
											isSource ? _true : pLayout.port.getSource,
											isSource ? getValue : pLayout.port.getValue);
				} else
					wire = new InternalWire(start, end, bounds, _true, getValue);
				wire.reversed = reversed;
				wires.push(wire);
			}
			
			return wires;
		}
		
		public function updatePosition():void {
			for each (var wire:InternalWire in internalWires)
				wire.shiftTo(Loc);
		}
		
		public function update():void {
			for each (var wire:InternalWire in internalWires)
				wire.update();
		}
		
		public function getValue():Value {
			if (param != null)
				return GetValue(param);
			return GetValue();
		}
		
		public function remainingDelay():int {
			return 0; //eh
		}
		
		public function inputDelay():int {
			var delay:int = 0;
			if (U.state && U.state.level.delay)
				for each (var node:Node in connections)
					delay = Math.max(node.remainingDelay(), delay)
			return delay;
		}
		
		private function _true():Boolean { return true; }
		
		
		public static const DIM_STANDARD:Point = new Point(2, 2);
		public static const DIM_WIDE:Point = new Point(4, 2);
		public static const DIM_TALL:Point = new Point(2, 4);
		public static const DIM_BIG:Point = new Point(6, 4);
		public static const DIM_BIG_AND_TALL:Point = new Point(4, 6);
	}

}