package Layouts.Nodes {
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public interface Node {
		function get Loc():Point;
		function remainingDelay():int;
	}
	
}