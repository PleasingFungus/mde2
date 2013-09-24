package Components {
	import Modules.Module;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class LinkPotential {
		
		public var sourcePortIndex:int;
		public var sourceModuleIndex:int;
		public var destPortIndex:int;
		public var destModuleIndex:int;
		public function LinkPotential(SourcePortIndex:int, SourceModuleIndex:int, DestPortIndex:int, DestModuleIndex:int) {
			sourceModuleIndex = SourceModuleIndex;
			sourcePortIndex = SourcePortIndex;
			destModuleIndex = DestModuleIndex;
			destPortIndex = DestPortIndex;
		}
		
		public function manifestPotential(contextModules:Vector.<Module>):Link {
			return new Link(contextModules[sourceModuleIndex].layout.ports[sourcePortIndex].port,
							contextModules[destModuleIndex].layout.ports[destPortIndex].port);
		}
	}

}