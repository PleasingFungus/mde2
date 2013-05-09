package Modules {
	import Components.Port;
	import Displays.DModule;
	import Displays.DClockModule;
	import Values.Value;
	import Values.NumericValue;
	import UI.ColorText;
	import UI.HighlightFormat;
	import Layouts.PortLayout;
	import Layouts.InternalLayout;
	import flash.geom.Point;
	import Layouts.Nodes.InternalNode;
	import Layouts.Nodes.PortNode;
	import Layouts.ModuleLayout;
	import org.flixel.FlxSprite;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SysDelayClock extends Module {
		
		private var _edgeLength:int = 1;
		public function SysDelayClock(X:int, Y:int, EdgeLength:int = 1) {
			super(X, Y, "System Clock", ModuleCategory.MISC, 0, 1, 0);
			abbrev = "Clk";
			symbol = _symbol;
			largeSymbol = _large_symbol;
			
			configuration = getConfiguration();
			if (U.state)
				configuration.setValue(EdgeLength);
			setByConfig();
		}
		
		override protected function generateLayout():ModuleLayout {
			var layout:ModuleLayout = super.generateLayout();
			layout.ports[0].offset.y += 1;
			return layout;
		}
		
		override public function getConfiguration():Configuration {
			var maxEdge:int = U.state ? U.state.time.clockPeriod - 1 : 64;
			if (!configuration)
				configuration = new Configuration(new Range(1, maxEdge, edgeLength));
			if (U.state && configuration.valueRange.max != maxEdge) {
				var initial:int = Math.max(Math.min(edgeLength, maxEdge), 1);
				configuration.valueRange.max = maxEdge;
				configuration.value = initial;
			}
			return configuration;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			var lport:PortLayout = layout.ports[0];
			lport.port.name = "Clock";
			return new InternalLayout([new PortNode(this, InternalNode.DIM_STANDARD,
													new Point(lport.offset.x - layout.dim.x / 2 - 1 / 2, lport.offset.y), lport)]);
		}
		
		override public function generateDisplay():DModule {
			return new DClockModule(this);
		}
		
		override public function setByConfig():void {
			_edgeLength = configuration.value;
		}
		
		override public function renderDetails():String {
			return "SYSCLK" + "\n"+U.state.time.clockPeriod+"\n"+edgeLength+"-"+delayLength+"\n\n" + drive(null);
		}
		
		override public function getDescription():String {
			var edgeLength:int = configuration.value;
			return "Outputs "+EDGE+" for the last "+(edgeLength != 1 ? edgeLength + ' ticks' : 'tick')+" out of every "+(U.state ? U.state.time.clockPeriod : '-')+"; outputs "+NO_EDGE+" the rest of the time."
		}
		
		override public function getHighlitDescription():HighlightFormat {
			return new HighlightFormat("Outputs " + EDGE + " for the last {}"+(edgeLength != 1 ? ' ticks' : '')+" out of every " + (U.state ? U.state.time.clockPeriod : '-') + "; outputs " + NO_EDGE + " the rest of the time.",
										ColorText.singleVec(new ColorText(U.CONFIG_COLOR, (edgeLength != 1 ? edgeLength.toString() : 'tick'))));
		}
		
		protected function get delayLength():int {
			return Math.max(1, U.state.time.clockPeriod - edgeLength);
		}
		
		override public function drive(port:Port):Value {
			if (U.state.time.clockPeriod - (U.state.time.moment % U.state.time.clockPeriod) <= edgeLength) //within e ticks of the end of the clock period
				return EDGE;
			return NO_EDGE;
		}
		
		public function get edgeLength():int {
			return U.state ? Math.min(_edgeLength, U.state.time.clockPeriod - 1) : _edgeLength;
		}
		
		override public function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(edgeLength);
			return values;
		}
		
		public const EDGE:Value = new NumericValue(1);
		public const NO_EDGE:Value = new NumericValue(0);
		
		
		[Embed(source = "../../lib/art/modules/symbol_clk_24.png")] private const _symbol:Class;
		[Embed(source = "../../lib/art/modules/symbol_clk_48.png")] private const _large_symbol:Class;
	}

}