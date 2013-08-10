package Modules {
	import Layouts.Nodes.InternalNode;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public interface Clockable {
		function getClockNode():InternalNode;
		function getClockFraction():Number;
	}
	
}