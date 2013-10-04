package Actions {
	import Components.Bloc;
	import Components.Link;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DelBlocAction extends Action {
		
		public var bloc:Bloc;
		private var assocLinks:Vector.<Link>;
		public function DelBlocAction(bloc:Bloc) {
			this.bloc = bloc;
		}
		
		override public function execute():Action {
			assocLinks = bloc.getLinks();
			
			for each (var link:Link in assocLinks)
				Link.remove(link);
			
			bloc.demanifest();
			
			return super.execute();
		}
		
		override public function revert():Action {
			bloc.manifest(bloc.lastRootedLoc);
			
			for each (var link:Link in assocLinks)
				Link.place(link);
			
			return super.revert();
		}
		
	}

}