package Menu.GameRoom
{
	import Game.Races.Race;
	
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.LevelIcon;
	import Menu.Lobby.PlayerInfoPopup;
	import Menu.Tooltips.TextTooltip;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class PlayerSlot extends Sprite
	{
		private var playerName:TextField;
		private var playerRating:TextField;
		public var index:int;
		private var kickCallback:Function;
		private var readyCallback:Function;
		
		private var bgSprite:Sprite;
		private var tf:TextFormat;
		private var readyButton:Button;
		private var isReady:Boolean;
		private var raceImage:Sprite;
		private var levelSprite:LevelIcon;
		//private var levelTooltip:TextTooltip;
		
		private var isMe:Boolean;
		private var isPremium:Boolean;
		private var tooltip:TextTooltip;
		
		private var playerKey:String;
		
		public function PlayerSlot(i:int, readyCallback:Function)
		{
			super();
			this.readyCallback = readyCallback;
			
			bgSprite = new Sprite();
			bgSprite.addChild(ResList.GetArtResource("gamePanel_player_long_empty"));
			addChild(bgSprite);
			
			tf = new TextFormat("Arial", 14, -1, true);
			tf.align = TextFormatAlign.LEFT;
				
			playerName = new TextField();
			playerName.x = 67;
			playerName.mouseEnabled = false;
			playerName.text = "Empty";
			playerName.setTextFormat(tf);
			playerName.autoSize = TextFieldAutoSize.LEFT;
			playerName.y = bgSprite.y + bgSprite.height / 2 - playerName.height / 2 - 2;
			addChild(playerName);
			
			playerRating = new TextField();
			playerRating.x = 67;
			playerRating.mouseEnabled = false;
			playerRating.defaultTextFormat = new TextFormat("Arial", 10, -1, true);
			playerRating.text = "R: ";
			playerRating.autoSize = TextFieldAutoSize.LEFT;
			playerRating.y = 3 * height / 4 - playerName.height / 2 - 2;
			playerRating.visible = false;
			addChild(playerRating);
			
			readyButton = new Button(null, null, ResList.GetArtResource("gameRoom_ready_disabled"));
			readyButton.x = 204;
			readyButton.y = 1;
			readyButton.visible = false;
			if(G.host != G.HOST_PLAYSMART) {
				addChild(readyButton);
			}
			
			raceImage = new Sprite();
			raceImage.mouseChildren = false;
			raceImage.x = raceImage.y = height / 2 - 30;
			addChild(raceImage);
			
			levelSprite = new LevelIcon(0);
			levelSprite.x = 46;
			addChild(levelSprite);
			
			index = i;
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		private function onRemovedFromStage(event:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			if(tooltip) {
				tooltip.remove();
				tooltip = null;
			}
		}
		
		public function setMe():void {
			tf.color = 0;
			isMe = true;
			if(kickCallback != null && readyButton.visible) {
				readyButton.visible = false;
			}
			
			playerKey = null;
			bgSprite.removeEventListener(MouseEvent.CLICK, onMouseClicked);
		}
		
		private function kickClick(button:Button):void {
			if(readyButton.visible) {
				kickCallback(index);
			}
		}
		
		public function addKickButton(callback:Function):void {
			kickCallback = callback;
			
			if(readyButton.visible) {
				if(isMe) {
					readyButton.visible = false;
				}
				else {
					readyButton.setImage("gameRoom_kick");
					readyButton.setCallback(kickClick);
					readyButton.enabled = true;
				}
			}
		}
		
		public function removeKickButton():void {
			if(readyButton.visible) {
				readyButton.visible = false;
			}
		}
		
		private function onKickClicked(button:Button):void {
			kickCallback(index);
		}
		
		public function setName(name:String, premium:Boolean, playerKey:String, rating:int):void {
			isPremium = premium;
			tf.color = isPremium ? 0xFFC600 : -1; 
			
			playerName.text = name;
			playerName.setTextFormat(tf);
			
			tf.size = 14;
			while(playerName.width > 136) {
				tf.size = (int)(tf.size) - 1;
				playerName.setTextFormat(tf);
			}
			playerName.y = height / 2 - playerName.height / 2 - 2;
			
			readyButton.visible = true;
			
			// enable info popup for registered players (but not me)
			if(name != G.user.name && playerKey != "") {
				this.playerKey = playerKey;
				bgSprite.addEventListener(MouseEvent.CLICK, onMouseClicked);
				useHandCursor = true;
				buttonMode = true;
			}
			
			if(rating != 0) {
				playerRating.text = "R: " + rating;
				playerRating.visible = true;
				
				playerName.y = height / 4 - playerName.height / 2 + 1;
			}
		}
		
		public function setRace(raceID:int):void {
			var race:Race = Race.Create(raceID);
			if(raceImage.numChildren > 0) raceImage.removeChildAt(0);
			raceImage.addChild(race.symbolSmall);
			if(tooltip) {
				tooltip.remove();
			}
			tooltip = new TextTooltip(race.name + "\n" + race.bonusDesc, raceImage);
		}
		
		public function setLevel(level:int):void {
			if(level > 0) {
				levelSprite.setLevel(level);
				//levelSprite.y = playerName.y + playerName.height / 2 - levelSprite.height / 2;
				levelSprite.y = bgSprite.y + bgSprite.height / 2 - levelSprite.height / 2 - 2;
			}
		}
		
		public function clear():void {
			isPremium = false;
			bgSprite.addChild(ResList.GetArtResource("gamePanel_player_long_empty"));
			tf.color = -1;
			playerName.text = "Empty";
			tf.size = 14;
			playerName.setTextFormat(tf);
			playerName.y = bgSprite.y + bgSprite.height / 2 - playerName.height / 2 - 2;
			playerRating.visible = false;
			
			readyButton.visible = false;
			isReady = false;
			if(raceImage.numChildren > 0)
				raceImage.removeChildAt(0);
			if(tooltip) {
				tooltip.remove();
				tooltip = null;
			}
			levelSprite.setLevel(0);
			
			playerKey = null;
			bgSprite.removeEventListener(MouseEvent.CLICK, onMouseClicked);
		}
		
		public function setReady(ready:Boolean):void {
			isReady = ready;
			if(kickCallback == null && readyButton.visible) {
				if(ready) {
					readyButton.setImage("gameRoom_ready");
					readyButton.enabled = false;
				}
				else {
					readyButton.setImage("gameRoom_ready_disabled");
					readyButton.enabled = true;
				}
				
				if(isMe)
					readyButton.setCallback(readyCallback);
				else 
					readyButton.setCallback(null);
			}
			bgSprite.removeChildAt(0);
			if(isReady) {
				bgSprite.addChild(ResList.GetArtResource("gamePanel_player_long_3"));
			}
			else {
				bgSprite.addChild(ResList.GetArtResource("gamePanel_player_long_empty"));
			}
			tf.color = isPremium ? 0xFFC600 : -1;
			playerName.setTextFormat(tf);
		}
		
		public function getReady():Boolean {
			return isReady;
		}
		
		public function isOccupied():Boolean {
			return playerName.text != "Empty";
		}
		
		private function onMouseClicked(event:MouseEvent):void {
			if(!G.user.isGuest) {
				var pos:Point = new Point(width / 2 - 136 / 2, 0);
				pos = localToGlobal(pos);
				G.errorSprite.addChild(new PlayerInfoPopup(playerKey, pos.x, pos.y + height - 12, height, null));
			}
		}
	}
}