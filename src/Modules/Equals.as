package Modules {
	import Components.Port;
	import Layouts.PortLayout;
	import Layouts.InternalLayout;
	import Layouts.Nodes.TallNode;
	import Values.Value;
	import Values.BooleanValue;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Equals extends Module {
		
		private var width:int;
		public function Equals(X:int, Y:int, Width:int = 2) {
			super(X, Y, "Comparator", ModuleCategory.LOGIC, Width, 1, 0);
			abbrev = "=";
			symbol = _symbol;
			width = Width;
			configuration = new Configuration(new Range(2, 8, Width));
			configurableInPlace = false;
			delay = Math.ceil(Math.log(Width) / Math.log(2));
		}
		
		override protected function generateInternalLayout():InternalLayout {
			var ports:Array = [];
			for each (var portLayout:PortLayout in layout.ports)
				ports.push(portLayout);
			
			var outport:PortLayout = layout.ports[layout.ports.length - 1];
			
			return new InternalLayout([new TallNode(this, new Point(outport.offset.x - layout.dim.x / 2 - 1 / 2, outport.offset.y),
														ports, [], function getValue():Value { return drive(outputs[0]); }, "Equal" )]);
		}
		
		protected function resetPorts():void {
			outputs = new Vector.<Port>;
			outputs.push(new Port(true, this));
		}
		
		override public function renderDetails():String {
			var out:String = "Equal\n\n";
			for each (var input:Port in inputs)
				out += input.getValue() + ',';
			return out.slice(0, out.length - 1);
		}
		
		override public function getDescription():String {
			return "Outputs "+BooleanValue.NUMERIC_TRUE+" if all inputs are equal, else "+BooleanValue.NUMERIC_FALSE+"."
		}
		
		override public function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(width);
			return values;
		}
		
		override public function drive(port:Port):Value {
			var v:Value;
			for each (var inputPort:Port in inputs) {
				var inputValue:Value = inputPort.getValue();
				if (inputValue.unknown || inputValue.unpowered)
					return inputValue;
				else if (!v)
					v = inputValue
				else if (!v.eq(inputValue))
					return BooleanValue.NUMERIC_FALSE;
			}
			return BooleanValue.NUMERIC_TRUE;
		}
		
		
		[Embed(source = "../../lib/art/modules/symbol_eq_24.png")] private const _symbol:Class;
		
	}

}