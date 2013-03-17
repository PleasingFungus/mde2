package Layouts.Nodes {
	import Components.Port;
	import Components.Wire;
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
					out += ":"
				
				out += getValue();
			}
			
			return out;
		}
		
		public function get Loc():Point {
			return parent.add(offset);
		}
		
		protected function buildConnections():Vector.<InternalWire> {
			var wires:Vector.<InternalWire> = new Vector.<InternalWire>;
			var bounds:Rectangle = parent.layout.getBounds();
			
			for each (var connection:Node in connections)
				if (connection is PortLayout) {
					var pLayout:PortLayout = connection as PortLayout;
					
					wires.push(new InternalWire(Loc, pLayout.Loc, bounds,
												isSource ? _true : pLayout.port.getSource,
												isSource ? getValue : pLayout.port.getValue));
				} else {
					var wire:InternalWire = new InternalWire(connection.Loc, Loc, bounds, _true, getValue);
					wire.reversed = true;
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
		
		private function _true():Boolean { return true; }
		
	}

}