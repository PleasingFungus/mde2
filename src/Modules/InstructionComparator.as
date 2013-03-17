package Modules {
	import Components.Port;
	import Levels.Level;
	import Values.*;
	import Layouts.*;
	import Layouts.Nodes.StandardNode;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InstructionComparator extends Module {
		
		public var compareValue:OpcodeValue;
		protected var level:Level;
		public function InstructionComparator(X:int, Y:int, CompareValue:int = 0) {
			super(X, Y, "I-Comp", Module.CAT_LOGIC, 1, 1, 0);
			
			configuration = new OpConfiguration;
			if (U.state)
				configuration.setValue(CompareValue);

			setByConfig();
			delay = 1;
		}
		
		override public function getConfiguration():Configuration {
			if (!U.state)
				return configuration = new OpConfiguration;
			if (U.state.level != level) {
				configuration = new OpConfiguration;
				level = U.state.level;
			}
			return configuration;
		}
		
		override public function setByConfig():void {
			compareValue = (configuration as OpConfiguration).opValue;
		}
		
		override protected function generateLayout():ModuleLayout {
			var layout:ModuleLayout = super.generateLayout();
			layout.ports[0].offset.y += 1;
			layout.ports[1].offset.y += 1;
			return layout;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			var outport:PortLayout = layout.ports[1];
			return new InternalLayout([new StandardNode(this, new Point(outport.offset.x - layout.dim.x / 2 - 1 / 2, outport.offset.y),
														[layout.ports[0], layout.ports[1]], [],
														function getValue():Value { return drive(outputs[0]); }, "=" ),
									   new StandardNode(this, new Point(outport.offset.x - layout.dim.x / 2 - 1 / 2, outport.offset.y - 2),
														[], [],
														function getValue():Value { return compareValue; })]);
		}
		
		override public function renderName():String {
			return "I=" + "\n"+compareValue+"\n\n" + drive(null);
		}
		
		override public function getDescription():String {
			return "Outputs "+BooleanValue.TRUE+" if the input is "+(configuration as OpConfiguration).opValue+", else "+BooleanValue.FALSE+"."
		}
		
		
		override public function drive(port:Port):Value {
			var input:Value = inputs[0].getValue();
			if (input.unknown || input.unpowered)
				return input;
			return input.eq(compareValue) ? BooleanValue.TRUE : BooleanValue.FALSE;
		}
		
		override protected function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(compareValue.toNumber());
			return values;
		}
		
	}

}