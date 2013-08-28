package Modules {
	import Values.*;
	import Layouts.*;
	import Layouts.Nodes.*;
	import Components.Port;
	import Displays.DModule;
	import Displays.DClockModule;
	
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DataWriter extends Module implements Clockable {
		
		protected var lastMomentStored:int = -1;
		public function DataWriter(X:int, Y:int) {
			super(X, Y, "Data Writer", ModuleCategory.STORAGE, 1, 0, 1);
			abbrev = "wr";
			symbol = _symbol;
			delay = 12;
			writesToMemory = 1;
		}
		
		override public function initialize():void {
			super.initialize();
			lastMomentStored = -1;
		}
		
		override protected function generateLayout():ModuleLayout {
			var layout:ModuleLayout = new DefaultLayout(this, 3, 6);
			layout.ports[0].offset.y += 2;
			layout.ports[1].offset.x += 2;
			return layout;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			controls[0].name = U.LINE_NUM.text;
			var lineNode:InternalNode = new PortNode(this, InternalNode.DIM_WIDE, new Point(layout.ports[1].offset.x, layout.ports[1].offset.y + 2), layout.ports[1]);
			lineNode.type = new NodeType(0x0, U.LINE_NUM.color);
			layout.ports[0].port.name = "Input";
			var writeNode:InternalNode = new BigNode(this, new Point(layout.ports[1].offset.x-1, layout.ports[0].offset.y), [layout.ports[0], lineNode], [], getNextValue, "Next Value");
			if (!U.state || !U.state.level.delay)
				return new InternalLayout([lineNode, writeNode]);
			
			var controlNode:StandardNode = new StandardNode(this, new Point(layout.ports[0].offset.x + 2, layout.ports[1].offset.y + 2), [],
															[new NodeTuple(layout.ports[0], writeNode, writeOK)], function ticksUntilWrite():IntegerValue {
																return new IntegerValue(U.state.time.clockPeriod - (U.state.time.moment % U.state.time.clockPeriod));
															}, "Memory value at line will be set to input value in");
			//controlNode.type = NodeType.TOGGLE;
			return new InternalLayout([lineNode, writeNode, controlNode]);
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
			var out:String = "DWRITE\n\n" + controls[0].getValue();
			return out;
		}
		
		override public function getDescription():String {
			if (U.state.time.clockPeriod == 1)
				return "Each tick, writes the input value to the specified line of memory."
			return "Every "+U.state.time.clockPeriod+" ticks, writes the input value to the specified line of memory."
		}
		
		private function getNextValue():Value {
			var line:Value = controls[0].getValue();
			if (line.unpowered || line.unknown)
				return NilValue.NIL;
			
			var index:int = line.toNumber();
			if (index < 0 || index >= U.state.memory.length)
				return NilValue.NIL;
			
			if (!writeOK())
				return NilValue.NIL;
			
			return inputs[0].getValue();
		}
		
		override public function updateState():Boolean {
			if (U.state.time.moment == lastMomentStored)
				return false; //can only store at most once per cycle
			if (!writeOK())
				return false;
			
			var line:Value = controls[0].getValue();
			if (line.unpowered || line.unknown || line.toNumber() < 0 || line.toNumber() > U.state.memory.length) return false;
			
			var input:Value = inputs[0].getValue();
			if (input.unpowered)
				return false;
			
			U.state.time.deltas.push(new Delta(U.state.time.moment, this,
											   new IndexedValue(U.state.memory[line.toNumber()], line.toNumber())));
			U.state.memory[line.toNumber()] = input;
			lastMomentStored = U.state.time.moment;
			return true;
		}
		
		private function writeOK():Boolean {
			return (U.state.time.moment % U.state.time.clockPeriod) == U.state.time.clockPeriod - 1;
		}
		
		override public function revertTo(oldValue:Value):void {
			var indexedOldValue:IndexedValue = oldValue as IndexedValue;
			U.state.memory[indexedOldValue.index] = indexedOldValue.subValue;
			lastMomentStored = -1;
		}
		
		protected function getData():Value { 
			var line:Value = controls[0].getValue();
			if (line.unpowered || line.unknown) return line;
			
			var index:int = line.toNumber();
			if (index < 0 || index >= U.state.memory.length)
				return U.V_UNPOWERED;
			
			var memoryValue:Value = U.state.memory[index];
			if (!memoryValue)
				return FixedValue.NULL;
			
			return memoryValue;
		}
		
		public function getClockFraction():Number {
			return 1.0 / U.state.time.clockPeriod;
		}
		
		override public function cacheValues():void {
			if (inputs[0].getValue().toNumber() == 26) {
				inputs[0].getValue();
			}
			super.cacheValues();
		}
		
		[Embed(source = "../../lib/art/modules/symbol_stamp_24.png")] private const _symbol:Class;
	}

}