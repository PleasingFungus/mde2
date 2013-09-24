package Components {
	import flash.geom.Point;
	import flash.utils.ByteArray;
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
		public var placed:Boolean = false;
		public var hovering:Boolean = false;
		public var FIXED:Boolean = false;
		public function Link(Source:Port, Destination:Port, Hovering:Boolean = false) {
			source = Source;
			destination = Destination;
			hovering = Hovering;
		}
		
		public function get exists():Boolean {
			return !deleted && (hovering || (source.parent.exists && destination.parent.exists));
		}
		
		public function get deployed():Boolean {
			return !hovering && placed && source.parent.deployed && destination.parent.deployed;
		}
		
		public function get mouseable():Boolean {
			return exists && deployed;
		}
		
		public function get saveIncluded():Boolean {
			return exists && !FIXED;
		}
		
		public function atValidEndpoint():Boolean {
			if (!hovering)
				throw new Error("Why is this being called?");
			return findDestinationPort(U.pointToGrid(destination.Loc)) != null; //TODO: investigate why pointToGrid is needed here but not in the place() call
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
			if (link.placed)
				throw new Error("Attempting to place an already-placed & non-deleted link!");
			
			if (link.hovering) {
				link.destination = link.findDestinationPort(link.destination.Loc);
				if (link.destination) {
					link.hovering = false;
				} else {
					link.deleted = true;
					return false; //won't enter onto the action stack
				}
			}
			
			link.connect();
			link.placed = true;
			link.deleted = false;
			U.state.links.push(link);
			newLinks.push(link);
			return true; //will go onto the action stack
		}
		
		private function findDestinationPort(loc:Point):Port {
			for each (var module:Module in U.state.modules)
				if (module.exists)
					for each (var port:PortLayout in module.layout.ports)
						if (port.Loc.equals(loc)) {
							if (validDestination(port.port))
								return port.port;
							return null;
						}
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
			link.placed = false;
			return true;
		}
		
		public function getActualSource():Port {
			return source.isSource() ? source : destination;
		}
		
		//is a port a valid target for beginning a link?
		public static function validStart(port:Port):Boolean {
			return port.isSource() || !port.getSource();
		}
		
		private function validDestination(port:Port):Boolean {
			if (source.isSource())
				return !port.getSource();
			return port.isSource();
		}
		
		public function getBytes():ByteArray {
			var bytes:ByteArray = new ByteArray;
			
			var sourceIndex:int = portIndex(source);
			var sourceModuleIndex:int = moduleIndex(source.parent);
			var destIndex:int = portIndex(destination);
			var destModuleIndex:int = moduleIndex(destination.parent);
			
			if (sourceIndex == -1 || sourceModuleIndex == -1 ||
				destIndex == -1 || destModuleIndex == -1)
				throw new Error("Module or port not found!");
			
			bytes.writeInt(sourceModuleIndex);
			bytes.writeByte(sourceIndex);
			bytes.writeInt(destModuleIndex);
			bytes.writeByte(destIndex);
			
			bytes.position = 0;
			return bytes;
		}
		
		
		
		private static function fromBytes(bytes:ByteArray):LinkPotential {
			var sourceModuleIndex:int = bytes.readInt();
			var sourceIndex:int = bytes.readByte();
			var destModuleIndex:int = bytes.readInt();
			var destIndex:int = bytes.readByte();
			
			return new LinkPotential(sourceIndex, sourceModuleIndex,
									 destIndex, destModuleIndex);
		}
		
		public static function linksFromBytes(bytes:ByteArray, end:int):Vector.<LinkPotential> {
			var links:Vector.<LinkPotential> = new Vector.<LinkPotential>;
			while (bytes.position < end)
				links.push(fromBytes(bytes));
			if (bytes.position > end)
				throw new Error("Link reading overshot?");
			return links;
		}
		
		protected function moduleIndex(module:Module):int {
			var index:int = 0;
			for each (var m:Module in U.state.modules)
				if (m == module)
					return index;
				else if (m.exists)
					index++;
			return -1;
		}
		
		protected function portIndex(port:Port):int {
			var index:int = 0;
			for each (var layout:PortLayout in port.parent.layout.ports)
				if (layout.port == port)
					return index;
				else
					index++;
			return -1;
		}
		
		public static var newLinks:Vector.<Link> = new Vector.<Link>;
	}

}