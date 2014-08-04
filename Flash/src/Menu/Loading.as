package Menu
{
	import IreUtils.ResList;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class Loading extends Sprite
	{
		private var lights:Array;
		private var lightTime:Number = 0;
		
		public var timeDelta:Number = 0;
		private var oldTime:Number = 0;
		private var prevTimeDelta:Number = 0;
		
		public function Loading(loadingText:String = "CONNECTING...", useBg:Boolean = true)
		{
			super();
			
			if(useBg) {
				graphics.beginFill(0, 0.8);
				graphics.drawRect(0, 0, 800, 600);
			}
			
			var bg:Sprite = new Sprite(); 
			bg.addChild(ResList.GetArtResource("loading_bg"));
			addChild(bg);
			
			lights = new Array();
			for(var i:int = 0; i < 6; ++i) {
				var b:Bitmap = ResList.GetArtResource("loading_light"); 
				bg.addChild(b);
				lights.push(b);
				b.alpha = 0;
			}
			lights[0].alpha = 1;
			lights[0].x = 23;
			lights[1].x = 46;
			lights[1].y = 14;
			lights[2].x = 46;
			lights[2].y = 40;
			lights[3].x = 23;
			lights[3].y = 54;
			lights[4].y = 40;
			lights[5].y = 14;
			
			var txtFormat:TextFormat = new TextFormat("Arial", 20, -1, true);
			txtFormat.align = TextFormatAlign.CENTER;
			
			var text:TextField = new TextField();
			text.text = loadingText;
			text.setTextFormat(txtFormat);
			text.autoSize = TextFieldAutoSize.CENTER;
			text.mouseEnabled = false;
			addChild(text);
			
			// set position after text is added to sprite, because it is usually wider and we need it to resize sprite first
			text.x = width / 2 - text.width / 2;
			text.y = height / 2 - text.height / 2 + 60;
			bg.x = width / 2 - bg.width / 2;
			if(useBg) {
				bg.y = height / 2 - bg.height / 2;
			}

			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		
		private function update(event:Event):void {
			prevTimeDelta = timeDelta;
			var time:Number = (new Date).getTime();
			timeDelta = (5*prevTimeDelta + (time - oldTime)/1000)/6;
			oldTime = time;
			if (timeDelta > 0.1)
				timeDelta = 0.1;
			
			lightTime += timeDelta * 2;
			if(lightTime >= 6) {
				lightTime -= 6;
			}
			
			var lightIndex:int = lightTime;
			
			for(var i:int = 0; i < 6; i++) {
				lights[i].alpha = 0;
			}
			lights[lightIndex].alpha = 1 - (lightTime - lightIndex);
			lights[(lightIndex + 1) % 6].alpha = lightTime - lightIndex;
		}
	}
}