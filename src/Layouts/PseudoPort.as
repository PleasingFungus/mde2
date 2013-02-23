package Layouts {
	import Components.Port;
	import Modules.Module;
	import Values.Value;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class PseudoPort extends Port {
		
		public var node:InternalNode;
		public function PseudoPort(Parent:InternalNode) {
			super(true, Parent.parent);
			node = Parent;
			
		}
		
		override public function getValue():Value {
			return node.getValue();
		}
		
	}

}