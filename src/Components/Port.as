package Components {
	import flash.geom.Point;
	import Layouts.PortLayout;
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
		public var newLink:Link;
		protected var _source:Port;
		
		private var cachedValue:Value;
		private var lastValue:Value;
		private var lastChanged:int = 0;
		
		public function Port(IsOutput:Boolean, Parent:Module, Connections:Vector.<Carrier> = null) {
			isOutput = IsOutput;
			dataParent = physParent = Parent;
			connections = Connections ? Connections : new Vector.<Carrier>;
		}
		
		public function cleanup():void {
			connections = new Vector.<Carrier>;
			
			if (isSource()) {
				for each (var module:Module in U.state.modules)
					for each (var port:PortLayout in module.layout.ports)
						if (port.port.source == this)
							port.port.source = null;
			} else
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
			return _source;
		}
		
		public function get source():Port {
			return getSource();
		}
		
		public function set source(s:Port):void {
			if (/*s && */isSource())
				throw new Error("Can't set a source for a source port!");
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
		
		public function createLink(port:Port):void {
			if (isSource()) {
				var existingSource:Port = port.getSource();
				
				if (existingSource == this)
					return;
				
				if (existingSource)
					throw new Error("Attempting to connect source port to port with existing source!");
				
				port.createLink(this);
			} else {
				if (!port.isSource())
					throw new Error("Attempting to connect two input/control ports!");
				
				if (_source) {
					if (_source == port)
						return; //redundant connection
					throw new Error("Trying to link to a port which already has a source!");
				}
				
				Link.place(new Link(port, this));
			}
			
			
		}
		
		public function addConnection(connection:Carrier):void {
			log(this +" added a connection with " + connection);
			connections.push(connection);
		}
		
		
		public function disconnect():void {
			disconnectWiring();
			cleanup();
		}
		
		protected function disconnectWiring():void {
			var connection:Carrier;
			for each (connection in connections)
				connection.removeConnection(this);
			if (getSource()) {
				for each (connection in connections)
					connection.resetSource();
				if (!isSource())
					source.propagateSource(); //re-propagate
			}
		}
		
		public function isEndpoint(p:Point):Boolean {
			return Loc.equals(p);
		}
		
		public function get Loc():Point {
			return physParent.add(offset);
		}
		
		public function getLinks():Vector.<Link> {
			var links:Vector.<Link> = new Vector.<Link>;
			if (!isOutput) {
				if (source)
					links.push(new Link(_source, this));
				return links;
			}
			
			for each (var module:Module in U.state.modules)
				//check exists?
				for each (var port:PortLayout in module.layout.ports)
					if (port.port != this && port.port.source == this)
						links.push(new Link(this, port.port));
			return links;
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