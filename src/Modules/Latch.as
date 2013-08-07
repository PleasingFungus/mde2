package Modules {
	import Components.Port;
	import Values.*
	import Layouts.*;
	import Layouts.Nodes.*;
	import flash.geom.Point;
	import UI.HighlightFormat;
	import UI.ColorText;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Latch extends Module {
		
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
			var layout:ModuleLayout = new DefaultLayout(this, 2, 3);
			for (var i:int = 0; i < layout.ports.length; i++)
				layout.ports[i].offset.y -= 1;
			return layout;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			var nodes:Array = [];
			for (var i:int = 0; i < width; i++) {
				var outPort:PortLayout = layout.ports[i + width];
				var dataNode:InternalNode = new StandardNode(this, new Point(outPort.offset.x - 2, outPort.offset.y), [layout.ports[i], outPort], [],
													 outputs[i].getValue /*?*/, width > 1 ? "Stored value " + i : "Stored value", true);
				//dataNode.type = NodeType.STORAGE;
				nodes.push(dataNode);
			}
			return new InternalLayout(nodes);
		}
		
		override public function renderDetails():String {
			return "LCH" +"\n\n" + values;
		}
		
		override public function getDescription():String {
			if (width == 1)
				return "Stores & outputs a value. Each tick, sets its value to the input."
			return "Stores & outputs "+width+" values. Each tick, sets its values to the inputs."
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
		
		override public function revertTo(oldValue:Value):void {
			var indexedOldValue:IndexedValue = oldValue as IndexedValue;
			values[indexedOldValue.index] = indexedOldValue.subValue;
			lastMomentStored = -1;
		}
		
		[Embed(source = "../../lib/art/modules/symbol_box_unlocked_24.png")] private const _symbol:Class;
	}

}