package Menu
{
	import IreUtils.Input;
	import IreUtils.ResList;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class ButtonHex extends Sprite
	{
		private var callback:Function;
		private var downCallback:Function;
		
		private var buttonTextFormat:TextFormat = null;
		private var buttonLabel:TextField;
		
		private var bgSprite:Sprite;
		
		public var enabled:Boolean = true;
		
		private var mouseDownHere:Boolean = false;
		
		public function ButtonHex(text:String, callback:Function, bgImageName:String = null, maxFontSize:int = 14, color:int = -1, forceWidth:int = -1, forceHeight:int = -1)
		{
			super();
			
			this.callback = callback;
			this.downCallback = null;
			
			buttonTextFormat = new TextFormat("Arial", maxFontSize, color, true);
			buttonTextFormat.align = TextFormatAlign.CENTER;
			buttonTextFormat.rightMargin = 2;
			
			bgSprite = new Sprite();
			addChild(bgSprite);
			
			addEventListener(MouseEvent.MOUSE_UP, onClick, false, 0, true);
			addEventListener(MouseEvent.MOUSE_DOWN, playSound, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOut, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			var endWidth:int = ResList.GetArtResource(bgImageName + "_end").width;

			if(text != null) {
				buttonLabel = new TextField();
				buttonLabel.text = text;
				buttonLabel.setTextFormat(buttonTextFormat);
				buttonLabel.autoSize = TextFieldAutoSize.CENTER;
				
				if(width > 0) {
					while(buttonLabel.width > width - 10) {
						buttonTextFormat.size = int(buttonTextFormat.size) - 1;
						buttonLabel.setTextFormat(buttonTextFormat);
						buttonLabel.autoSize = TextFieldAutoSize.CENTER;
					}
				}
				if(forceWidth != -1) {
					buttonLabel.x = (forceWidth - endWidth * 2 - 6 - buttonLabel.width) / 2 + endWidth + 3;
				}
				else {
					buttonLabel.x = endWidth + 3;
				}
				
				buttonLabel.mouseEnabled = false;
				addChild(buttonLabel);
			}
			
			if(bgImageName != null) {
				var b:Bitmap = ResList.GetArtResource(bgImageName + "_end");
				b.x = endWidth;
				b.scaleX = -1;
				bgSprite.addChild(b);
				b = ResList.GetArtResource(bgImageName + "_mid");
				if(forceWidth != -1)
					b.width = forceWidth - endWidth * 2 + 1;
				else
					b.width = buttonLabel.width + 1 + 6;
				b.x = endWidth;
				bgSprite.addChild(b);
				b = ResList.GetArtResource(bgImageName + "_end");
				if(forceWidth != -1)
					b.x = forceWidth - endWidth;
				else
					b.x = endWidth + 6 + buttonLabel.width;
				bgSprite.addChild(b);
			}
			else {
				bgSprite.graphics.beginFill(0, 0);
				bgSprite.graphics.drawRect(0, 0, forceWidth, forceHeight);
			}
			
			if(buttonLabel) {
				buttonLabel.y = height / 2 - buttonLabel.height / 2;
			}
			
			useHandCursor = true;
			buttonMode = true;
		}
		
		public function onRemovedFromStage(event:Event):void {
			removeEventListener(MouseEvent.MOUSE_UP, onClick);
			removeEventListener(MouseEvent.MOUSE_DOWN, playSound);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			callback = null;
		}
		
		public function setText(text:String):void {
			buttonLabel.text = text;
			
			buttonTextFormat.size = 14;
			buttonLabel.setTextFormat(buttonTextFormat);
			buttonLabel.autoSize = TextFieldAutoSize.CENTER;
			
			while(buttonLabel.width > width - 10) {
				buttonTextFormat.size = int(buttonTextFormat.size) - 1;
				buttonLabel.setTextFormat(buttonTextFormat);
				buttonLabel.autoSize = TextFieldAutoSize.CENTER;
			}
			buttonLabel.x = width / 2 - buttonLabel.width / 2;
		}
		
		private function playSound(event:MouseEvent):void {
			if(!enabled) return;
		
			Input.mouseHandled = true;
			Input.mouseLockedToButton = true;
	
			if(callback != null) {
				G.sounds.playSound("button_click0");
			}
			
			mouseDownHere = true;
		}

		private function mouseOut(event:MouseEvent):void {
			mouseDownHere = false;
		}
		
		private function onClick(event:MouseEvent):void {
			if(!enabled || !mouseDownHere) return;
			
			if(callback != null) {
				Input.mouseHandled = true;
				callback();
			}
			
			mouseDownHere = false;
			Input.mouseLockedToButton = false;
		}
		
		public function setImage(imgName:String):void {
			var origWidth:int = width;
			
			while(bgSprite.numChildren > 0) bgSprite.removeChildAt(bgSprite.numChildren - 1);
			
			var endWidth:int = ResList.GetArtResource(imgName + "_end").width;
			var b:Bitmap = ResList.GetArtResource(imgName + "_end");
			b.x = endWidth;
			b.scaleX = -1;
			bgSprite.addChild(b);
			b = ResList.GetArtResource(imgName + "_mid");
			b.width = origWidth - endWidth*2 + 1;
			b.x = endWidth;
			bgSprite.addChild(b);
			b = ResList.GetArtResource(imgName + "_end");
			b.x = origWidth - endWidth;
			bgSprite.addChild(b);
			bgSprite.width = origWidth;
			
			buttonLabel.x = (width - buttonLabel.width) / 2;
		}
		
		public function setCallback(newCallback:Function):void {
			callback = newCallback;
		}
		
		public function setTextColor(textColor:int):void {
			buttonTextFormat.color = textColor;
			buttonLabel.setTextFormat(buttonTextFormat);
		}
		
		public function setOnDownCallback(downCallback:Function):void {
			if (null == this.downCallback) {
				addEventListener(MouseEvent.MOUSE_DOWN, downCallback, false, 0, true);
			}
			this.downCallback = downCallback;
		}
	}
}