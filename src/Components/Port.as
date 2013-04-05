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
		
		public var name:String;
		public var isOutput:Boolean;
		public var parent:Module;
		public var connections:Vector.<Carrier>;
		public var source:Port;
		
		private var cachedValue:Value;
		private var lastValue:Value;
		private var lastChanged:int = 0;
		
		public function Port(IsOutput:Boolean, Parent:Module, Connections:Vector.<Carrier> = null) {
			isOutput = IsOutput;
			parent = Parent;
			connections = Connections ? Connections : new Vector.<Carrier>;
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
			return source;
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
		
		public function addConnection(Connection:Carrier):void {
			log(this +" added a connection with " + Connection);
			connections.push(Connection);
		}
		
		public function isEndpoint(p:Point):Boolean {
			return false; //not implemented
		}
		
		
		
		protected function log(...args):void {
			if (U.DEBUG_PRINT_CONNECTIONS)
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
				var value:Value = parent.drive(this);
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
			var _stable:Boolean = (!U.state.level.delay || !parent.delay || isOutput ||
								   !source || source.lastChanged == -1 ||
								   remainingDelay() <= 0);
			return _stable
		}
		
		public function remainingDelay():int {
			if (!source) return 0;
			var moment:int = U.state.time.moment;
			var timeSince:int = moment - source.lastChanged;
			var timeRemaining:int = parent.delay - timeSince;
			return timeRemaining;
		}
		
		public function revertTo(oldValue:Value, oldTime:int):void {
			lastValue = oldValue;
			lastChanged = oldTime;
		}
		
		public function lastMinuteInit():void {
			lastValue = findValue();
			lastChanged = 0;
		}
		
		public function cacheValue():void {
			cachedValue = findValue();
		}
		
		public function clearCachedValue():void {
			cachedValue = null;
		}
		
		public function updateDelay():void {
			var value:Value = getValue();
			if (!value.eq(lastValue)) {
				U.state.time.deltas.push(new DelayDelta(U.state.time.moment, this,
													    lastValue, lastChanged));
				
				lastValue = value;
				lastChanged = U.state.time.moment;
			}
		}
		
		public function getLastChanged():int {
			return lastChanged;
		}
		
		public function clearDelay():void {
			lastValue = null;
			lastChanged = 0;
		}
		
		
		public function toString():String {
			return "PORT of " + parent.name;
		}
	}

}