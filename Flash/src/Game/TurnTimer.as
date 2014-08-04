package Game
{
	import IreUtils.ResList;
	
	import Menu.Button;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundChannel;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class TurnTimer extends Sprite
	{
		public static const MAX_TIME:int = 20;
		
		private var remainingTime:Number;
		private var active:Boolean;
		private var isMyTurn:Boolean;
		
		private var greenFill:Sprite;
		private var redFill:Sprite;
		private var maskFill:Sprite;
		private var fillWrap:Sprite;
		
		//private var endTurnButton:Button;
		private var endTurnButton:Sprite;
		private var endTurnCallback:Function;
		
		private var blinkTimer:Number = -1;
		
		//private var endSound:SoundChannel;
		
		public function TurnTimer(endTurn:Function)
		{
			super();
			
			x = 5;
			y = 543;
			
			endTurnCallback = endTurn;
			
			addChild(ResList.GetArtResource("turnTimer_bg"));
			
			endTurnButton = new Sprite();
			endTurnButton.addChild(ResList.GetArtResource("turnTimer_button_yellow"));
			endTurnButton.addChild(ResList.GetArtResource("turnTimer_button_red"));
			endTurnButton.x = 3;
			endTurnButton.y = 3;
			endTurnButton.getChildAt(1).visible = false;
			endTurnButton.addEventListener(MouseEvent.CLICK, onEndClicked);
			endTurnButton.useHandCursor = true;
			endTurnButton.buttonMode = true;
			addChild(endTurnButton);
			
			fillWrap = new Sprite();
			fillWrap.x = 7;
			fillWrap.y = 33;
			addChild(fillWrap);
			
			maskFill = new Sprite();
			//maskFill.addChild(ResList.GetArtResource("turnTimer_bar_green"));
			fillWrap.mask = maskFill;
			fillWrap.addChild(maskFill);
			
			greenFill = new Sprite();
			greenFill.addChild(ResList.GetArtResource("turnTimer_bar_green"));
			fillWrap.addChild(greenFill);
			
			redFill = new Sprite();
			redFill.addChild(ResList.GetArtResource("turnTimer_bar_red"));
			fillWrap.addChild(redFill);
		}
		
		private function onEndClicked(event:MouseEvent):void {
			endTurnCallback();
		}
		
		public function update(timeDelta:Number):void {
			if(active)
				remainingTime -= timeDelta;
			
			if(remainingTime < 0) remainingTime = 0;
			
			greenFill.visible = remainingTime > 8;
			redFill.visible = remainingTime <= 8;
			
			if(isMyTurn) {
				if((remainingTime < 5 && remainingTime + timeDelta >= 5) || (remainingTime < 4 && remainingTime + timeDelta >= 4) || (remainingTime < 3 && remainingTime + timeDelta >= 3)) {
					G.sounds.playSound("turn_ending");
				}
				if((remainingTime < 2 && remainingTime + timeDelta >= 2) || (remainingTime < 1.6 && remainingTime + timeDelta >= 1.6) || (remainingTime < 1.2 && remainingTime + timeDelta >= 1.2) || (remainingTime < 0.8 && remainingTime + timeDelta >= 0.8) || (remainingTime < 0.4 && remainingTime + timeDelta >= 0.4)) {
					G.sounds.playSound("turn_ending_fast");
				} 
			}
			// blinking
			if(remainingTime < 5) {
				fillWrap.visible = (int)(remainingTime + 0.5) == (int)(remainingTime);
			}
			else {
				fillWrap.visible = true;
			}
			
			maskFill.graphics.clear();
			maskFill.graphics.beginFill(0);
			maskFill.graphics.moveTo(0, 0);
			maskFill.graphics.lineTo(153 * (remainingTime) / MAX_TIME - 14, 0); 
			maskFill.graphics.lineTo(153 * (remainingTime) / MAX_TIME, 14);
			maskFill.graphics.lineTo(0, 14);
			
			if(blinkTimer == -1) {
				endTurnButton.getChildAt(1).visible = false;
			}
			else {
				blinkTimer += 5*timeDelta;
				endTurnButton.getChildAt(1).visible = true;
				endTurnButton.getChildAt(1).alpha = (Math.sin(blinkTimer) + 1)/2;
			}
		}
		
		public function addTime(newTime:int):void {
			remainingTime += newTime;
			if(remainingTime > MAX_TIME) {
				remainingTime = MAX_TIME;
			}
		}
		
		public function stop():void {
			active = false;
			blinkTimer = -1;
			endTurnButton.getChildAt(1).visible = false;
			
			/*if(endSound) {
				endSound.stop();
				endSound = null;
			}*/
		}
		
		public function resume():void {
			active = true;
		}
		
		public function reset(newTime:int = -1):void {
			active = true;
			if(newTime == -1)
				remainingTime = MAX_TIME;
			else
				remainingTime = newTime;
		}
		
		public function setEndTurnButtonVisible(isVisible:Boolean):void {
			endTurnButton.visible = isVisible;
		}
		
		public function startButtonHighlight():void {
			blinkTimer = 0;
		}
		
		public function setIsMyTurn(isMyTurn:Boolean):void {
			this.isMyTurn = isMyTurn;
		}
		
		public function substractTime(t:Number):void {
			remainingTime -= t;
		}
		
		public function setRemainingTime(t:int):void {
			remainingTime = t;
		}
	}
}