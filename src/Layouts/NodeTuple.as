package Layouts {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class NodeTuple {

		public var a:Node;
		public var b:Node;
		public var IsEnabled:Function
		public var param:*;
		public function NodeTuple(A:Node, B:Node, IsEnabled:Function, Param:* = null ) {
			a = A;
			b = B;
			this.IsEnabled = IsEnabled;
			param = Param;
		}
		
		public function isEnabled():Boolean {
			if (param == null)
				return IsEnabled();
			return IsEnabled(param);
		}
	}

}