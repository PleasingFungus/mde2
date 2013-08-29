package Modules {
	import UI.HighlightFormat;
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class LatchQ extends Latch {
		
		public function LatchQ(X:int, Y:int, Width:int=1) {
			super(X, Y, Width);
			name += "?";
		}
		
		override protected function get initializerValue():Value {
			return U.V_UNKNOWN;
		}
		
		override public function getDescription():String {
			return "Storage that initially stores "+initializerValue+".";
		}
		
		override public function getHighlitDescription():HighlightFormat {
			return null;
		}
	}

}