package Modules {
	import Components.Port;
	import Values.*;
	
	import Layouts.*;
	import Layouts.Nodes.*;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InstructionDemux extends Module {
		
		public var width:int;
		private var expectedOps:Vector.<OpcodeValue>;
		public function InstructionDemux(X:int, Y:int, opIntValues:* = null) {
			if (opIntValues is int)
				opIntValues = [opIntValues];
			
			expectedOps = new Vector.<OpcodeValue>;
			if (opIntValues && opIntValues.length)
				for each (var opIntValue:int in opIntValues)
					expectedOps.push(OpcodeValue.fromValue(new NumericValue(opIntValue)));
			else if (U.state)
				expectedOps = U.state.level.expectedOps.slice();
			
			width = expectedOps.length ? expectedOps.length : 1;
			super(X, Y, "Instruction Multiplexer", ModuleCategory.CONTROL, width, 1, 1);
			abbrev = "Imx";
			symbol = _symbol;
			
			if (U.state)
				for (var i:int = 0; i < width; i++)
					inputs[i].name = expectedOps[i].toString();
			delay = Math.ceil(Math.log(width) / Math.log(2));
		}
		
		override protected function generateLayout():ModuleLayout {
			var layout:ModuleLayout = new DefaultLayout(this, 2, 5);
			for (var i:int = 0; i < layout.ports.length; i++)
				if (i != layout.ports.length - 2)
					layout.ports[i].offset.y += 1;
			return layout;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			if (!U.state) return null;
			
			var nodes:Array = [];
			var controlLines:Array = [];
			for (var i:int = 0; i < inputs.length; i++) {
				var loc:Point = new Point(layout.offset.x + layout.dim.x / 2, layout.ports[i].offset.y);
				nodes.push(new WideNode(this, loc, [layout.ports[i], layout.ports[layout.ports.length - 1]], [],
											inputs[i].getValue, "Input value for "+expectedOps[i], true));
				controlLines.push(new NodeTuple(layout.ports[layout.ports.length - 1], nodes[i], function (i:int):Boolean { 
					return getIndex() == i;
				}, i));
			}
			
			var controlNode:WideNode = new WideNode(this, new Point(layout.ports[inputs.length].offset.x, layout.ports[inputs.length].offset.y + 2),
															[layout.ports[layout.ports.length - 2]], controlLines,
															controls[0].getValue, "Selected input");
			//controlNode.type = NodeType.INDEX;
			nodes.push(controlNode);
			return new InternalLayout(nodes);
		}
		
		protected function resetPorts():void {
			inputs = new Vector.<Port>;
			for (var i:int = 0; i < width; i++)
				inputs.push(new Port(false, this));
		}
		
		override public function renderDetails():String {
			return "I-Demux\n\n" + controls[0].getValue()+": "+ drive(null);
		}
		
		override public function getDescription():String {
			return "Outputs the value of the input corresponding to the control value."
		}
		
		override public function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			for each (var op:OpcodeValue in expectedOps)
				values.push(op.toNumber());
			return values;
		}
		
		override public function drive(port:Port):Value {
			var control:Value = controls[0].getValue();
			if (control.unknown || control.unpowered)
				return control;
			
			var op:OpcodeValue = OpcodeValue.fromValue(control);
			var index:int = expectedOps.indexOf(op);
			if (index < 0 || index >= width)
				return U.V_UNKNOWN;
			
			return inputs[index].getValue();
		}
		
		protected function getIndex():int {
			var control:Value = controls[0].getValue();
			if (control.unknown || control.unpowered)
				return C.INT_NULL;
			
			var op:OpcodeValue = OpcodeValue.fromValue(control);
			var index:int = expectedOps.indexOf(op);
			if (index < 0 || index >= width)
				return C.INT_NULL;
			
			return index;
		}
		
		[Embed(source = "../../lib/art/modules/symbol_i_multiplex_24.png")] private const _symbol:Class;
	}

}