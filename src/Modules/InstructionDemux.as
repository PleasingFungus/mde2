package Modules {
	import Components.Port;
	import Displays.OpSelector;
	import flash.utils.ByteArray;
	import Values.*;
	import UI.FlxBounded;
	
	import Layouts.*;
	import Layouts.Nodes.*;
	import flash.geom.Point;
	import Levels.Level;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InstructionDemux extends Module {
		
		public var width:int;
		public var expectedOps:Vector.<OpcodeValue>;
		protected var level:Level;
		public function InstructionDemux(X:int, Y:int, opIntValues:* = null) {
			if (opIntValues is int)
				opIntValues = [opIntValues];
			
			expectedOps = new Vector.<OpcodeValue>;
			if (U.state) {
				for each (var op:OpcodeValue in OpcodeValue.OPS)
					if (opIntValues && opIntValues.length) {
						if (opIntValues.indexOf(op.toNumber()) != -1)
							expectedOps.push(op);
					} else {
						if (U.state.level.expectedOps.indexOf(op) != -1)
							expectedOps.push(op);
					}
				level = U.state.level;
			}
			
			width = expectedOps.length ? expectedOps.length : 1;
			super(X, Y, "Instruction Multiplexer", ModuleCategory.CONTROL, width, 1, 1);
			abbrev = "Imx";
			symbol = _symbol;
			
			for (var i:int = 1; i < expectedOps.length; i++)
				if (expectedOps[i - 1].toNumber() > expectedOps[i].toNumber())
					throw new Error("Misordered ops!");
			
			if (U.state)
				for (i = 0; i < width; i++)
					inputs[i].name = expectedOps[i].toString();
			delay = Math.ceil(Math.log(width) / Math.log(2));
		}
		
		override protected function generateLayout():ModuleLayout {
			var layout:ModuleLayout = new DefaultLayout(this, 2, 5);
			for each (var port:Port in inputs)
				port.offset.y += 1;
			for each (port in outputs)
				port.offset.y += 1;
			return layout;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			if (!U.state) return null;
			
			var nodes:Array = [];
			var controlLines:Array = [];
			for (var i:int = 0; i < inputs.length; i++) {
				var loc:Point = new Point(layout.offset.x + layout.dim.x / 2, inputs[i].offset.y);
				nodes.push(new WideNode(this, loc, [layout.ports[i], layout.ports[layout.ports.length - 1]], [],
											inputs[i].getValue, "Input value for "+expectedOps[i], true));
				controlLines.push(new NodeTuple(layout.ports[layout.ports.length - 1], nodes[i], function (i:int):Boolean { 
					return getIndex() == i;
				}, i));
			}
			
			var controlNode:WideNode = new WideNode(this, new Point(controls[0].offset.x, controls[0].offset.y + 2),
															[layout.ports[layout.ports.length - 2]], controlLines,
															controls[0].getValue, "Selected input");
			//controlNode.type = NodeType.INDEX;
			nodes.push(controlNode);
			return new InternalLayout(nodes);
		}
		
		protected function resetPorts():void {
			inputs = new Vector.<Port>;
			for (var i:int = 0; i < width; i++)
				inputs.push(new Port(false, this));
		}
		
		override public function renderDetails():String {
			return "I-Demux\n\n" + controls[0].getValue()+": "+ drive(null);
		}
		
		override public function getDescription():String {
			return "Outputs the value of the input corresponding to the control value."
		}
		
		override public function drive(port:Port):Value {
			var control:Value = controls[0].getValue();
			if (control.unknown || control.unpowered)
				return control;
			
			var op:OpcodeValue = OpcodeValue.fromValue(control);
			var index:int = expectedOps.indexOf(op);
			if (index < 0 || index >= width)
				return U.V_UNPOWERED;
			
			return inputs[index].getValue();
		}
		
		protected function getIndex():int {
			var control:Value = controls[0].getValue();
			if (control.unknown || control.unpowered)
				return C.INT_NULL;
			
			var op:OpcodeValue = OpcodeValue.fromValue(control);
			var index:int = expectedOps.indexOf(op);
			if (index < 0 || index >= width)
				return C.INT_NULL;
			
			return index;
		}
		
		override public function getConfiguration():Configuration {
			if (U.state && U.state.level != level) {
				expectedOps = U.state.level.expectedOps.slice();
				level = U.state.level;
			}
			return null;
		}
		
		override public function fromConfig(type:Class, loc:Point):Module {
			getConfiguration(); //just to be sure
			var opArray:Array = new Array;
			for each (var op:OpcodeValue in OpcodeValue.OPS)
				if (expectedOps.indexOf(op) != -1)
					opArray.push(op.toNumber());
			return new type(loc.x, loc.y, opArray);
		}
		
		override public function canGenerateConfigurationTool():Boolean {
			return U.state && U.state.level.expectedOps.length > 1;
		}
		
		override public function generateConfigurationTool(X:int, Y:int, MaxHeight:int):FlxBounded {
			return new OpSelector(X, Y, MaxHeight, this);
		}
		
		override public function getSaveValues():Array {
			var values:Array = super.getSaveValues();
			for each (var op:OpcodeValue in expectedOps)
				values.push(op.toNumber());
			return values;
		}
		
		public static function fromBytes(x:int, y:int, bytes:ByteArray, end:int):InstructionDemux {
			var opIntValues:Array = [];
			while (bytes.position < end)
				opIntValues.push(bytes.readByte());
			return new InstructionDemux(x, y, opIntValues);
		}
		
		[Embed(source = "../../lib/art/modules/symbol_i_multiplex_24.png")] private const _symbol:Class;
	}

}