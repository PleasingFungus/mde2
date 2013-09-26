package Values {
	import Components.Port;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DelayDelta extends Delta {
		
		public var port:Port;
		public var oldTime:int;
		public function DelayDelta(Moment:int, port:Port, OldValue:Value, OldTime:int) {
			super(U.state.time.moment, port.dataParent, OldValue);
			this.port = port;
			oldTime = OldTime;
		}
		
		override public function revert():void {
			port.revertTo(oldValue, oldTime);
		}
		
	}

}