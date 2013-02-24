package Modules {
	import Components.Port;
	import Layouts.NodeTuple;
	import Values.*
	
	import Layouts.ModuleLayout;
	import Layouts.PortLayout;
	import Layouts.InternalLayout;
	import Layouts.InternalNode;
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
			var dataNode:InternalNode = new InternalNode(this, new Point(layout.ports[2].offset.x - 2, layout.ports[2].offset.y), [layout.ports[0], layout.ports[2]], [],
														 function getValue():Value { return value; });
			var controlNode:InternalNode = new InternalNode(this, new Point(layout.ports[1].offset.x, layout.ports[1].offset.y + 2), [layout.ports[1]],
															[new NodeTuple(layout.ports[0], dataNode, writeOK)],
															function getValue():BooleanValue { return writeOK() ? BooleanValue.TRUE : BooleanValue.FALSE; } , "W");
			return new InternalLayout([controlNode, dataNode]);
		}
		
		override public function renderName():String {
			return "LCH" +"\n\n" + value;
		}
		
		override public function drive(port:Port):Value {
			return value;
		}
		
		override protected function statefulUpdate():Boolean {
			if (!writeOK())
				return false;
			
			var input:Value = inputs[0].getValue();
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