package Modules {
	import Values.Value;
	import Components.Port;
	
	import Layouts.*;
	import Layouts.Nodes.*;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DataReader extends Module {
		
		public function DataReader(X:int, Y:int) {
			super(X, Y, "Data Reader", Module.CAT_STORAGE, 0, 1, 1);
			delay = 8;
		}
		
		override protected function generateLayout():ModuleLayout {
			var layout:ModuleLayout = new DefaultLayout(this, 5, 3);
			layout.ports[0].offset.x += 1;
			layout.ports[1].offset.y += 2;
			return layout;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			controls[0].name = "Line no.";
			var lineNode:InternalNode = new PortNode(this, InternalNode.DIM_WIDE, new Point(layout.ports[0].offset.x, layout.ports[0].offset.y + 2), layout.ports[0]);
			
			var dataNode:InternalNode = new BigNode(this, new Point(layout.ports[1].offset.x - 4, layout.ports[1].offset.y), [lineNode, layout.ports[1]], [],
														  outputs[0].getValue, "Memory at line");
			return new InternalLayout([dataNode, lineNode]);
		}
		
		override public function renderDetails():String {
			return "D-RD\n\n" + controls[0].getValue()+": "+outputs[0].getValue();
		}
		
		override public function getDescription():String {
			return "Continuously outputs a specified line of memory.";
		}
		
		override public function drive(port:Port):Value {
			var line:Value = controls[0].getValue();
			if (line.unpowered || line.unknown) return line;
			
			var index:int = line.toNumber();
			if (index < 0 || index >= U.state.memory.length)
				return U.V_UNPOWERED;
			
			var memoryValue:Value = U.state.memory[index];
			if (!memoryValue)
				return U.V_UNKNOWN;
			
			return memoryValue;
		}
		
	}

}