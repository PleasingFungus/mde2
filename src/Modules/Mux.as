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
	public class Mux extends Module {
		
		public var width:int;
		public function Mux(X:int, Y:int, Width:int = 8) {
			super(X, Y, "Demultiplex", ModuleCategory.CONTROL, 1, Width, 1);
			abbrev = "Dmx";
			symbol = _symbol;
			
			width = Width;
			configuration = new Configuration(new Range(2, 16, Width));
			configurableInPlace = false;
			delay = Math.ceil(Math.log(width) / Math.log(2));
		}
		override protected function generateLayout():ModuleLayout {
			var layout:ModuleLayout = new DefaultLayout(this, 2, 5);
			for (var i:int = 0; i < layout.ports.length; i++)
				if (i == 1)
					layout.ports[i].offset.x += 1;
				else
					layout.ports[i].offset.y += 1;
			return layout;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			var i:int;
			
			var connections:Array = [layout.ports[0]];
			for (i = 0; i < outputs.length; i++)
				connections.push(layout.ports[i + 2]);
			var inputNode:InternalNode = new WideNode(this, new Point(layout.ports[0].offset.x + 3, layout.ports[0].offset.y),
													  connections, null, inputs[0].getValue, "Input");
			
			var controlLines:Array = [];
			for (i = 0; i < outputs.length; i++) {
				controlLines.push(new NodeTuple(inputNode, layout.ports[i+2], function (i:int):Boolean {
					var control:Value = controls[0].getValue();
					return !control.unknown && !control.unpowered && control.toNumber() == i;
				}, i));
			}
			
			var controlNode:StandardNode = new StandardNode(this, new Point(layout.ports[inputs.length].offset.x, layout.ports[inputs.length].offset.y + 2),
															[layout.ports[inputs.length]], controlLines,
															controls[0].getValue, "Selected input no.");
			controlNode.type = NodeType.INDEX;
			return new InternalLayout([inputNode, controlNode]);
		}
		
		protected function resetPorts():void {
			outputs = new Vector.<Port>;
			for (var i:int = 0; i < width; i++)
				outputs.push(new Port(true, this));
		}
		
		override public function renderDetails():String {
			return "Mux\n\n" + inputs[0].getValue()+"->"+ controls[0].getValue();
		}
		
		override public function getDescription():String {
			return "Outputs the input to the output port indicated by the control value.";
		}
		
		override public function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(width);
			return values;
		}
		
		override public function drive(port:Port):Value {
			var index:int = outputs.indexOf(port);
			var control:Value = controls[0].getValue();
			if (control.unknown || control.unpowered)
				return control;
			if (control.toNumber() == index)
				return inputs[0].getValue();
			return U.V_UNPOWERED;
		}
		
		[Embed(source = "../../lib/art/modules/symbol_demultiplex_24.png")] private const _symbol:Class;
		
	}

}