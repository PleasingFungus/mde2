package Components {
	import Modules.Module;
	import Values.DelayDelta;
	import Values.Value;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Port implements Carrier {
		
		public var isOutput:Boolean;
		public var parent:Module;
		public var connection:Carrier;
		public var source:Port;
		
		private var lastValue:Value;
		private var lastChanged:int;
		
		public function Port(IsOutput:Boolean, Parent:Module, Connection:Carrier = null) {
			isOutput = IsOutput;
			parent = Parent;
			connection = Connection;
		}
		
		public function getConnections():Vector.<Carrier> {
			var connections:Vector.<Carrier> = new Vector.<Carrier>;
			if (connection)
				connections.push(connection);
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
			this.connection = null;
		}
		
		public function resetSource():void {
			source = null;
		}
		
		public function setSource(Source:Port):void {
			source = Source;
		}
		
		public function addConnection(Connection:Carrier):void {
			if (Connection == connection) return;

			connection = Connection;
			connection.addConnection(this);
			if (!source && connection.getSource())
				source = connection.getSource();
		}
		
		public function getValue():Value {
			var curValue:Value = findValue();
			//if (isOutput || !U.level.delayEnabled) //TODO: re-enable
				return curValue;
			
			if (curValue != lastValue) {
				U.level.time.deltas.push(new DelayDelta(U.level.time.moment, this, lastValue, lastChanged));
				
				lastValue = curValue;
				lastChanged = U.level.time.moment;
			}
			
			if ((U.level.time.moment - lastChanged) < parent.delay && U.level.time.moment)
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
			if (source)
				return source.getValue();
			return U.V_UNPOWERED;
		}
		
		public function revertTo(oldValue:Value, oldTime:int):void {
			lastValue = oldValue;
			lastChanged = oldTime;
		}
	}

}