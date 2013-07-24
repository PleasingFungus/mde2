package Modules {
	import flash.geom.Point;
	import Layouts.InternalLayout
	import Layouts.ModuleLayout;
	import Layouts.Nodes.PortNode;
	import Layouts.Nodes.InternalNode;
	import Layouts.PortLayout;
	import UI.ColorText;
	import UI.HighlightFormat;
	import Values.IntegerValue;
	import Values.Value;
	import Components.Port;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ConstIn extends Module {
		
		public var initialValue:int;
		public var value:IntegerValue;
		public function ConstIn(X:int, Y:int, InitialValue:int = 0) {
			configuration = new Configuration(new Range( -32, 31, InitialValue));
			setByConfig();
			super(X, Y, "Number", ModuleCategory.MISC, 0, 1, 0);
			abbrev = "In";
			symbol = _symbol
		}
		
		override protected function generateLayout():ModuleLayout {
			var layout:ModuleLayout = super.generateLayout();
			layout.ports[0].offset.y += 1;
			return layout;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			var lport:PortLayout = layout.ports[0];
			lport.port.name = "Value";
			return new InternalLayout([new PortNode(this, InternalNode.DIM_STANDARD,
													new Point(lport.offset.x - layout.dim.x / 2 - 1 / 2, lport.offset.y), lport)]);
		}
		
		override public function setByConfig():void {
			initialValue = configuration.value;
		}
		
		override public function renderDetails():String {
			return name + "\n\n" + value;
		}
		
		override public function getDescription():String {
			return "Outputs "+configuration.value+"."
		}
		
		override public function getHighlitDescription():HighlightFormat {
			return new HighlightFormat("Outputs {}", ColorText.singleVec(new ColorText(U.CONFIG_COLOR, configuration.value.toString())));
		}
		
		override public function drive(port:Port):Value {
			return value;
		}
		
		override public function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(initialValue);
			return values;
		}
		
		override public function initialize():void {
			value = new IntegerValue(initialValue);
		}
		
		[Embed(source = "../../lib/art/modules/symbol_num_24.png")] private const _symbol:Class;
	}

}