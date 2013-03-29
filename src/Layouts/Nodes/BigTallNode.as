package Layouts.Nodes {
	import flash.geom.Point;
	import Modules.Module;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class BigTallNode extends InternalNode {
		
		public function BigTallNode(Parent:Module, Offset:Point, Connections:Array, ControlTuples:Array=null, GetValue:Function=null, Name:String=null, IsSource:Boolean=false, Param:*=null) {
			super(Parent, DIM_BIG_AND_TALL, Offset, Connections, ControlTuples, GetValue, Name, IsSource, Param);
			
		}
	}

}