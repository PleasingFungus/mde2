package Modules {
	import flash.geom.Point;
	import Layouts.InternalLayout
	import Layouts.Nodes.PortNode;
	import Layouts.Nodes.InternalNode;
	import Layouts.PortLayout;
	import Values.NumericValue;
	import Values.Value;
	import Components.Port;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ConstIn extends Module {
		
		public var initialValue:int;
		public var value:NumericValue;
		public function ConstIn(X:int, Y:int, InitialValue:int = 0) {
			configuration = new Configuration(new Range( -16, 15, InitialValue));
			setByConfig();
			super(X, Y, "In", Module.CAT_MISC, 0, 1, 0);
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
			return "Continuously outputs "+configuration.value+"."
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
			value = new NumericValue(initialValue);
		}
	}

}