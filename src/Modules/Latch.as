package Modules {
	import Components.Port;
	import Values.Delta;
	import Values.FixedValue;
	import Values.BooleanValue;
	import Values.Value;
	
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
			var kludge:Latch = this;
			var controlNode:InternalNode = new InternalNode(this, new Point(layout.ports[1].offset.x, layout.ports[1].offset.y + 2), [layout.ports[1]], [],
															function getValue():BooleanValue { return BooleanValue.fromValue(kludge.controls[0].getValue()); } , "W");
			var dataNode:InternalNode = new InternalNode(this, new Point(controlNode.offset.x, layout.ports[0].offset.y), [layout.ports[0], layout.ports[2]], [controlNode],
														 function getValue():Value { return value; });
			return new InternalLayout([controlNode, dataNode]);
		}
		
		override public function renderName():String {
			return "LCH" +"\n\n" + value;
		}
		
		override public function drive(port:Port):Value {
			return value;
		}
		
		override protected function statefulUpdate():Boolean {
			var control:Value = controls[0].getValue();
			if (control == U.V_UNKNOWN || control == U.V_UNPOWERED || control.toNumber() == 0)
				return false;
			
			var input:Value = inputs[0].getValue();
			U.state.time.deltas.push(new Delta(U.state.time.moment, this, value));
			value = input;
			return true;
		}
		
	}

}