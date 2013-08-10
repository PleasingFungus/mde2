package Modules {
	import Components.Port;
	import Values.*
	import Layouts.*;
	import Layouts.Nodes.*;
	import flash.geom.Point;
	import UI.HighlightFormat;
	import UI.ColorText;
	import Displays.DClockModule;
	import Displays.DModule;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Latch extends Module implements Clockable {
		
		public var values:Vector.<Value>;
		public var width:int;
		protected var lastMomentStored:int;
		public function Latch(X:int, Y:int, Width:int = 1) {
			Width = Math.max(Width, 1); //back-compat
			configuration = new Configuration(new Range(1, 8, Width));
			setByConfig();
			
			super(X, Y, "Storage", ModuleCategory.STORAGE, Width, Width, 0);
			abbrev = "l";
			symbol = _symbol;
			delay = 1;
			storesData = true;
			configurableInPlace = false;
		}
		
		override public function initialize():void {
			super.initialize();
			
			values = new Vector.<Value>;
			var init:Value = new IntegerValue(0);
			for (var i:int = 0; i < width; i++)
				values.push(init);
			
			lastMomentStored = -1;
		}
		
		override public function getConfiguration():Configuration {
			if (U.state && U.state.level.configurableLatchesEnabled)
				return configuration;
			return null;
		}
		
		override public function setByConfig():void {
			width = configuration.value;
		}
		
		override public function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(width);
			return values;
		}
		
		override protected function generateLayout():ModuleLayout {
			var layout:ModuleLayout = new DefaultLayout(this, 2, 5);
			return layout;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			var nodes:Array = [];
			var tuples:Array = [];
			for (var i:int = 0; i < width; i++) {
				var outPort:PortLayout = layout.ports[i + width];
				var dataNode:InternalNode = new StandardNode(this, new Point(outPort.offset.x - (U.state && U.state.level.delay ? 2 : 3), outPort.offset.y),
															 [layout.ports[i], outPort], [], outputs[i].getValue /*?*/, width > 1 ? "Stored value " + i : "Stored value", true);
				//dataNode.type = NodeType.STORAGE;
				nodes.push(dataNode);
				tuples.push(new NodeTuple(layout.ports[i], dataNode, writeOK));
			}
			
			if (!U.state || !U.state.level.delay)
				return new InternalLayout(nodes);
			
			var valueText:String = width == 1 ? "value" : "values";
			var controlText:String = "Stored " +valueText + " will be set to input " + valueText +" in";
			var controlNode:StandardNode = new StandardNode(this, new Point(layout.ports[0].offset.x + 2, layout.ports[0].offset.y - 2), [],
															tuples, function ticksUntilWrite():IntegerValue {
																return new IntegerValue(U.state.time.clockPeriod - (U.state.time.moment % U.state.time.clockPeriod));
															}, controlText);
			//controlNode.type = NodeType.TOGGLE;
			nodes.push(controlNode);
			return new InternalLayout(nodes);
		}
		
		public function getClockNode():InternalNode {
			return internalLayout.nodes[internalLayout.nodes.length - 1];
		}
		
		override public function generateDisplay():DModule {
			if (!U.state.level.delay)
				return super.generateDisplay();
			return new DClockModule(this, this);
		}
		
		override public function renderDetails():String {
			return "LCH" +"\n\n" + values;
		}
		
		override public function getDescription():String {
			var values:String = width == 1 ? "a value" : width+" values";
			var ticks:String = U.state.time.clockPeriod == 1 ? "Each tick" : "Every " + U.state.time.clockPeriod + " ticks";
			var plural:String = width == 1 ? "" : 's';
			return "Stores & outputs " + values + ". " + ticks + ", sets its value" + plural + " to the input" + plural + ".";
		}
		
		override public function getHighlitDescription():HighlightFormat {
			if (width == 1)
				return null;
			return new HighlightFormat( "Stores & outputs {} values. Each tick, sets its values to the inputs.",
									   ColorText.singleVec(new ColorText(U.CONFIG_COLOR, width.toString())));
		}
		
		override public function drive(port:Port):Value {
			return values[outputs.indexOf(port)];
		}
		
		override public function updateState():Boolean {
			if (U.state.time.moment == lastMomentStored) return false; //can only store at most once per cycle
			
			var stored:Boolean = statefulUpdate();
			if (stored)
				lastMomentStored = U.state.time.moment;
			return stored;
		}
		
		protected function statefulUpdate():Boolean {
			if (!writeOK())
				return false;
			
			var changed:Boolean = false;
			for (var i:int = 0; i < width; i++) {
				var input:Value = inputs[i].getValue();
				if (input.unpowered)
					continue;
				
				U.state.time.deltas.push(new Delta(U.state.time.moment, this, new IndexedValue(values[i], i)));
				values[i] = input;
				changed = true;
			}
			return changed;
		}
		
		private function writeOK():Boolean {
			return (U.state.time.moment % U.state.time.clockPeriod) == U.state.time.clockPeriod - 1;
		}
		
		override public function revertTo(oldValue:Value):void {
			var indexedOldValue:IndexedValue = oldValue as IndexedValue;
			values[indexedOldValue.index] = indexedOldValue.subValue;
			lastMomentStored = -1;
		}
		
		public function getClockFraction():Number {
			return 1.0 / U.state.time.clockPeriod;
		}
		
		[Embed(source = "../../lib/art/modules/symbol_box_unlocked_24.png")] private const _symbol:Class;
	}

}