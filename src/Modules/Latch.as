package Modules {
	import Components.Port;
	import Layouts.Nodes.InternalNode;
	import Layouts.Nodes.NodeType;
	import Layouts.Nodes.WideNode;
	import Values.*
	import Layouts.*;
	import Layouts.Nodes.StandardNode;
	import Layouts.Nodes.NodeTuple;
	import flash.geom.Point;
	import UI.ColorText;
	import UI.HighlightFormat;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Latch extends Module {
		
		public var values:Vector.<Value>
		public var width:int;
		protected var lastMomentStored:int;
		public function Latch(X:int, Y:int, Width:int = 1) {
			Width = Math.max(Width, 1); //back-compat
			configuration = new Configuration(new Range(1, 8, Width));
			setByConfig();
			
			super(X, Y, "Storage", ModuleCategory.STORAGE, Width, Width, 1);
			abbrev = "L";
			symbol = _symbol;
			
			delay = 2;
			configurableInPlace = false;
			storesData = true;
		}
		
		override public function initialize():void {
			super.initialize();
			
			values = new Vector.<Value>;
			var init:Value = new IntegerValue(0);
			for (var i:int = 0; i < width; i++)
				values.push(init);
			
			lastMomentStored = -1;
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
			for (var i:int = 0; i < layout.ports.length; i++)
				if (layout.ports[i].port != controls[0])
					layout.ports[i].offset.y += 1;
				else
					layout.ports[i].offset.x -= 1;
			return layout;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			var nodes:Array = [];
			var tuples:Array = [];
			for (var i:int = 0; i < width; i++) {
				var outPort:PortLayout = layout.ports[i + width + 1];
				var dataNode:InternalNode = new StandardNode(this, new Point(outPort.offset.x - 3, outPort.offset.y), [layout.ports[i], outPort], [],
													 outputs[i].getValue /*?*/, width > 1 ? "Stored value " + i : "Stored value", true);
				//dataNode.type = NodeType.STORAGE;
				nodes.push(dataNode);
				tuples.push(new NodeTuple(layout.ports[i], dataNode, writeOK));
			}
			
			var valueText:String = width == 1 ? "value" : "values";
			var controlText:String = "Stored " +valueText + " will be set to input " + valueText;
			controls[0].name = name + " write?";
			var controlNode:StandardNode = new StandardNode(this, new Point(layout.ports[width].offset.x, layout.ports[width].offset.y + 2), [layout.ports[width]],
															tuples, controls[0].getValue, controlText);
			//controlNode.type = NodeType.TOGGLE;
			nodes.push(controlNode);
			return new InternalLayout(nodes);
		}
		
		override public function renderDetails():String {
			return "LCH" +"\n\n" + values;
		}
		
		override public function getDescription():String {
			if (width == 1)
				return "Stores & outputs a value. Each tick, sets its value to the input if the control is "+BooleanValue.TRUE+"."
			return "Stores & outputs "+width+" values. Each tick, sets its values to the inputs if the control is "+BooleanValue.TRUE+"."
		}
		
		override public function getHighlitDescription():HighlightFormat {
			if (width == 1)
				return null;
			return new HighlightFormat( "Stores & outputs {} values. Each tick, sets its values to the inputs if the control is "+BooleanValue.TRUE+".",
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
		
		override public function revertTo(oldValue:Value):void {
			var indexedOldValue:IndexedValue = oldValue as IndexedValue;
			values[indexedOldValue.index] = indexedOldValue.subValue;
			lastMomentStored = -1;
		}
		
		
		
		protected function writeOK():Boolean {
			var control:Value = controls[0].getValue();
			return control != U.V_UNKNOWN && control != U.V_UNPOWERED && control.toNumber() != 0;
		}
		
		[Embed(source = "../../lib/art/modules/symbol_box_24.png")] private const _symbol:Class;
		
	}

}