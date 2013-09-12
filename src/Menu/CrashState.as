package Menu {
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class CrashState extends FlxState {
		
		private var error:Error;
		public function CrashState(error:Error) {
			this.error = error;
		}
		
		override public function create():void {
			//32pt: title ("the game has crashed!")
			var title:FlxText = U.TITLE_FONT.configureFlxText(new FlxText(5, 5, FlxG.width - 10, "Crash!")); 
			add(title);
			
			//16pt: friendly text (sorry, you can send me info on the crash @ pfung@gmail, what you were doing + a screenshot of this, refresh to try again if you want)
			var body:FlxText = U.BODY_FONT.configureFlxText(new FlxText(5, title.y + title.height + 15, FlxG.width - 10, "Sorry for the trouble!"));
			body.text += " If you want this bug fixed, send me an email at pleasingfung@gmail.com, containing (1) a description of what you were doing when the game crashed,"
			body.text += " and (2) a screenshot of this screen. If you want to try again, just refresh the page. (Though it might crash again.)"
			body.text += "\n\nSorry again!";
			add(body);
			
			//8pt:
				//error message
				//stack trace
				//if U.state
					//level #
					//code?
			var errorText:FlxText = new FlxText(5, body.y + body.height + 10, FlxG.width - 10, error.getStackTrace());
			add(errorText);
			
			FlxG.bgColor = 0x0;
			FlxG.mouse.hide();
		}
	}

}