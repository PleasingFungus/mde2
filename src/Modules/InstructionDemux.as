package Modules {
	import Components.Port;
	import Values.NumericValue;
	import Values.Value;
	import Values.OpcodeValue;
	import Values.BooleanValue;
	
	import Layouts.*;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InstructionDemux extends Module {
		
		public var width:int;
		public function InstructionDemux(X:int, Y:int) {
			width = U.state ? U.state.level.expectedOps.length : 1;
			super(X, Y, "I-Demux", Module.CAT_CONTROL, width, 1, 1);
			if (U.state)
				for (var i:int = 0; i < width; i++)
					inputs[i].name = U.state.level.expectedOps[i].toString();
			delay = Math.ceil(Math.log(width) / Math.log(2));
		}
		override protected function generateLayout():ModuleLayout {
			var layout:ModuleLayout = super.generateLayout();
			for (var i:int = 0; i < inputs.length; i++) {
				layout.ports[i].offset.x -= 1;
				layout.ports[i].offset.y += 1;
			}
			layout.ports[layout.ports.length - 2].offset.x += 2;
			return layout;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			if (!U.state) return null;
			
			var nodes:Array = [];
			var controlLines:Array = [];
			for (var i:int = 0; i < inputs.length; i++) {
				nodes.push(new InternalNode(this, new Point(layout.ports[i].offset.x + 3, layout.ports[i].offset.y), [layout.ports[i], layout.ports[layout.ports.length - 1]], [],
											inputs[i].getValue, U.state.level.expectedOps[i].toString()));
				controlLines.push(new NodeTuple(layout.ports[layout.ports.length - 1], nodes[i], function (i:int):Boolean { 
					return getIndex() == i;
				}, i));
			}
			var kludge:InstructionDemux = this;
			var controlNode:InternalNode = new InternalNode(this, new Point(layout.ports[inputs.length].offset.x, layout.ports[inputs.length].offset.y + 2),
															[layout.ports[layout.ports.length - 2]], controlLines,
															function getValue():BooleanValue { return getIndex() != C.INT_NULL ? BooleanValue.TRUE : BooleanValue.FALSE; });
			nodes.push(controlNode);
			return new InternalLayout(nodes);
		}
		
		protected function resetPorts():void {
			inputs = new Vector.<Port>;
			for (var i:int = 0; i < width; i++)
				inputs.push(new Port(false, this));
		}
		
		override public function renderName():String {
			return "I-Demux\n\n" + controls[0].getValue()+": "+ drive(null);
		}
		
		override public function drive(port:Port):Value {
			var control:Value = controls[0].getValue();
			if (control.unknown || control.unpowered)
				return control;
			
			var op:OpcodeValue = OpcodeValue.fromValue(control);
			var index:int = U.state.level.expectedOps.indexOf(op);
			if (index < 0 || index >= width)
				return U.V_UNKNOWN;
			
			return inputs[index].getValue();
		}
		
		protected function getIndex():int {
			var control:Value = controls[0].getValue();
			if (control.unknown || control.unpowered)
				return C.INT_NULL;
			
			var op:OpcodeValue = OpcodeValue.fromValue(control);
			var index:int = U.state.level.expectedOps.indexOf(op);
			if (index < 0 || index >= width)
				return C.INT_NULL;
			
			return index;
		}
	}

}