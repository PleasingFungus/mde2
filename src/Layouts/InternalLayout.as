package Layouts {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InternalLayout {
		
		public var nodes:Vector.<InternalNode>;
		public var wires:Vector.<InternalWire>;
		public function InternalLayout(Nodes:Array) {
			nodes = new Vector.<InternalNode>;
			wires = new Vector.<InternalWire>;
			if (Nodes)
				for each (var node:InternalNode in Nodes) {
					nodes.push(node);
					for each (var wire:InternalWire in node.internalWires)
						wires.push(wire);
				}
			
			for each (node in Nodes)
				for each (var tuple:NodeTuple in node.controlTuples) {
					wires.push(wire = new InternalControlWire(node, tuple, wires));
					node.internalWires.push(wire);
				}
		}
		
	}

}