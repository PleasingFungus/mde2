package Modules {
	import Components.Port;
	import Values.FixedValue;
	import Values.IntegerValue;
	import Values.Value;
	
	import Layouts.*;
	import Layouts.Nodes.TallNode;
	import flash.geom.Point;
	import org.flixel.FlxSprite;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Adder extends Module {
		
		public function Adder(X:int, Y:int) {
			super(X, Y, "Adder", ModuleCategory.ARITH, 2, 1, 0);
			abbrev = "+";
			delay = 2;
			symbol = _symbol;
			largeSymbol = _large_symbol;
		}
		
		override public function generateSymbolDisplay():FlxSprite {
			var symbolDisplay:FlxSprite = super.generateSymbolDisplay();
			symbolDisplay.offset.y = symbolDisplay.height / 2;
			return symbolDisplay;
		}
		
		override protected function generateLayout():ModuleLayout {
			var layout:ModuleLayout = super.generateLayout();
			layout.ports[layout.ports.length - 1].offset.y += 2;
			return layout;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			var outport:PortLayout = layout.ports[2];
			return new InternalLayout([new TallNode(this, new Point(outport.offset.x - layout.dim.x / 2 - 1 / 2, outport.offset.y),
														[layout.ports[0], layout.ports[1], layout.ports[2]], [],
													    function getValue():Value { return drive(outputs[0]); }, "Sum" )]);
		}
		
		override public function drive(port:Port):Value {
			var inputA:Value = inputs[0].getValue();
			var inputB:Value = inputs[1].getValue();
			if (inputA.unknown || inputB.unknown)
				return U.V_UNKNOWN;
			if (inputA.unpowered || inputB.unpowered)
				return U.V_UNPOWERED;
			if (inputA == FixedValue.NULL || inputB == FixedValue.NULL)
				return FixedValue.NULL;
			return IntegerValue.fromNumber(inputA.toNumber() + inputB.toNumber());
		}
		
		override public function renderDetails():String {
			return name + "\n\n" + drive(outputs[0]);
		}
		
		override public function getDescription():String {
			return "Outputs the sum of its inputs."
		}
		
		[Embed(source = "../../lib/art/modules/symbol_plus_24.png")] private const _symbol:Class;
		[Embed(source = "../../lib/art/modules/symbol_plus_48.png")] private const _large_symbol:Class;
	}

}