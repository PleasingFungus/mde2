package Values {
	import Components.Port;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DelayDelta extends Delta {
		
		public var port:Port;
		public var oldTime:int;
		public function DelayDelta(Moment:int, Port_:Port, OldValue:Value, OldTime:int) {
			super(U.level.time.moment, Port_.parent, OldValue);
			port = Port_;
			oldTime = OldTime;
		}
		
		override public function revert():void {
			port.revertTo(oldValue, oldTime);
		}
		
	}

}