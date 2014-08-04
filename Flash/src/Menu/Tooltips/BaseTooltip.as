package Menu.Tooltips
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	public class BaseTooltip extends Sprite
	{
		private var ownerSprite:DisplayObject;
		private var timer:Timer;
		private var lastX:int, lastY:int;
		
		public function BaseTooltip(owner:DisplayObject)
		{
			super();

			ownerSprite = owner;
			
			owner.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
			owner.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			owner.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut, false, 0, true);
			
			owner.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
		}
		
		private function onRemovedFromStage(event:Event):void {
			remove();
		}
		
		public function remove():void {
			if(G.tooltipSprite.contains(this))
				G.tooltipSprite.removeChild(this);
			
			if(ownerSprite) {
				ownerSprite.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
				ownerSprite.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				ownerSprite.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				ownerSprite.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			}
			
			ownerSprite = null;
			
			if(timer) {
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerFired);
				timer = null;
			}
		}
		
		private function onMouseOver(event:MouseEvent):void {
			//visible = true;
			timer = new Timer(400, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerFired, false, 0, true);
			timer.start();
			
			lastX = event.stageX;
			lastY = event.stageY;
		}
		
		private function onTimerFired(event:TimerEvent):void {
			G.tooltipSprite.addChild(this);
			//visible = true;
			
			x = lastX + 10;  
			y = lastY + 12;
			if(x + width > 800) {
				x = lastX - width;
			}
		}
		
		private function onMouseMove(event:MouseEvent):void {
			lastX = event.stageX;
			lastY = event.stageY;
			
			if(!G.tooltipSprite.contains(this)) return;
			//if(!visible) return;
			
			x = event.stageX + 10;  
			y = event.stageY + 10;  
			
			if(x + width > 800) {
				x = lastX - width;
			}
		}
		
		private function onMouseOut(event:MouseEvent):void {
			if(G.tooltipSprite.contains(this))
				G.tooltipSprite.removeChild(this);
			//visible = false;
			if(timer) {
				timer.stop();
				timer = null;
			}
		}
	}
}