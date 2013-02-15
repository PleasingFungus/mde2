package Components {
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
		private var lastChanged:int = -1;
		
		public function Port(IsOutput:Boolean, Parent:Module, Connections:Vector.<Carrier> = null) {
			isOutput = IsOutput;
			parent = Parent;
			connections = Connections ? Connections : new Vector.<Carrier>;
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
		
		
		
		
		protected function log(...args):void {
			if (U.DEBUG && U.DEBUG_PRINT_CONNECTIONS)
				C.log(args);
		}
		
		public function getValue():Value {
			if (cachedValue)
				return cachedValue;
			
			var curValue:Value = findValue();
			//if (isOutput || !U.state.delayEnabled) //TODO: re-enable
				return curValue;
			
			if ((U.state.time.moment - lastChanged) < parent.delay && U.state.time.moment)
				return U.V_UNKNOWN;
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
			if (source) {
				if (U.state.level.delay && U.state.time.moment - source.lastChanged <= parent.delay && source.lastChanged > -1)
					return U.V_UNKNOWN; //delay!
				
				return source.getValue();
			}
			return U.V_UNPOWERED;
		}
		
		public function revertTo(oldValue:Value, oldTime:int):void {
			lastValue = oldValue;
			lastChanged = oldTime;
		}
		
		public function cacheValue():void {
			cachedValue = findValue();
			
			if (U.state.level.delay && !cachedValue.eq(lastValue)) {
				U.state.time.deltas.push(new DelayDelta(U.state.time.moment, this, lastValue, lastChanged));
				
				lastValue = cachedValue;
				lastChanged = U.state.time.moment - 1;
			}
		}
		
		public function clearCachedValue():void {
			cachedValue = null;
		}
		
		public function clearDelay():void {
			lastValue = null;
			lastChanged = -1;
		}
		
		
		public function toString():String {
			return "PORT of " + parent.name;
		}
	}

}