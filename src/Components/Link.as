package Components {
	import flash.geom.Point;
	import Layouts.PortLayout;
	import Modules.Module;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Link {
		
		public var source:Port;
		public var destination:Port;
		public var deleted:Boolean = false;
		public var fullyPlaced:Boolean = false;
		public function Link(Source:Port, Destination:Port) {
			source = Source;
			destination = Destination;
		}
		
		public function get exists():Boolean {
			return !deleted && (!fullyPlaced || (source.parent.exists && source.parent.deployed &&
											     destination.parent.exists && destination.parent.deployed));
		}
		
		public function get deployed():Boolean {
			return fullyPlaced && source.parent.deployed && destination.parent.deployed;
		}
		
		protected function connect():void {
			source.links.push(this);
			destination.links.push(this);
		}
		
		protected function disconnect():void {
			unlinkFrom(source);
			unlinkFrom(destination);
		}
		
		protected function unlinkFrom(port:Port):void {
			var linkIndex:int = port.links.indexOf(this);
			if (linkIndex == -1)
				throw new Error("Unlinking from a port this link was never connected to!");
			
			port.links.splice(linkIndex, 1);
		}
		
		public static function place(link:Link):Boolean {
			if (link.fullyPlaced && !link.deleted)
				throw new Error("Attempting to place an already-placed & non-deleted link!");
			
			if (!link.fullyPlaced) {
				link.destination = findDestinationPort(link.destination.Loc);
				if (link.destination) {
					link.fullyPlaced = true;
				} else {
					link.deleted = true;
					return false; //won't enter onto the action stack
				}
			}
			
			link.connect();
			link.deleted = false;
			U.state.links.push(link);
			return true; //will go onto the action stack
		}
		
		private static function findDestinationPort(loc:Point):Port {
			for each (var module:Module in U.state.modules)
				if (module.exists)
					for each (var port:PortLayout in module.layout.ports)
						if (!port.port.getSource() && port.Loc.equals(loc))
							return port.port;
			return null;
		}
		
		public static function remove(link:Link):Boolean {
			if (link.deleted)
				throw new Error("Attempting to delete a deleted link!");
			
			var linkIndex:int = U.state.links.indexOf(link);
			if (linkIndex == -1)
				throw new Error("Attempting to remove a link that wasn't in the link list!");
			
			U.state.links.splice(linkIndex, 1);
			link.disconnect();
			link.deleted = true;
			return true;
		}
		
	}

}