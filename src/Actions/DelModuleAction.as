package Actions {
	import Components.Link;
	import Modules.Module;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DelModuleAction extends Action {
		
		public var module:Module;
		private var assocLinks:Vector.<Link>;
		public function DelModuleAction(module:Module) {
			this.module = module;
		}
		
		override public function execute():Action {
			assocLinks = module.getLinks();
			
			for each (var link:Link in assocLinks)
				Link.remove(link);
			
			module.demanifest();
			
			return super.execute();
		}
		
		override public function revert():Action {
			module.manifest();
			
			for each (var link:Link in assocLinks)
				Link.place(link);
			
			return super.revert();
		}
		
	}

}