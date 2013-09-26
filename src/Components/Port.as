package Components {
	import flash.geom.Point;
	import Modules.Module;
	import Values.DelayDelta;
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Port implements Carrier {
		
		public var dataParent:Module; //source for drive(), etc
		public var physParent:Module; //source for Loc(), etc
		//distinct only in custommodule to-date
		
		public var name:String;
		public var isOutput:Boolean;
		public var offset:Point;
		public var connections:Vector.<Carrier>;
		public var links:Vector.<Link>;
		public var newLink:Link;
		protected var _source:Port;
		
		private var cachedValue:Value;
		private var lastValue:Value;
		private var lastChanged:int = 0;
		
		public function Port(IsOutput:Boolean, Parent:Module, Connections:Vector.<Carrier> = null) {
			isOutput = IsOutput;
			dataParent = physParent = Parent;
			connections = Connections ? Connections : new Vector.<Carrier>;
			links = new Vector.<Link>;
		}
		
		public function cleanup():void {
			connections = new Vector.<Carrier>;
			source = null;
		}
		
		public function getConnections():Vector.<Carrier> {
			return connections;
		}
		
		public function isSource():Boolean {
			return isOutput;
		}
		
		public function getSource():Port {
			if (isSource())
				return this;
			if (links.length > 1)
				throw new Error("Multiple links to a non-source port!");
			if (links.length)
				return links[0].source != this ? links[0].source : links[0].destination;
			return _source;
		}
		
		public function get source():Port {
			return getSource();
		}
		
		public function set source(s:Port):void {
			_source = s;
		}
		
		public function removeConnection(Connection:Carrier):void {
			log(this + " removed its connection with " + Connection);
			connections.splice(connections.indexOf(Connection), 1);
		}
		
		public function resetSource():void {
			if (!source || isSource()) return;
			
			source = null;
			log("Unset source for " + this);
			for each (var connection:Carrier in connections)
				connection.resetSource();
		}
		
		public function setSource(Source:Port):void {
			log("Set " + Source + " as source for " + this);
			source = Source;
			propagateSource();
		}
		
		public function propagateSource():void {
			for each (var connection:Carrier in connections) {
				if (!connection.getSource())
					connection.setSource(getSource());
				else if (connection.getSource() != getSource())
					throw new Error("Mismatched sources in network!");
			}
		}
		
		public function addConnection(connection:Carrier):void {
			log(this +" added a connection with " + connection);
			connections.push(connection);
		}
		
		public function hasLinkTo(port:Port):Boolean {
			for each (var link:Link in links)
				if (link.source == port || link.destination == port)
					return true;
			return false;
		}
		
		public function createLink(port:Port):void {
			if (hasLinkTo(port))
				return; //don't add redundant links
			
			var s:Port = getSource();
			if (!isSource() && s && s != port)
				throw new Error("Multiple links to a non-source port!");
			
			newLink = new Link(this, port);
			Link.place(newLink);
		}
		
		public function addLink(link:Link):void {
			for each (var extLink:Link in links)
				if (extLink.equals(link))
					return; //don't add redundant links
			
			var s:Port = getSource();
			if (!isSource() && s && s != link.getActualSource())
				throw new Error("Multiple links to a non-source port!");
			
			links.push(link);
		}
		
		public function isEndpoint(p:Point):Boolean {
			return Loc.equals(p);
		}
		
		public function get Loc():Point {
			return physParent.add(offset);
		}
		
		
		
		protected function log(...args):void {
			if (DEBUG.PRINT_CONNECTIONS)
				C.log(args);
		}
		
		public function getValue():Value {
			if (cachedValue)
				return cachedValue;
			
			var curValue:Value = findValue();
			return curValue;
		}
		
		public var checked:Boolean;
		private function findValue():Value {
			if (checked)
				return U.V_UNKNOWN; //deloop
			
			checked = true;
			if (isSource()) {
				var value:Value = dataParent.drive(this);
				checked = false;
				return value;
			}
			checked = false;
			
			if (!source)
				return U.V_UNPOWERED;
			
			if (stable)
				return source.getValue();
			
			return U.V_UNKNOWN;
		}
		
		public function get stable():Boolean {
			var _stable:Boolean = (!U.state || !U.state.level.delay || !dataParent.delay || isOutput ||
								   !source || source.lastChanged == -1 ||
								   remainingDelay() <= 0);
			return _stable
		}
		
		public function remainingDelay():int {
			if (!source) return 0;
			var moment:int = U.state.time.moment;
			var timeSince:int = moment - source.lastChanged;
			var timeRemaining:int = dataParent.delay - timeSince;
			return timeRemaining;
		}
		
		public function revertTo(oldValue:Value, oldTime:int):void {
			lastValue = oldValue;
			lastChanged = oldTime;
		}
		
		public function cacheValue():void {
			cachedValue = findValue();
			if (U.state && U.state.level.delay)
				updateDelay(cachedValue);
		}
		
		public function clearCachedValue():void {
			cachedValue = null;
		}
		
		public function updateDelay(value:Value):void {
			if (value.eq(lastValue))
				return;
			
			U.state.time.deltas.push(new DelayDelta(U.state.time.moment, this,
													lastValue, lastChanged));
			
			lastValue = value;
			lastChanged = U.state.time.moment;
		}
		
		public function getLastChanged():int {
			return lastChanged;
		}
		
		public function clearDelay():void {
			lastValue = null;
			lastChanged = 0;
		}
		
		
		public function toString():String {
			return "PORT of " + dataParent.name; //should be physparent...?
		}
	}

}