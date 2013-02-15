package Values {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class IndexedValue extends Value {
		
		public var subValue:Value;
		public var index:int;
		public function IndexedValue(SubValue:Value, Index:int) {
			super();
			subValue = SubValue;
			index = Index;
		}
		
	}

}