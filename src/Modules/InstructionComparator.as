package Modules {
	import Components.Port;
	import Layouts.Nodes.WideNode;
	import Levels.Level;
	import Values.*;
	import Layouts.*;
	import Layouts.Nodes.StandardNode;
	import flash.geom.Point;
	import UI.ColorText;
	import UI.HighlightFormat;
	import org.flixel.FlxSprite;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InstructionComparator extends Module {
		
		public var compareValue:OpcodeValue;
		protected var level:Level;
		public function InstructionComparator(X:int, Y:int, CompareValue:int = 0) {
			super(X, Y, "Instruction Comparator", ModuleCategory.LOGIC, 1, 1, 0);
			abbrev = "I=";
			symbol = _symbol;
			
			getConfiguration();
			if (U.state)
				configuration.setValue(CompareValue);
			setByConfig();
			
			delay = 1;
		}
		
		override public function generateSymbolDisplay():FlxSprite {
			var symbolDisplay:FlxSprite = super.generateSymbolDisplay();
			symbolDisplay.offset.x = symbolDisplay.width*3/4;
			return symbolDisplay;
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
			var layout:ModuleLayout = new DefaultLayout(this, 3, 5);
			layout.ports[0].offset.y += 2;
			layout.ports[1].offset.y += 2;
			return layout;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			var outport:PortLayout = layout.ports[1];
			return new InternalLayout([new StandardNode(this, new Point(outport.offset.x - layout.dim.x / 2 - 1 / 2, outport.offset.y),
														[layout.ports[0], layout.ports[1]], [],
														function getValue():Value { return drive(outputs[0]); }, "Opcodes match" ),
									   new WideNode(this, new Point(outport.offset.x - layout.dim.x / 2 - 1 / 2, outport.offset.y - 2),
														[], [],
														function getValue():Value { return compareValue; }, "Comparison opcode")]);
		}
		
		override public function renderDetails():String {
			return "I=" + "\n"+compareValue+"\n\n" + drive(null);
		}
		
		override public function getDescription():String {
			return "Outputs "+BooleanValue.NUMERIC_TRUE+" if the input is "+(configuration as OpConfiguration).opValue+", else "+BooleanValue.NUMERIC_FALSE+"."
		}
		
		override public function getHighlitDescription():HighlightFormat {
			return new HighlightFormat("Outputs " + BooleanValue.NUMERIC_TRUE + " if the input is {}, else " + BooleanValue.NUMERIC_FALSE + ".",
									   ColorText.singleVec(new ColorText(U.CONFIG_COLOR, (configuration as OpConfiguration).opValue.toString().replace(' ', ''))));
		}
		
		
		override public function drive(port:Port):Value {
			var input:Value = inputs[0].getValue();
			if (input.unknown || input.unpowered)
				return input;
			return input.eq(compareValue) ? BooleanValue.NUMERIC_TRUE : BooleanValue.NUMERIC_FALSE;
		}
		
		override public function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(compareValue.toNumber());
			return values;
		}
		
		[Embed(source = "../../lib/art/modules/symbol_ieqb_24.png")] private const _symbol:Class;
		//[Embed(source = "../../lib/art/modules/symbol_ieqb_48.png")] private const _large_symbol:Class;
		
	}

}