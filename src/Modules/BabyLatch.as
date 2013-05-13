package Modules {
	import Components.Port;
	import Values.*
	import Layouts.*;
	import Layouts.Nodes.StandardNode;
	import Layouts.Nodes.NodeType;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class BabyLatch extends StatefulModule {
		
		public function BabyLatch(X:int, Y:int, InitialValue:int = 0) {
			super(X, Y, "Basic Storage", ModuleCategory.STORAGE, 1, 1, 0, InitialValue);
			abbrev = "l";
			symbol = _symbol;
			delay = 1;
			storesData = true;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			var dataNode:StandardNode = new StandardNode(this, new Point(layout.ports[1].offset.x - 2, layout.ports[1].offset.y), [layout.ports[0], layout.ports[1]], [],
														function getValue():Value { return value; }, "Stored value")
			dataNode.type = NodeType.STORAGE;
			return new InternalLayout([dataNode]);
		}
		
		override public function renderDetails():String {
			return "LCH" +"\n\n" + value;
		}
		
		override public function getDescription():String {
			return "Stores & outputs a value. Each tick, sets its value to the input."
		}
		
		override public function drive(port:Port):Value {
			return value;
		}
		
		override protected function statefulUpdate():Boolean {
			var input:Value = inputs[0].getValue();
			if (input.unpowered)
				return false;
			
			U.state.time.deltas.push(new Delta(U.state.time.moment, this, value));
			value = input;
			return true;
		}
		
		[Embed(source = "../../lib/art/modules/symbol_box_unlocked_24.png")] private const _symbol:Class;
	}

}