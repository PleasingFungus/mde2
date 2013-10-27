package Menu {
	import Displays.DNode;
	import Layouts.Nodes.InternalNode;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DStatNode extends DNode {
		
		private var statNode:StatNode;
		public function DStatNode(node:InternalNode) {
			super(node);
			statNode = node as StatNode;
		}
		
	}

}