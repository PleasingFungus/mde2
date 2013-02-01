package

{
	import flash.events.Event;

	import org.flixel.*;

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

	}

}

