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
				for each (var iNode:InternalNode in controls)
					controls.push(iNode);
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
		
		public function buildConnections():Vector.<Wire> {
			var wires:Vector.<Wire> = new Vector.<Wire>;
			for each (var connection:Node in connections)
				if (connection is PortLayout)
					wires.push(new InternalWire(connection.Loc, Loc, false,
												(connection as PortLayout).port.getSource,
												(connection as PortLayout).port.getValue));
				else
					wires.push(new InternalWire(connection.Loc, Loc, false, _true, getValue));
			for each (var control:InternalNode in controls)
				wires.push(new InternalWire(control.Loc, Loc, false, _true, control.getValue != null ? control.getValue : getValue));
			return wires;
		}
		
		private function _true():Boolean { return true; }
		
	}

}