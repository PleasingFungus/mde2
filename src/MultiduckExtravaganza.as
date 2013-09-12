package

{
	import flash.events.Event;

	import org.flixel.*;
	
	import Menu.MenuState;
	import Menu.CrashState;
	import flash.net.URLLoader;

	[SWF(width="640", height="480", backgroundColor="#000000")]

	[Frame(factoryClass="Preloader")]



	public class MultiduckExtravaganza extends FlxGame

	{

		public function MultiduckExtravaganza()

		{

			super(640,480,MenuState,1);
			
			if (stage) init()
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event = null):void{
			if (event) removeEventListener(Event.ADDED_TO_STAGE, init);
			
			U.init();
			U.load();
		}

		override protected function onFocusLost(FlashEvent:Event = null):void { }
		
		override protected function onEnterFrame(FlashEvent:Event = null):void {
			if (FlxG.debug) {
				super.onEnterFrame(FlashEvent);
				return;
			}
			
			try {
				super.onEnterFrame(FlashEvent);
			} catch (error:Error) {
				C.log("Error in loading!");
				C.log(error);
				
				var data:Object = {
					'version' : U.VERSION,
					'error' : error.getStackTrace()
				};
				if (U.state)
					data['lvl'] = U.save.data[U.state.level.name]
				
				var loader:URLLoader = C.sendRequest(
					"http://pleasingfungus.com/mde2/error.php", data,
					 function onLoad(e : Event):void {
						var response:String = loader.data;
						C.log(response);
					 }
				);
				
				FlxG.switchState(new CrashState(error));
			}
		}
	}

}

