package Modules {
	import Components.Port;
	import Layouts.PortLayout;
	import Layouts.ModuleLayout;
	import Layouts.DefaultLayout;
	import Layouts.InternalLayout;
	import Layouts.Nodes.TallNode;
	import Values.Value;
	import Values.BooleanValue;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class And extends Module {
		
		private var width:int;
		public function And(X:int, Y:int, Width:int = 2) {
			super(X, Y, "And", Module.CAT_LOGIC, Width, 1, 0);
			width = Width;
			configuration = new Configuration(new Range(2, 8, Width));
			configurableInPlace = false;
			delay = Math.ceil(Math.log(Width) / Math.log(2));
		}
		
		override protected function generateLayout():ModuleLayout {
			var layout:ModuleLayout = new DefaultLayout(this, 2, 3);
			return layout;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			var ports:Array = [];
			for each (var portLayout:PortLayout in layout.ports)
				ports.push(portLayout);
			
			var outport:PortLayout = layout.ports[layout.ports.length - 1];
			
			return new InternalLayout([new TallNode(this, new Point(outport.offset.x - layout.dim.x / 2 - 1 / 2, outport.offset.y),
														ports, [], function getValue():Value { return drive(outputs[0]); }, "All" )]);
		}
		
		protected function resetPorts():void {
			outputs = new Vector.<Port>;
			outputs.push(new Port(true, this));
		}
		
		override public function renderDetails():String {
			var out:String = "And\n\n";
			for each (var input:Port in inputs)
				out += input.getValue() + ',';
			return out.slice(0, out.length - 1);
		}
		
		override public function getDescription():String {
			if (2 == width)
				return "Outputs " + BooleanValue.NUMERIC_TRUE + " if both inputs are " + BooleanValue.TRUE + ", else outputs " + BooleanValue.NUMERIC_FALSE + ".";
			return "Outputs "+BooleanValue.NUMERIC_FALSE+" if any input is "+BooleanValue.FALSE+", else "+BooleanValue.NUMERIC_TRUE+"."
		}
		
		override public function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(width);
			return values;
		}
		
		override public function drive(port:Port):Value {
			for each (var inputPort:Port in inputs) {
				var inputValue:Value = inputPort.getValue();
				if (inputValue.unknown || inputValue.unpowered)
					return inputValue;
				if (!BooleanValue.fromValue(inputValue).boolValue)
					return BooleanValue.NUMERIC_FALSE;
			}
			return BooleanValue.NUMERIC_TRUE;
		}
		
	}

}