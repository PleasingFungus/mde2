package Components {
	import Modules.Module;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public interface Carrier {
		function getConnections():Vector.<Carrier>;
		function isSource():Boolean;
		function getSource():Port;
		function removeConnection(connection:Carrier):void;
		function resetSource():void;
		function setSource(source:Port):void;
		function addConnection(connection:Carrier):void;
	}
	
}