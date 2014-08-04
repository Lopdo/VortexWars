package Menu
{
	import IreUtils.Input;
	
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	public class ButtonContextMenu extends Sprite
	{
		private var buttonCallbacks:Array;
		private var bg:Sprite;
		
		public function ButtonContextMenu(buttonTitles:Array, buttonCallbacks:Array, posX:int, posY:int, offsetHeight:int)
		{
			super();

			this.buttonCallbacks = buttonCallbacks;
			
			graphics.beginFill(0, 0.3);
			graphics.drawRect(0, 0, 800, 600);
			graphics.beginFill(0, 0);
			graphics.drawRect(posX, posY - height, 136, height);
			
			addEventListener(MouseEvent.CLICK, onMouseClick);
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			bg = new NinePatchSprite("9patch_context", 116, 46 * buttonTitles.length);
			bg.x = posX;
			if(posY + bg.height > 580) {
				bg.y = posY - offsetHeight - bg.height;
			}
			else {
				bg.y = posY;
			}
			
			addChild(bg);
			
			var button:ButtonHex;
			for(var i:int = 0; i < buttonTitles.length; i++) {
				button = new ButtonHex(buttonTitles[i], buttonCallbacks[i], "button_small_gray", 14, -1, 110);
				button.x = bg.width / 2 - button.width / 2;
				button.y = 4 + 46 * i;
				bg.addChild(button);
			}
		}
		
		private function onMouseClick(event:MouseEvent):void {
			//if(event.stageX < bg.x || event.stageX > bg.x + bg.width || event.stageY < bg.y || event.stageY > bg.y + bg.height) {
				removePopup();
			//}
		}
		
		private function onKeyDown(event:KeyboardEvent):void {
			if(event.keyCode == Input.KEY_ESC) {
				removePopup();
			}
		}
		
		private function removePopup():void {
			removeEventListener(MouseEvent.CLICK, onMouseClick);
			removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			parent.removeChild(this);
		}
	}
}