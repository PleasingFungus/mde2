package Modules {
	import Layouts.ModuleLayout;
	import Values.BooleanValue;
	import Values.IndexedValue;
	import Values.NumericValue;
	import Values.Value;
	import Values.Delta;
	import Components.Port;
	
	import Layouts.PortLayout;
	import Layouts.InternalLayout;
	import Layouts.InternalNode;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DataWriter extends Module {
		
		protected var lastMomentStored:int = -1;
		public function DataWriter(X:int, Y:int) {
			super(X, Y, "D-Write", Module.CAT_DATA, 1, 0, 1);
			delay = 10;
		}
		
		override public function initialize():void {
			super.initialize();
			lastMomentStored = -1;
		}
		
		override protected function generateLayout():ModuleLayout {
			var layout:ModuleLayout = super.generateLayout();
			layout.ports[0].offset.y += 1;
			layout.ports[1].offset.x += 1;
			return layout;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			var writeNode:InternalNode = new InternalNode(this, new Point(layout.ports[1].offset.x, layout.ports[0].offset.y), [layout.ports[0]], [],
															null, "[M]");
			var controlNode:InternalNode = new InternalNode(this, new Point(layout.ports[1].offset.x, layout.ports[1].offset.y + 2), [layout.ports[1]], [],
															controls[0].getValue, "L");
			return new InternalLayout([controlNode, writeNode]);
		}
		
		override public function renderName():String {
			var out:String = "DWRITE\n\n" + controls[0].getValue();
			return out;
		}
		
		protected function get data():NumericValue { 
			var line:Value = controls[0].getValue();
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
			
			var line:Value = controls[0].getValue();
			if (line.unpowered || line.unknown || line.toNumber() < 0 || line.toNumber() > U.state.memory.length) return false;
			
			var input:Value = inputs[0].getValue();
			U.state.time.deltas.push(new Delta(U.state.time.moment, this,
											   new IndexedValue(U.state.memory[line.toNumber()], line.toNumber())));
			U.state.memory[line.toNumber()] = input;
			lastMomentStored = U.state.time.moment;
			return true;
		}
		
		override public function revertTo(oldValue:Value):void {
			var indexedOldValue:IndexedValue = oldValue as IndexedValue;
			U.state.memory[indexedOldValue.index] = indexedOldValue.subValue;
			lastMomentStored = -1;
		}
		
	}

}