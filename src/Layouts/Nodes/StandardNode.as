package Layouts.Nodes {
	import flash.geom.Point;
	import Modules.Module;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class StandardNode extends InternalNode {
		
		public function StandardNode(Parent:Module, Offset:Point, Connections:Array, ControlTuples:Array=null, GetValue:Function=null, Name:String=null, IsSource:Boolean=false, Param:*=null) {
			super(Parent, DIM_STANDARD, Offset, Connections, ControlTuples, GetValue, Name, IsSource, Param);
			
		}
	}

}