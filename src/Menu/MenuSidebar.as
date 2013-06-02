package Menu {
	import org.flixel.*;
	import UI.GraphicButton;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class MenuSidebar extends FlxGroup {
		
		public var height:int;
		private var color:uint;
		private var bg:FlxSprite;
		public function MenuSidebar(Height:int, Color:uint = 0xffbcbcbc) {
			height = Height;
			color = Color;
			super();
			init();
		}
		
		protected function init():void {
			members = [];
			
			add(bg = new FlxSprite(0, FlxG.height - height).makeGraphic(FlxG.width, height, color));
			bg.scrollFactor.x = bg.scrollFactor.y = 0;
			
			var titleText:FlxText = U.TITLE_FONT.configureFlxText(new FlxText(8, bg.y + 12, bg.width - 16, "MDE2"), 0xffffff, 'center', 0x1);
			titleText.scrollFactor = bg.scrollFactor;
			add(titleText);
			
			var howToPlay:GraphicButton = new GraphicButton(40, bg.y, _info_sprite, function onSelect():void {
				FlxG.switchState(new HowToPlayState);
			}, "How To Play").setScroll(0);
			howToPlay.Y += (bg.height - howToPlay.fullHeight) / 2;
			howToPlay.fades = true;
			add(howToPlay);
		}
		
		override public function update():void {
			super.update();
			if (bg.overlapsPoint(FlxG.mouse, true))
				U.buttonManager.moused = true;
		}
		
		[Embed(source = "../../lib/art/ui/info.png")] private const _info_sprite:Class;
	}

}