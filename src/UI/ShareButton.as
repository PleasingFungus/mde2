package UI {
	import org.flixel.*;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ShareButton extends FlxGroup {
		
		private var X:int;
		private var Y:int;
		
		private var button:GraphicButton;
		private var text:FlxText;
		
		private var sharingState:int = SHARING_READY;
		private var sharingError:String;
		private var sharingCode:String;
		private var sharingLevel:String;
		//TODO: textfield
		public function ShareButton(X:int, Y:int) {
			this.X = X;
			this.Y = Y;
			super();
			init();
		}
		
		protected function init():void {
			members = [];
			
			add(button = new GraphicButton(X, Y, SPRITES[sharingState], onClick, "Share your machine"));
			
			var extraWidth:int = 10;
			text = new FlxText(X - extraWidth / 2 - 1, button.Y + button.fullHeight - 2, button.fullWidth + extraWidth, getText());
			U.TOOLBAR_FONT.configureFlxText(text, 0xffffff, 'center');
			add(text);
			button.associatedObjects.push(text);
		}
		
		private function onClick():void {
			//TODO
		}
		
		private const SHARING_READY:int = 0;
		private const SHARING_SUCCESS:int = 1;
		private const SHARING_WAITING:int = 2;
		private const SHARING_FAILED:int = 3;
		
		[Embed(source = "../../lib/art/ui/share.png")] private const _ready_sprite:Class;
		[Embed(source = "../../lib/art/ui/erahs.png")] private const _waiting_sprite:Class;
		[Embed(source = "../../lib/art/ui/sharing_success.png")] private const _success_sprite:Class;
		[Embed(source = "../../lib/art/ui/sharing_failure.png")] private const _failure_sprite:Class;
		
		private const SPRITES:Array = [_ready_sprite, _success_sprite, _waiting_sprite, _failure_sprite];
		private function getText():String {
			switch (sharingState) {
				case SHARING_READY: return "Share";
				case SHARING_WAITING: return "Waiting...";
				case SHARING_SUCCESS: return sharingCode;
				case SHARING_FAILED: return sharingError;
				default: return sharingState.toString();
			}
		}
	}

}