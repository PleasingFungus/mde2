package Modules {
	import Components.Port;
	import Values.Value;
	import Layouts.InternalLayout;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Output extends Module {
		
		public function Output(X:int, Y:int) {
			super(X, Y, "Output", ModuleCategory.MISC, 1, 1, 0);
			abbrev = "Out";
			symbol = _symbol;
		}
		
		override protected function generateInternalLayout():InternalLayout {
			return new InternalLayout([]);
		}
		
		override public function drive(port:Port):Value {
			return inputs[0].getValue();
		}
		
		override public function getDescription():String {
			return "Routes the input to the output. (Does nothing; intended for custom modules.)";
		}
		
		[Embed(source = "../../lib/art/modules/symbol_out_24.png")] private const _symbol:Class;
	}

}