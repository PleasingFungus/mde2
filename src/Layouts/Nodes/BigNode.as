package Layouts.Nodes {
	import flash.geom.Point;
	import Modules.Module;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class BigNode extends InternalNode {
		
		public function BigNode(Parent:Module, Offset:Point, Connections:Array, ControlTuples:Array=null, GetValue:Function=null, Name:String=null, IsSource:Boolean=false, Param:*=null) {
			super(Parent, DIM, Offset, Connections, ControlTuples, GetValue, Name, IsSource, Param);
			
		}
		
		private const DIM:Point = new Point(6, 4);
	}

}