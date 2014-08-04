package Menu.MainMenu
{
	import IreUtils.ResList;
	
	import Menu.Lobby.Slider;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class ScrollableSprite extends Sprite
	{
		protected var scrollableWidth:int;
		protected var scrollableHeight:int;
		
		protected var contentSprite:Sprite;
		protected var contentHeight:Number = 0;
		
		protected var slider:Slider;
		
		private var previousMouseY:int = -1;
		private var sliderInitialized:Boolean = false;

		public function ScrollableSprite(w:int, h:int)
		{
			super();
			
			contentSprite = new Sprite();
			contentSprite.scrollRect = new Rectangle(0, 0, w - 15, h);
			addChild(contentSprite);
			
			var b:Bitmap = ResList.GetArtResource("slider_bg_end");
			b.x = w - 15;
			addChild(b);
			
			b = ResList.GetArtResource("slider_bg_end");
			b.x = w - 15;
			b.y = h;
			b.scaleY = -1;
			addChild(b);
			
			b = ResList.GetArtResource("slider_bg_mid");
			b.x = w - 15;
			b.y = 10;
			b.height = h - 20;
			addChild(b);
			
			slider = new Slider();
			slider.setSize(h - 4);
			slider.x = w - slider.width - 2;
			slider.y = 2;
			slider.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			slider.useHandCursor = true;
			slider.buttonMode = true;
			addChild(slider);
		}
		
		private function onMouseDown(event:MouseEvent):void {
			if(contentHeight <= contentSprite.scrollRect.height) {
				contentSprite.scrollRect = new Rectangle(0, 0, width - 15, contentSprite.scrollRect.height);
				return;
			}
			
			previousMouseY = event.stageY;
			
			if(!sliderInitialized) {
				stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
				sliderInitialized = true;
			}
		}
		
		private function onMouseMove(event:MouseEvent):void {
			if(previousMouseY != -1) {
				var offsetY:int = event.stageY - previousMouseY;
				previousMouseY = event.stageY;
				var maxOffsetY:int = contentSprite.scrollRect.height - 4 - slider.size;
				slider.y += offsetY;
				if(slider.y < 2) slider.y = 2;
				if(slider.y > maxOffsetY) slider.y = maxOffsetY;
				
				var progressRatio:Number = (slider.y - 2) / maxOffsetY;
				var newHeight:int = (contentHeight - contentSprite.scrollRect.height) * progressRatio;
				if(newHeight < 0) newHeight = 0;
				contentSprite.scrollRect = new Rectangle(0, newHeight, width - 10, height);
			}
		}
		
		private function onMouseUp(event:MouseEvent):void {
			previousMouseY = -1;
		}
		
		private function updateSliderSize():void {
			if(contentHeight <= contentSprite.scrollRect.height) {
				slider.setSize(contentSprite.scrollRect.height - 4);
				slider.y = 2;
				contentSprite.scrollRect = new Rectangle(0, 0, width - 10, contentSprite.scrollRect.height);
			}
			else {
				slider.setSize(contentSprite.scrollRect.height * (contentSprite.scrollRect.height / contentHeight) - 4);
				
				if(slider.y + slider.size > contentSprite.scrollRect.height - 4) {
					slider.y = contentSprite.scrollRect.height - slider.size - 4;
				}
				
				var range:int = contentSprite.scrollRect.height - 4 - slider.size;
				var progressRatio:Number = (slider.y - 2) / range;
				contentSprite.scrollRect = new Rectangle(0, (contentHeight - contentSprite.scrollRect.height) * progressRatio, width - 10, contentSprite.scrollRect.height);
			}
		}
		
		public function addSprite(item:DisplayObject):void {
			contentSprite.addChild(item);
			
			var newSpriteBottom:int = item.y + item.height;
			if(newSpriteBottom > contentHeight) {
				contentHeight = newSpriteBottom;
				updateSliderSize();
			}
		}
		
		public function removeAllItems():void {
			while(contentSprite.numChildren > 0) contentSprite.removeChildAt(contentSprite.numChildren - 1);
			
			contentHeight = 0;
			updateSliderSize();
		}
		
		public function removeItem(item:Sprite):void {
			var itemY:Number = item.y;
			var itemHeight:Number = item.height;
			
			contentSprite.removeChild(item);
			
			var newHeight:Number = 0;
			
			var i:int;
			for(i = 0; i < contentSprite.numChildren; i++) {
				var s:DisplayObject = contentSprite.getChildAt(i);
				if(s.y > itemY) {
					s.y -= itemHeight;
				}
				
				// also find item with lowest bottom
				if(s.y + s.height > newHeight) {
					newHeight = s.y + s.height; 
				}
			}
			
			contentHeight = newHeight;
		}
	}
}