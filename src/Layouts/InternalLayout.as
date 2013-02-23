package Layouts {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InternalLayout {
		
		public var nodes:Vector.<InternalNode>
		public function InternalLayout(Nodes:Array) {
			nodes = new Vector.<InternalNode>;
			if (Nodes)
				for each (var node:InternalNode in Nodes)
					nodes.push(node);
		}
		
	}

}