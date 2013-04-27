package Modules {
	import Components.Port;
	import Layouts.Nodes.WideNode;
	import Values.*;
	
	import Layouts.*;
	import Layouts.Nodes.StandardNode;
	import Layouts.Nodes.NodeTuple;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Regfile extends Module {
		
		public var width:int;
		public var values:Vector.<Value>;
		protected var lastMomentStored:int = -1;
		public function Regfile(X:int, Y:int, Width:int = 8) {
			width = Width;
			
			super(X, Y, "Registers", Module.CAT_STORAGE, 1, 2, 4);
			
			inputs[0].name = "Write v";
			controls[0].name = "Write";
			controls[1].name = "Write Reg i";
			controls[2].name = "Out Reg i 1";
			controls[3].name = "Out Reg i 2";
			outputs[0].name = "Out Reg 1";
			outputs[1].name = "Out Reg 2";
			
			//configuration = new Configuration(new Range(4, 32, Width));
			configurableInPlace = false;
			delay = Math.ceil(Math.log(width) / Math.log(2)) * 2;
		}
		
		override public function initialize():void {
			super.initialize();
			values = new Vector.<Value>;
			for (var i:int = 0; i < width; i++)
				values.push(new NumericValue(0));
			lastMomentStored = -1;
		}
		
		override protected function generateLayout():ModuleLayout {
			var layout:ModuleLayout = super.generateLayout();
			
			layout.dim.y = Math.max(width * 2 + 3, layout.dim.y);
			
			layout.ports[0].offset.y += 1;
			layout.ports[inputs.length].offset.x -= 1;
			layout.ports[inputs.length + 1].offset.x -= 1;
			layout.ports[inputs.length + 2].offset.x += 2;
			layout.ports[inputs.length + 3].offset.x += 2;
			layout.ports[layout.ports.length - 1].offset.y += 2;
			
			return layout;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			var nodes:Array = [];
			var controlLines:Array;
			var tup:NodeTuple;
			
			for (var i:int = 0; i < width; i++) {
				var loc:Point = new Point(layout.offset.x + layout.dim.x / 2, layout.offset.y + 3.5 + i * 2);
				nodes.push(new WideNode(this, loc, [layout.ports[layout.ports.length - 2], layout.ports[layout.ports.length - 1]], [],
											function getValue(i:int):Value {
												return values[i];
											}, "Stored value no."+i, true, i));
			}
			
			var writeConnections:Array = nodes.slice();
			writeConnections.push(layout.ports[0]);
			var writeNode:StandardNode = new StandardNode(this, new Point(layout.ports[0].offset.x + 4, layout.ports[0].offset.y),
														  writeConnections, [], inputs[0].getValue, "Input");
			
			var writeOK:Function = function writeOK():Boolean {
				var control:Value = write.getValue();
				return !control.unknown && !control.unpowered && control.toNumber() != 0;
			}
			var writeControlNode:StandardNode = new StandardNode(this, new Point(layout.ports[1].offset.x, layout.ports[1].offset.y + 2), [layout.ports[1]],
																[new NodeTuple(layout.ports[0], writeNode, writeOK)], function isEnabled():BooleanValue {
																	return writeOK() ? BooleanValue.TRUE : BooleanValue.FALSE;
																}, "Specified stored value will be set to input value");
			
			controlLines = [];
			for (i = 0; i < nodes.length; i++) {
				tup = new NodeTuple(writeNode, nodes[i], function writeChosen(index:int):Boolean {
					return destination.getValue().toNumber() == index;
				}, i);
				tup.reverseTruncate = true;
				controlLines.push(tup);
			}
			var writeTargetNode:StandardNode = new StandardNode(this, new Point(layout.ports[2].offset.x, layout.ports[2].offset.y + 2), [layout.ports[2]], controlLines,
																function getValue():Value { return destination.getValue(); }, "No. of stored value to set" );
			
			controlLines = [];
			for (i = 0; i < nodes.length; i++)
				controlLines.push(new NodeTuple(nodes[i], layout.ports[layout.ports.length - 2], function writeChosen(index:int):Boolean {
					return source.getValue().toNumber() == index;
				}, i));
			var sourceTargetNode:StandardNode = new StandardNode(this, new Point(layout.ports[3].offset.x, layout.ports[3].offset.y + 2), [layout.ports[3]], controlLines,
																 function getValue():Value { return source.getValue(); }, "No. of 1st stored value to output" );
			
			controlLines = [];
			for (i = 0; i < nodes.length; i++) {
				tup = new NodeTuple(nodes[i], layout.ports[layout.ports.length - 1], function writeChosen(index:int):Boolean {
					return target.getValue().toNumber() == index;
				}, i);
				tup.suggestedIntersect = 4;
				controlLines.push(tup);
			}
			var targetTargetNode:StandardNode = new StandardNode(this, new Point(layout.ports[4].offset.x, layout.ports[4].offset.y + 2), [layout.ports[4]], controlLines,
																 function getValue():Value { return target.getValue(); }, "No. of 2nd stored value to output" );
			
			nodes.push(writeNode);
			nodes.push(writeControlNode);
			nodes.push(writeTargetNode);
			nodes.push(sourceTargetNode);
			nodes.push(targetTargetNode);
			return new InternalLayout(nodes);
		}
		
		override public function renderDetails():String {
			return "Registers" +"\n\n" + values;
		}
		
		override public function getDescription():String {
			return "Stores " + width + " values, and outputs two of them, specified by index. Each tick, sets one specified value to the input if the write-control is " + BooleanValue.TRUE + ".";
		}
		
		override public function drive(port:Port):Value {
			var portIndex:int = outputs.indexOf(port);
			var selectValue:Value = (portIndex == 0 ? source : target).getValue();
			if (selectValue.unknown)
				return U.V_UNKNOWN;
			if (selectValue.unpowered)
				return U.V_UNPOWERED;
			
			var regIndex:int = selectValue.toNumber();
			if (regIndex < 0 || regIndex >= width)
				return U.V_UNPOWERED;
			
			return values[regIndex];
		}
		
		override public function updateState():Boolean {
			if (U.state.time.moment == lastMomentStored) return false; //can only store at most once per cycle
			
			var control:Value = write.getValue();
			if (control.unknown || control.unpowered || control.toNumber() == 0)
				return false;
			
			var selectControl:Value = destination.getValue();
			if (selectControl.unknown || selectControl.unpowered)
				return false;
			
			var selectIndex:int = selectControl.toNumber();
			if (selectIndex < 0 || selectIndex >= width)
				return false;
			
			var input:Value = inputs[0].getValue();
			if (input.unpowered)
				return false;
			
			U.state.time.deltas.push(new Delta(U.state.time.moment, this,
											   new IndexedValue(values[selectIndex], selectIndex)));
			values[selectIndex] = input;
			lastMomentStored = U.state.time.moment;
			return true;
		}
		
		override public function revertTo(oldValue:Value):void {
			var indexedOldValue:IndexedValue = oldValue as IndexedValue;
			values[indexedOldValue.index] = indexedOldValue.subValue;
			lastMomentStored = -1;
		}
		
		override public function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			values.push(width);
			return values;
		}
		
		
		protected function get write():Port {
			return controls[0];
		}
		
		protected function get destination():Port {
			return controls[1];
		}
		
		protected function get source():Port {
			return controls[2];
		}
		
		protected function get target():Port {
			return controls[3];
		}
	}

}