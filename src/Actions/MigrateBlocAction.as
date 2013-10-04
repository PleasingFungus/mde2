package Actions {
	import Components.Link;
	import Components.Wire;
	import flash.geom.Point;
	import Components.Bloc;
	import Components.WireHistory;
	import Components.AssociatedWire;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class MigrateBlocAction extends Action {
		
		public var bloc:Bloc;
		public var newLoc:Point;
		public var oldLoc:Point;
		private var placementLinks:Vector.<Link>;
		public function MigrateBlocAction(bloc:Bloc, newLoc:Point, oldLoc:Point) {
			super();
			this.bloc = bloc;
			this.newLoc = newLoc;
			this.oldLoc = oldLoc;
		}
		
		override public function execute():Action {
			var oldLinks:Vector.<Link> = bloc.getLinks();
			
			bloc.lift(oldLoc);
			bloc.place(newLoc);
			
			findPlacementLinks(oldLinks);
			
			return super.execute();
		}
		
		override public function revert():Action {
			removePlacementLinks();
			bloc.lift(newLoc);
			bloc.place(oldLoc);
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