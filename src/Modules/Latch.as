package Modules {
	import Components.Port;
	import Values.*
	import Layouts.*;
	import Layouts.Nodes.StandardNode;
	import Layouts.Nodes.NodeTuple;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Latch extends StatefulModule {
		
		public function Latch(X:int, Y:int, InitialValue:int = 0) {
			super(X, Y, "Latch", Module.CAT_STORAGE, 1, 1, 1, InitialValue);
			//configuration = new Configuration(new Range( -32, 31, InitialValue));
			delay = 2;
		}
		
		override protected function generateLayout():ModuleLayout {
			var layout:ModuleLayout = super.generateLayout();
			layout.ports[0].offset.y += 2;
			layout.ports[2].offset.y += 2;
			return layout;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			var dataNode:StandardNode = new StandardNode(this, new Point(layout.ports[2].offset.x - 2, layout.ports[2].offset.y), [layout.ports[0], layout.ports[2]], [],
														 function getValue():Value { return value; }, "Stored value");
			var controlNode:StandardNode = new StandardNode(this, new Point(layout.ports[1].offset.x, layout.ports[1].offset.y + 2), [layout.ports[1]],
															[new NodeTuple(layout.ports[0], dataNode, writeOK)],
															function getValue():BooleanValue { return writeOK() ? BooleanValue.TRUE : BooleanValue.FALSE; }, "Stored value will be set to input value");
			return new InternalLayout([controlNode, dataNode]);
		}
		
		override public function renderName():String {
			return "LCH" +"\n\n" + value;
		}
		
		override public function getDescription():String {
			return "Stores & continuously outputs a value. Each tick, sets its value to the input if the control is "+BooleanValue.TRUE+"."
		}
		
		override public function drive(port:Port):Value {
			return value;
		}
		
		override protected function statefulUpdate():Boolean {
			if (!writeOK())
				return false;
			
			var input:Value = inputs[0].getValue();
			if (input.unpowered)
				return false;
			
			U.state.time.deltas.push(new Delta(U.state.time.moment, this, value));
			value = input;
			return true;
		}
		
		protected function writeOK():Boolean {
			var control:Value = controls[0].getValue();
			return control != U.V_UNKNOWN && control != U.V_UNPOWERED && control.toNumber() != 0;
		}
		
	}

}