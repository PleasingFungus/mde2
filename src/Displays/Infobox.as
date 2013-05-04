package Displays {
	import org.flixel.*;
	import UI.Scrollbar;
	import Controls.ControlSet;
	import UI.GraphicButton;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Infobox extends FlxGroup {
		
		protected var bg:FlxSprite;
		private var scrollbar:Scrollbar;
		private var scroll:int;
		protected var page:InfoboxPage;
		private var pageTop:int;
		private var pageBottom:int;
		public function Infobox() {
			super();
			init();
		}
		
		protected function init():void {
			members = [];
			makeBG();
			makeCloseButton();
			add(page = new InfoboxPage(bg.width - RAISED_BORDER_WIDTH * 4, bg.height - RAISED_BORDER_WIDTH * 4));
			
			pageTop = bg.y + RAISED_BORDER_WIDTH * 2;
			pageBottom = bg.y + bg.height - RAISED_BORDER_WIDTH * 2;
			var lastScrollFraction:Number = NaN;
			if (scrollbar)
				lastScrollFraction = scrollbar.scrollFraction;
			add(scrollbar = new Scrollbar(bg.x + bg.width - 48/2 - RAISED_BORDER_WIDTH * 3,
										  pageTop + INNER_BORDER, pageBottom - pageTop - INNER_BORDER * 2));
			if (!isNaN(lastScrollFraction))
				scrollbar.scrollFraction = lastScrollFraction;
			
			var lineHeight:int = U.BODY_FONT.configureFlxText(new FlxText( -1, -1, 10000, "Example")).height + 6;
			scrollbar.arrowScrollFraction = lineHeight / (pageBottom - pageTop);
			
			scroll = 0;
		}
		
		protected function setPageTop(top:int):void {
			pageTop = top;
			page.setDimensions(bg.width - RAISED_BORDER_WIDTH * 4, pageBottom - pageTop);
		}
		
		protected function makeBG():void {
			var shade:FlxSprite = new FlxSprite;
			shade.makeGraphic(FlxG.width, FlxG.height, 0xff000000);
			shade.alpha = 0.4;
			add(shade);
			
			var width:int = FlxG.width * WIDTH_FRACTION;
			var height:int = FlxG.height * HEIGHT_FRACTION;
			bg = new FlxSprite((FlxG.width - width) / 2, (FlxG.height - height) / 2).makeGraphic(width, height, 0xff202020);
			
			var light:FlxSprite = new FlxSprite().makeGraphic(width - RAISED_BORDER_WIDTH * 2, height - RAISED_BORDER_WIDTH * 2, 0xff666666)
			bg.stamp(light, RAISED_BORDER_WIDTH, RAISED_BORDER_WIDTH);
			
			var innerDark:FlxSprite = new FlxSprite().makeGraphic(width - RAISED_BORDER_WIDTH * 4, height - RAISED_BORDER_WIDTH * 4, 0xff202020)
			bg.stamp(innerDark, RAISED_BORDER_WIDTH * 2, RAISED_BORDER_WIDTH * 2);
			
			add(bg);
		}
		
		protected function makeCloseButton():void {
			var kludge:Infobox = this;
			add(new GraphicButton(bg.x + INNER_BORDER, bg.y + INNER_BORDER,
								  _close_sprite, function close():void { kludge.exists = false } ))
		}
		
		override public function update():void {
			super.update();
			checkScroll();
			checkControls();
			if (bg.overlapsPoint(FlxG.mouse, true))
				U.buttonManager.moused = true;
		}
		
		private function checkScroll():void {
			var pageHeight:int = getPageHeight();
			var scrollDistance:int = pageHeight - (pageBottom - pageTop);
			scrollbar.exists = scrollDistance > 0;
			if (!scrollbar.exists)
				return;
			
			var scrollFraction:Number = scrollbar.scrollFraction;
			var newScroll:int = -scrollDistance * scrollFraction;
			var delta:int = newScroll - scroll;
			if (delta)
				for each (var o:FlxObject in page.members)
					o.y += delta;
			scroll = newScroll;
		}
		
		protected function getPageHeight():int {
			var height:int = 0;
			for each (var o:FlxObject in page.members)
				height = Math.max(o.y - pageTop - scroll + o.height, height);
			return height;
		}
		
		protected function checkControls():void {
			if (FlxG.mouse.justPressed() && !bg.overlapsPoint(FlxG.mouse, true)) // && tick?
				exists = false;
			if (ControlSet.CANCEL_KEY.justPressed())
				exists = false;
		}
		
		
		override public function draw():void {
			page.setLoc(bg.x + RAISED_BORDER_WIDTH * 2, pageTop);
			super.draw();
		}
		
		[Embed(source = "../../lib/art/ui/close.png")] private const _close_sprite:Class;
		
		protected const RAISED_BORDER_WIDTH:int = 2;
		protected const INNER_BORDER:int = RAISED_BORDER_WIDTH * 2 + 6;
		protected const WIDTH_FRACTION:Number = 3 / 4;
		protected const HEIGHT_FRACTION:Number = 3 / 4;
	}

}