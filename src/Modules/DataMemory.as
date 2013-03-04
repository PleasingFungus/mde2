package Modules {
	import Values.*
	import Components.Port;
	
	import Layouts.*;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DataMemory extends Module {
		
		protected var lastMomentStored:int = -1;
		public function DataMemory(X:int, Y:int) {
			super(X, Y, "D-Mem", Module.CAT_DATA, 1, 1, 2);
			delay = 10;
		}
		
		override public function initialize():void {
			super.initialize();
			lastMomentStored = -1;
		}
		
		override protected function generateLayout():ModuleLayout {
			var layout:ModuleLayout = super.generateLayout();
			layout.ports[0].offset.y += 2;
			layout.ports[2].offset.x += 2;
			layout.ports[3].offset.y += 2;
			return layout;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			var writeNode:InternalNode = new InternalNode(this, new Point(layout.ports[2].offset.x, layout.ports[0].offset.y), [layout.ports[0], layout.ports[3]], [],
														  getData, "[M]");
			var lineNode:InternalNode = new InternalNode(this, new Point(layout.ports[2].offset.x, layout.ports[2].offset.y + 3), [layout.ports[2], writeNode], [],
														 function getValue():Value {
															 var v:Value = controls[1].getValue();
															 if (v.toNumber() < 0)
																return U.V_UNKNOWN;
															return v;
														} , "L");
			var controlNode:InternalNode = new InternalNode(this, new Point(layout.ports[1].offset.x, layout.ports[1].offset.y + 2), [layout.ports[1]],
															[new NodeTuple(layout.ports[0], writeNode, writeOK)],
															function getValue():BooleanValue { return writeOK() ? BooleanValue.TRUE : BooleanValue.FALSE; } , "W");
			return new InternalLayout([lineNode, writeNode, controlNode]);
		}
		
		override public function renderName():String {
			var out:String = "DMEM\n\n" + controls[0].getValue()+": ";
			
			var dataValue:NumericValue = getData();
			if (dataValue)
				out += dataValue;
			else
				out += new NumericValue(0);
			
			return out;
		}
		
		override public function getDescription():String {
			return "Outputs a specified line of memory, and also, each tick, writes the input value to that line if the write-control is " + BooleanValue.TRUE + ".";
		}
		
		override public function drive(port:Port):Value {
			var line:Value = controls[1].getValue();
			if (line.unpowered || line.unknown) return line;
			
			var index:int = line.toNumber();
			if (index < 0 || index >= U.state.memory.length)
				return U.V_UNPOWERED;
			
			var memoryValue:Value = U.state.memory[index];
			if (!memoryValue)
				return U.V_UNKNOWN;
			
			return NumericValue.fromValue(memoryValue);
		}
		
		protected function getData():NumericValue { 
			var line:Value = controls[1].getValue();
			if (line.unpowered || line.unknown) return null;
			
			var index:int = line.toNumber();
			if (index < 0 || index >= U.state.memory.length)
				return null;
			
			var memoryValue:Value = U.state.memory[index];
			if (!memoryValue)
				return null;
			
			return NumericValue.fromValue(memoryValue);
		}
		
		override public function updateState():Boolean {
			if (U.state.time.moment == lastMomentStored)
				return false; //can only store at most once per cycle
			
			var line:Value = controls[1].getValue();
			if (line.unpowered || line.unknown || line.toNumber() < 0 || line.toNumber() > U.state.memory.length) return false;
			
			if (!writeOK())
				return false;
			
			var input:Value = inputs[0].getValue();
			U.state.time.deltas.push(new Delta(U.state.time.moment, this,
											   new IndexedValue(U.state.memory[line.toNumber()], line.toNumber())));
			U.state.memory[line.toNumber()] = input;
			lastMomentStored = U.state.time.moment;
			return true;
		}
		
		protected function writeOK():Boolean {
			var control:Value = controls[0].getValue();
			return control != U.V_UNKNOWN && control != U.V_UNPOWERED && control.toNumber() != 0;
		}
		
		override public function revertTo(oldValue:Value):void {
			var indexedOldValue:IndexedValue = oldValue as IndexedValue;
			U.state.memory[indexedOldValue.index] = indexedOldValue.subValue;
			lastMomentStored = -1;
		}
	}

}