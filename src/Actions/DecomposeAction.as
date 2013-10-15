package Actions {
	import Components.Bloc;
	import flash.geom.Point;
	import Layouts.PortLayout;
	import Modules.CustomModule;
	import Modules.Module;
	import Components.Link;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DecomposeAction extends Action {
		
		public var bloc:Bloc;
		public var loc:Point;
		public var customModule:CustomModule;
		private var placementLinks:Vector.<Link>;
		public function DecomposeAction(bloc:Bloc, Loc:Point, customModule:CustomModule) {
			this.bloc = bloc;
			loc = Loc;
			this.customModule = customModule;
		}
		
		override public function execute():Action {
			var oldLinks:Vector.<Link> = bloc.getLinks();
			
			//exec: lift custom, !exists, set layouts on modules, ext & place bloc
			if (customModule.exists) { //not first-time
				customModule.lift();
				customModule.exists = false;
				
				for each (var module:Module in customModule.modules) {
					for each (var port:PortLayout in module.layout.ports)
						port.port.physParent = module;
					module.setLayout();
				}
			}
			
			bloc.manifest(loc);
			
			findPlacementLinks(oldLinks);
			
			return super.execute();
		}
		
		override public function revert():Action {
			//undo: lift bloc, !exists, set layout on cmodule, ext & place cmod
			removePlacementLinks();
			bloc.lift(loc);
			for each (var module:Module in customModule.modules)
				module.exists = false;
			
			customModule.setLayout();
			customModule.exists = true;
			customModule.place();
			
			return super.revert();
		}
		
		private function findPlacementLinks(oldLinks:Vector.<Link>):void {
			var newLinks:Vector.<Link> = bloc.getLinks();
			placementLinks = new Vector.<Link>;
			for each (var newLink:Link in newLinks)
				if (!newLink.inVec(oldLinks))
					placementLinks.push(newLink);
		}
		
		private function removePlacementLinks():void {
			for each (var link:Link in placementLinks)
				Link.remove(link);
			placementLinks = null;
		}
		
	}

}