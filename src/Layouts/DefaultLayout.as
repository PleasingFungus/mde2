package Layouts {
	import Components.Port;
	import flash.geom.Point;
	import Modules.Module;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DefaultLayout extends ModuleLayout {
		
		public function DefaultLayout(module:Module) {
			var dim:Point = new Point(
				module.controls.length * SPACING + PADDING,
				Math.max(module.inputs.length, module.outputs.length) * SPACING + PADDING
			);
			
			var offset:Point = new Point(
				-(Math.floor(dim.x / 2) + 0.5),
				-(Math.floor(dim.y / 2) + 0.5)
			);
			
			var ports:Vector.<PortLayout> = new Vector.<PortLayout>;
			var i:int;
			for (i = 0; i < module.inputs.length; i++)
				ports.push(new PortLayout(module.inputs[i], new Point(offset.x - 0.5,
																	  offset.y + 0.5 + i * SPACING + Math.round(PADDING / 2))));
			for (i = 0; i < module.controls.length; i++)
				ports.push(new PortLayout(module.controls[i], new Point(offset.x + 0.5 + i * SPACING + Math.round(PADDING / 2),
																		offset.y - 0.5), true));
			for (i = 0; i < module.outputs.length; i++)
				ports.push(new PortLayout(module.outputs[i], new Point(offset.x + dim.x + 0.5,
																	   offset.y + 0.5 + i * SPACING + Math.round(PADDING / 2)), false, true));
			
			super(module, offset, dim, ports);
		}
		
		private const SPACING:int = 4;
		private const PADDING:int = 3; //minimum 1!
	}

}