package Menu
{
	import IreUtils.Input;
	import IreUtils.ResList;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class Button extends Sprite
	{
		private var callback:Function;
		private var downCallback:Function;
		
		private var buttonTextFormat:TextFormat = null;
		private var buttonLabel:TextField;
		
		private var bgSprite:Sprite;
		
		public var enabled:Boolean = true;
		
		private var mouseDownHere:Boolean = false;
		
		public var userData:int = 0;
		
		public function Button(text:String, callback:Function, bitmap:DisplayObject = null, maxFontSize:int = 14, color:int = -1, forceWidth:int = 100, forceHeight:int = 40)
		{
			super();
			
			this.callback = callback;
			this.downCallback = null;
			
			buttonTextFormat = new TextFormat();
			buttonTextFormat.font = "Arial";
			buttonTextFormat.bold = true;
			buttonTextFormat.size = maxFontSize;
			buttonTextFormat.align = TextFormatAlign.CENTER;
			buttonTextFormat.color = color;
			
			bgSprite = new Sprite();
			addChild(bgSprite);
			
			if(bitmap != null) {
				bgSprite.addChild(bitmap);
			}
			else {
				bgSprite.graphics.beginFill(0, 0);
				bgSprite.graphics.drawRect(0, 0, forceWidth, forceHeight);
			}
			
			addEventListener(MouseEvent.MOUSE_UP, onClick, false, 0, true);
			addEventListener(MouseEvent.MOUSE_DOWN, playSound, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOut, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			if(text != null) {
				buttonLabel = new TextField();
				buttonLabel.text = text;
				buttonLabel.setTextFormat(buttonTextFormat);
				buttonLabel.autoSize = TextFieldAutoSize.CENTER;
				
				while(buttonLabel.width > width - 10) {
					buttonTextFormat.size = int(buttonTextFormat.size) - 1;
					buttonLabel.setTextFormat(buttonTextFormat);
					buttonLabel.autoSize = TextFieldAutoSize.CENTER;
				}
				
				buttonLabel.x = width / 2 - buttonLabel.width / 2;
				buttonLabel.y = height / 2 - buttonLabel.height / 2;
				
				buttonLabel.mouseEnabled = false;
				addChild(buttonLabel);
			}
			
			useHandCursor = true;
			buttonMode = true;
		}
		
		public function onRemovedFromStage(event:Event):void {
			removeEventListener(MouseEvent.MOUSE_UP, onClick);
			removeEventListener(MouseEvent.MOUSE_DOWN, playSound);
			removeEventListener(MouseEvent.MOUSE_OUT, mouseOut);
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
			
			Input.mouseHandled = true;
			if(callback != null) {
				callback(this);
				event.stopImmediatePropagation();
			}

			Input.mouseLockedToButton = false;
			mouseDownHere = false;
		}
		
		public function setImage(imgName:String):void {
			while(bgSprite.numChildren > 0) bgSprite.removeChildAt(bgSprite.numChildren - 1);
			
			bgSprite.addChild(ResList.GetArtResource(imgName));
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