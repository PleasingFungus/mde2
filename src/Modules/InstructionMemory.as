package Modules {
	import Components.Port;
	import Values.*;
	import Layouts.ModuleLayout;
	import Layouts.Nodes.*;
	import Layouts.InternalLayout;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InstructionMemory extends Module {
		
		public function InstructionMemory(X:int, Y:int) {
			super(X, Y, "I-Mem", Module.CAT_STORAGE, 0, 4, 1);
			controls[0].name = "Line";
			outputs[0].name = "Op";
			outputs[1].name = "Src";
			outputs[2].name = "Targ";
			outputs[3].name = "Dest";
			delay = 10;
		}
		
		override protected function generateLayout():ModuleLayout {
			var layout:ModuleLayout = super.generateLayout();
			layout.dim.x += 4;
			layout.offset.x -= 4;
			layout.ports[0].offset.x -= 4;
			for (var i:int = 1; i < 5; i++)
				layout.ports[i].offset.y += 1;
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
			var memNode:InternalNode = new BigTallNode(this, new Point(layout.ports[0].offset.x, layout.ports[0].offset.y + 6), [opcodeNode, sourceNode, targetNode, destinNode], [],
												   getValue, "Memory at line");
			var lineNode:InternalNode = new WideNode(this, new Point(layout.ports[0].offset.x, layout.ports[0].offset.y + 2),
													 [layout.ports[0], memNode], [],
													 controls[0].getValue, "Line no.");
			return new InternalLayout([opcodeNode, sourceNode, targetNode, destinNode, memNode, lineNode]);
		}
		
		override public function renderDetails():String {
			return "IMEM\n\n" + controls[0].getValue()+": "+getValue();
		}
		
		override public function getDescription():String {
			return "Outputs the opcode, source, target & destination of the instruction at the specified line."
		}
		
		override public function drive(port:Port):Value {			
			var memoryValue:Value = getValue();
			if (!memoryValue)
				return U.V_UNPOWERED;
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
		
		protected function getValue():Value { 
			var line:Value = controls[0].getValue();
			if (line.unpowered || line.unknown) return line;
			
			var index:int = line.toNumber();
			if (index >= U.state.memory.length || index < 0)
				return U.V_UNPOWERED;
			
			return U.state.memory[index];
		}
	}

}