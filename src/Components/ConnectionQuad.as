package Components {
	import flash.utils.ByteArray;
	import Layouts.PortLayout;
	import Modules.Module;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ConnectionQuad {
		
		//probably can't meld this with link, because it's internal to custommmodule, not external? (hence dataparent...)
		
		public var inputPort:Port;
		public var outputPort:Port;
		public function ConnectionQuad(InputPort:Port, OutputPort:Port) {
			inputPort = InputPort;
			outputPort = OutputPort;
		}
		
		public function connect():void {
			inputPort.source = outputPort;
			outputPort.connections.push(inputPort);
			inputPort.connections.push(outputPort);
		}
		
		public function toBytes(modules:Vector.<Module>):ByteArray {
			var inputModuleIndex:int = modules.indexOf(inputPort.dataParent); //dubious
			var inputPortIndex:int = portIndex(inputPort);
			var outputModuleIndex:int = modules.indexOf(outputPort.dataParent); //dubious
			var outputPortIndex:int = portIndex(outputPort);
			
			if (inputModuleIndex == -1 || inputPortIndex == -1 ||
				outputModuleIndex == -1 || outputPortIndex == -1)
				throw new Error("Module or port not found when saving custom module!");
			
			var bytes:ByteArray = new ByteArray();
			bytes.writeInt(inputModuleIndex);
			bytes.writeByte(inputPortIndex);
			bytes.writeInt(outputModuleIndex);
			bytes.writeByte(outputPortIndex);
			
			return bytes;
		}
		
		public static function fromBytes(bytes:ByteArray, modules:Vector.<Module>):ConnectionQuad {
			return new ConnectionQuad(modules[bytes.readInt()].layout.ports[bytes.readByte()].port,
									  modules[bytes.readInt()].layout.ports[bytes.readByte()].port);
		}
		
		private function portIndex(port:Port):int {
			var i:int = 0;
			for each (var portLayout:PortLayout in port.dataParent.layout.ports)
				if (portLayout.port == port)
					return i;
				else
					i++;
			return -1;
		}
	}

}