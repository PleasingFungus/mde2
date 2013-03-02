package  {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Range {
		
		public var min:int;
		public var max:int;
		public var initial:int;
		public function Range(Min:int = 0, Max:int = 255, Initial:Number = NaN) {
			min = Min;
			max = Max;
			initial = !isNaN(Initial) ? Initial : midpoint;
		}
		
		public function get width():int { return max - min; }
		
		public function get midpoint():int { return width / 2 + min; }
		
		public function nameOf(value:int):String {
			return String(value);
		}
		
	}

}