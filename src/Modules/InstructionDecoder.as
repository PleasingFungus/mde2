package Modules {
	import Components.Port;
	import Layouts.DefaultLayout;
	import Layouts.PortLayout;
	import Values.*;
	import Layouts.ModuleLayout;
	import Layouts.Nodes.*;
	import Layouts.InternalLayout;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InstructionDecoder extends Module {
		
		public function InstructionDecoder(X:int, Y:int) {
			super(X, Y, "Instruction Decoder", Module.CAT_MISC, 1, 4, 0);
			abbrev = "Dec";
			inputs[0].name = "Instruction";
			outputs[0].name = "Op";
			outputs[1].name = "Src";
			outputs[2].name = "Targ";
			outputs[3].name = "Dest";
			delay = 2;
		}
		
		override protected function generateLayout():ModuleLayout {
			var layout:ModuleLayout = new DefaultLayout(this, 2, 9);
			for each (var portLayout:PortLayout in layout.ports)
				if (portLayout.port == inputs[0])
					portLayout.offset.y -= 3;
				else
					portLayout.offset.y += 1;
			return layout;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			var opcodeNode:InternalNode = new WideNode(this, new Point(layout.ports[1].offset.x - 3, layout.ports[1].offset.y), [layout.ports[1]], [],
													   function getOpcode():Value { return drive(outputs[0]); }, "Opcode" );
			var sourceNode:InternalNode = new WideNode(this, new Point(layout.ports[2].offset.x - 3, layout.ports[2].offset.y), [layout.ports[2]], [],
													   function getSource():Value { return drive(outputs[1]); }, "Source" );
			var targetNode:InternalNode = new WideNode(this, new Point(layout.ports[3].offset.x - 3, layout.ports[3].offset.y), [layout.ports[3]], [],
													   function getTarget():Value { return drive(outputs[2]); }, "Target" );
			var destinNode:InternalNode = new WideNode(this, new Point(layout.ports[4].offset.x - 3, layout.ports[4].offset.y), [layout.ports[4]], [],
													   function getDestin():Value { return drive(outputs[3]); }, "Destination" ); 
			var instrNode:InternalNode = new BigNode(this, new Point(layout.ports[0].offset.x + 4, layout.ports[0].offset.y),
														 [opcodeNode, sourceNode, targetNode, destinNode, layout.ports[0]], [],
														 inputs[0].getValue, "Instruction");
			return new InternalLayout([opcodeNode, sourceNode, targetNode, destinNode, instrNode]);
		}
		
		override public function renderDetails():String {
			return "IDEC\n\n: "+inputs[0].getValue();
		}
		
		override public function getDescription():String {
			return "Outputs the opcode, source, target & destination of the input instruction."
		}
		
		override public function drive(port:Port):Value {			
			var memoryValue:Value = inputs[0].getValue();
			if (!(memoryValue is InstructionValue))
				return U.V_UNKNOWN;
			
			var instrValue:InstructionValue = memoryValue as InstructionValue;
			
			var portIndex:int = outputs.indexOf(port);
			switch (portIndex) {
				case 0: return instrValue.operation;
				case 1: return instrValue.sourceArg;
				case 2: return instrValue.targetArg;
				case 3: return instrValue.destArg;
				default: return null; //crashme!
			}
		}
		
	}

}