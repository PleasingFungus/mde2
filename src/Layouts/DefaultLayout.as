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
				module.controls.length + 1,
				Math.max(module.inputs.length, module.outputs.length) + 1
			);
			
			var offset:Point = new Point(
				Math.floor(dim.x / 2) + 0.5,
				Math.floor(dim.y / 2) + 0.5
			);
			
			var ports:Vector.<PortLayout> = new Vector.<PortLayout>;
			var i:int;
			for (i = 0; i < module.inputs.length; i++)
				ports.push(new PortLayout(module.inputs[i], new Point(offset.x - 0.5, offset.y + 0.5 + i)));
			for (i = 0; i < module.controls.length; i++)
				ports.push(new PortLayout(module.controls[i], new Point(offset.x + 0.5 + i, offset.y - 0.5)));
			for (i = 0; i < module.outputs.length; i++)
				ports.push(new PortLayout(module.outputs[i], new Point(offset.x + dim + 0.5, offset.y + 0.5 + i)));
			
			super(module, offset, dim, ports);
		}
		
	}

}