package Displays {
	import Controls.Key;
	import flash.geom.Rectangle;
	import org.flixel.*;
	import UI.GraphicButton;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DTime extends FlxGroup {
		
		public var x:int;
		public var y:int;
		
		private var timeText:FlxText;
		private var timeBox:FlxSprite;
		private var stepButton:GraphicButton;
		private var backstepButton:GraphicButton;
		private var playButton:GraphicButton;
		private var rewindButton:GraphicButton;
		private var pauseButton:GraphicButton;
		private var stopButton:GraphicButton;
		
		private var playing:int;
		private var ticksPerSec:Number;
		
		private var derock:int;
		public function DTime(X:int, Y:int) {
			super();
			x = X;
			y = Y;
			ticksPerSec = 2;
			create();
		}
		
		public function create():void {
			var textWidth:int = 50;
			timeText = new FlxText(x + width/2 -textWidth / 2, y, textWidth, U.state.time.toString());
			timeText.setFormat(U.FONT, 16);
			
			var timeBorder:int = 2;
			timeBox = new FlxSprite(timeText.x - timeBorder, timeText.y - timeBorder);
			timeBox.makeGraphic(timeText.width + timeBorder * 2, timeText.height + timeBorder * 2, 0xff666666, true, "TIME BOX");
			timeBox.framePixels.fillRect(new Rectangle(timeBorder, timeBorder, timeText.width, timeText.height), 0xff202020);
			
			add(timeBox);
			add(timeText);
			
			stepButton = new GraphicButton(timeBox.x, timeBox.y + timeBox.height / 2, _step_sprite, U.state.time.step, new Key("L"));
			stepButton.X -= stepButton.fullWidth;
			stepButton.Y -= stepButton.fullHeight / 2;
			add(stepButton);
			
			playButton = new GraphicButton(stepButton.X, stepButton.Y, _play_sprite, function play():void {
				if (!derock) return;
				
				startPlaying();
				derock = 0;
			}, new Key("SPACE"));
			playButton.X -= playButton.fullWidth;
			add(playButton);
			
			pauseButton = new GraphicButton(playButton.X, playButton.Y, _pause_sprite, function pause():void {
				if (!derock) return;
				
				playing = 0;
				derock = 0;
			}, new Key("SPACE"));
			pauseButton.X -= playButton.fullWidth;
			pauseButton.exists = false;
			add(pauseButton);
			
			stopButton = new GraphicButton(timeBox.x + timeBox.width, stepButton.Y, _stop_sprite, function reset():void {
				U.state.time.reset();
				playing = 0;
			}, new Key("BACKSPACE"));
			add(stopButton);
			
			backstepButton = new GraphicButton(stopButton.X + stopButton.fullWidth, stopButton.Y, _backstep_sprite, U.state.time.backstep, new Key("K"));
			add(backstepButton);
			
			rewindButton = new GraphicButton(backstepButton.X + backstepButton.fullWidth, backstepButton.Y, _back_sprite, function back():void {
				if (!derock) return;
				
				playing = -1;
				timeSinceToggle = 0;
				derock = 0;
			}, new Key("M"));
			add(rewindButton);
			rewindButton.exists = false;
		}
		
		override public function update():void {
			super.update();
			if (playing)
				run();
			timeText.text = U.state.time.toString();
			
			stopButton.exists = backstepButton.exists = U.state.time.moment > 0;
			playButton.exists = playing != 1;
			pauseButton.exists = playing != 0;
			rewindButton.exists = playing != -1 && U.state.time.moment > 0;
			
			derock++;
		}
		
		protected var timeSinceToggle:Number;
		protected function run():void {
			timeSinceToggle += FlxG.elapsed;
			var timePerTick:Number = 1 / ticksPerSec;
			while (timeSinceToggle >= timePerTick) {
				if (playing > 0)
					U.state.time.step();
				else
					if (!U.state.time.backstep())
						playing = 0;
				timeSinceToggle -= timePerTick;
			}
		}
		
		public function startPlaying(speed:int = 1):void {
			playing = speed;
			timeSinceToggle = 0;
		}
		
		private const width:int = 100;
		
		[Embed(source = "../../lib/art/ui/skip.png")] private const _step_sprite:Class;
		[Embed(source = "../../lib/art/ui/skip_back.png")] private const _backstep_sprite:Class;
		[Embed(source = "../../lib/art/ui/play.png")] private const _play_sprite:Class;
		[Embed(source = "../../lib/art/ui/back.png")] private const _back_sprite:Class;
		[Embed(source = "../../lib/art/ui/stop.png")] private const _stop_sprite:Class;
		[Embed(source = "../../lib/art/ui/pause.png")] private const _pause_sprite:Class;
	}

}