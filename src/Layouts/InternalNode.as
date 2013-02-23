package Layouts {
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
		public var getValue:Function;
		public var offset:Point;
		public function InternalNode(Parent:Module, Offset:Point, Connections:Array, GetValue:Function = null, Name:String = null) {
			name = Name;
			getValue = GetValue;
			parent = Parent;
			offset = Offset;
			connections = new Vector.<Node>;
			if (Connections)
				for each (var node:Node in Connections)
					connections.push(node);
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
		
	}

}