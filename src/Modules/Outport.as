package Modules {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Outport extends Module {
		
		public function Outport(X:int, Y:int) {
			super(X, Y, "Out", 1, 0, 0);
		}
		
		override public function renderName():String {
			return name + "\n\n" + inputs[0].getValue();
		}
	}

}