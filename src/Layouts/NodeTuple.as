package Layouts {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class NodeTuple {

		public var a:Node;
		public var b:Node;
		public var isEnabled:Function
		public function NodeTuple(A:Node, B:Node, IsEnabled:Function ) {
			a = A;
			b = B;
			isEnabled = IsEnabled;
		}
		
	}

}