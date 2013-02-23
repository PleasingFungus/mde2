package Layouts {
	import Components.Port;
	import Components.Wire;
	import Modules.Module;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InternalNode implements Node {
		
		public var name:String;
		public var parent:Module;
		public var connections:Vector.<Node>
		public var controls:Vector.<InternalNode>;
		public var internalWires:Vector.<InternalWire>;
		public var getValue:Function;
		public var offset:Point;
		public function InternalNode(Parent:Module, Offset:Point, Connections:Array, Controls:Array = null, GetValue:Function = null, Name:String = null) {
			name = Name;
			getValue = GetValue;
			parent = Parent;
			offset = Offset;
			
			connections = new Vector.<Node>;
			if (Connections)
				for each (var node:Node in Connections)
					connections.push(node);
			
			controls = new Vector.<InternalNode>;
			if (Controls)
				for each (var iNode:InternalNode in Controls)
					controls.push(iNode);
			
			internalWires = buildConnections();
		}
		
		public function getLabel():String {
			var out:String = "";
			
			if (name != null)
				out += name;
			
			if (getValue != null) {
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
			for each (var connection:Node in connections)
				if (connection is PortLayout) {
					var pLayout:PortLayout = connection as PortLayout;
					
					var start:Point = pLayout.Loc;
					var end:Point = Loc;
					if (pLayout.port.isOutput) {
						start = Loc;
						end = pLayout.Loc;
					}
					
					wires.push(new InternalWire(start, end, pLayout.port.isOutput, false, pLayout.port.getSource,	pLayout.port.getValue));
				} else
					wires.push(new InternalWire(Loc, connection.Loc, false, false, _true, getValue));
			for each (var control:InternalNode in controls)
				wires.push(new InternalWire(control.Loc, Loc, false, true, _true, control.getValue != null ? control.getValue : getValue));
			return wires;
		}
		
		public function updatePosition():void {
			for each (var wire:InternalWire in internalWires)
				wire.shiftTo(Loc);
		}
		
		private function _true():Boolean { return true; }
		
	}

}