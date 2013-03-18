package Modules {
	import Components.Port;
	import Values.*;
	
	import Layouts.*;
	import Layouts.Nodes.StandardNode;
	import Layouts.Nodes.WideNode;
	import Layouts.Nodes.NodeTuple;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Demux extends Module {
		
		public var width:int;
		public function Demux(X:int, Y:int, Width:int = 4) {
			super(X, Y, "Demux", Module.CAT_LOGIC, Width, 1, 1);
			width = Width;
			configuration = new Configuration(new Range(2, 8, Width));
			configurableInPlace = false;
			delay = Math.ceil(Math.log(Width) / Math.log(2));
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
											inputs[i].getValue, i+"", true));
				controlLines.push(new NodeTuple(layout.ports[layout.ports.length - 1], nodes[i], function (i:int):Boolean {
					var control:Value = controls[0].getValue();
					return !control.unknown && !control.unpowered && control.toNumber() == i;
				}, i));
			}
			
			var controlNode:StandardNode = new StandardNode(this, new Point(layout.ports[inputs.length].offset.x, layout.ports[inputs.length].offset.y + 2),
															[layout.ports[layout.ports.length - 2]], controlLines,
															controls[0].getValue);
			nodes.push(controlNode);
			return new InternalLayout(nodes);
		}
		
		
		protected function resetPorts():void {
			inputs = new Vector.<Port>;
			for (var i:int = 0; i < width; i++)
				inputs.push(new Port(false, this));
		}
		
		override public function renderName():String {
			return "Demux\n\n" + controls[0].getValue()+": "+ drive(null);
		}
		
		override public function getDescription():String {
			return "Outputs the value of the input corresponding to the control value.";
		}
		
		override protected function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(width);
			return values;
		}
		
		override public function drive(port:Port):Value {
			var control:Value = controls[0].getValue();
			if (control.unknown || control.unpowered)
				return control;
			var index:int = control.toNumber();
			if (index < 0 || index >= width)
				return U.V_UNPOWERED;
			return inputs[index].getValue();
		}
		
	}

}