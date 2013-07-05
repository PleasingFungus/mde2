package UI {
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import org.flixel.*;
	import flash.external.ExternalInterface;
	import Levels.Level;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ShareButton extends FlxGroup {
		
		private var X:int;
		private var Y:int;
		
		private var button:GraphicButton;
		private var text:FlxText;
		private var textField:FlxInputText;
		//TODO: textfield
		
		private var sharingState:int = SHARING_READY;
		private var sharingError:String;
		private var sharingCode:String;
		private var sharingTime:Number;
		private var loader:URLLoader;
		public function ShareButton(X:int, Y:int) {
			this.X = X;
			this.Y = Y;
			super();
			init();
		}
		
		protected function init():void {
			if (textField) {
				textField.exists = false;
				textField.die();
				textField = null;
			}
			if (button)
				button.exists = false;
			
			members = [];
			
			add(button = new GraphicButton(X, Y, SPRITES[sharingState], onClick, "Share your machine"));
			
			if (sharingState == SHARING_SUCCESS) {
				textField = new FlxInputText(X - extraWidth / 2 - 1 - 120, text.y, 110 * 2 - 8, 8,
											 " ", 0xffffff, U.TOOLBAR_FONT.id, U.TOOLBAR_FONT.size);
				textField.text = getText();
				textField.scrollFactor.x = textField.scrollFactor.y = 0;
				button.add(textField);
			} else {
				var extraWidth:int = 10;
				text = new FlxText(X - extraWidth / 2 - 1, button.Y + button.fullHeight - 2, button.fullWidth + extraWidth, getText());
				U.TOOLBAR_FONT.configureFlxText(text, 0xffffff, 'center');
				text.scrollFactor.x = text.scrollFactor.y = 0;
				button.add(text);
			}
			
		}
		
		private function onClick():void {
			if (sharingState == SHARING_WAITING) {
				loader.close();
				loader = null;
				sharingState = SHARING_READY;
				init();
				return;
			}
			
			loader = C.sendRequest(
				"http://pleasingfungus.com/mde2/insert.php",
				{'lvl' : U.state.genSaveString()},
				function onLoad(e:Event):void {
					var response:String = loader.data;
					if (response.indexOf("ERROR") == 0) {
						sharingState = SHARING_FAILED;
						sharingError = response;
						init();
						return;
					}
					
					sharingState = SHARING_SUCCESS;
					sharingCode = response;
					init();
			});
			loader.addEventListener("ioError", function onFail(e:Event):void {
				sharingState = SHARING_FAILED;
				C.log(e);
				sharingError = "Net Error";
				init();
			});
			loader.addEventListener("securityError", function onFail(e:Event):void {
				sharingState = SHARING_FAILED;
				C.log(e);
				sharingError = "Security Error";
				init();
			});
			
			sharingState = SHARING_WAITING;
			sharingTime = 0;
			init();
		}
		
		override public function update():void {
			super.update();
			if (SHARING_WAITING == sharingState)
				checkTimeout();
			if (SHARING_SUCCESS == sharingState)
				checkClick();
		}
		
		protected function checkTimeout():void {
			sharingTime += FlxG.elapsed;
			if (sharingTime < TIMEOUT)
				return;
			
			sharingState = SHARING_FAILED;
			sharingError = "Timeout";
			init();
		}
		
		protected function checkClick():void {
			if (!FlxG.mouse.justPressed())
				return;
			if (textField.overlapsPoint(FlxG.mouse, true))
				return;
			
			sharingState = SHARING_READY;
			init();
		}
		
		private const SHARING_READY:int = 0;
		private const SHARING_SUCCESS:int = 1;
		private const SHARING_WAITING:int = 2;
		private const SHARING_FAILED:int = 3;
		
		private const TIMEOUT:Number = 8;
		
		[Embed(source = "../../lib/art/ui/share.png")] private const _ready_sprite:Class;
		[Embed(source = "../../lib/art/ui/erahs.png")] private const _waiting_sprite:Class;
		[Embed(source = "../../lib/art/ui/sharing_success.png")] private const _success_sprite:Class;
		[Embed(source = "../../lib/art/ui/sharing_failure.png")] private const _failure_sprite:Class;
		
		private const SPRITES:Array = [_ready_sprite, _success_sprite, _waiting_sprite, _failure_sprite];
		private function getText():String {
			switch (sharingState) {
				case SHARING_READY: return "Share";
				case SHARING_WAITING: return "Waiting...";
			case SHARING_SUCCESS:
					var path:String = ExternalInterface.available ? new QueryString().path : "http://pleasingfungus.com/mde2";
					return path + "?lvl="+Level.ALL.indexOf(U.state.level)+"&code="+sharingCode;
				case SHARING_FAILED: return sharingError;
				default: return sharingState.toString();
			}
		}
		
		override public function destroy():void {
			super.destroy();
			if (textField)
				textField.die();
		}
	}

}