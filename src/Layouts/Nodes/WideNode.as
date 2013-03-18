package Layouts.Nodes {
	import flash.geom.Point;
	import Modules.Module;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class WideNode extends InternalNode {
		
		public function WideNode(Parent:Module, Offset:Point, Connections:Array, ControlTuples:Array=null, GetValue:Function=null, Name:String=null, IsSource:Boolean=false, Param:*=null) {
			super(Parent, DIM, Offset, Connections, ControlTuples, GetValue, Name, IsSource, Param);
			
		}
		
		private const DIM:Point = new Point(4, 2);
	}

}