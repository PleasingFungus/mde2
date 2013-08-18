package Modules {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SlowAdder extends Adder {
		
		public function SlowAdder(X:int, Y:int) {
			super(X, Y);
			name = "Slow Adder";
			delay = 10;
		}
		
	}

}