package Menu.Lobby
{
	import IreUtils.Input;
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.LevelIcon;
	import Menu.Tooltips.TextTooltip;
	import Menu.Upgrades.RanksScreen;
	
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
	
	import playerio.DatabaseObject;
	
	public class LobbyChatPlayer extends Sprite
	{
		public var ID:int;
		public var username:String;
		public var playerKey:String;
		public var isPremium:Boolean;
		public var isModerator:Boolean;
		public var isFriend:Boolean = false;
		
		private var detailClickSprite:Sprite;
		//private var tooltip:TextTooltip;
		
		//private var bd:BitmapData;
		
		private var muteButton:Button;
		
		public function LobbyChatPlayer(name:String, level:int, isPremium:Boolean, isModerator:Boolean, id:int, playerKey:String, rating:int)
		{
			super();
			
			ID = id;
			username = name;
			this.isPremium = isPremium;
			this.isModerator = isModerator;
			this.playerKey = playerKey;
			
			addChild(getCorrectBg());
			//addChild(ResList.GetArtResource(isModerator ? "lobby_chatListUserModerator_bg" : (isPremium ? "lobby_chatListUserPremium_bg" : "lobby_chatListUser_bg")));
			
			var tf:TextFormat = new TextFormat("Arial", 12, isModerator ? 0xc2e4f9 : (isPremium ?  0xF5E192 : 0xBAAF96), true);
			
			var nameField:TextField = new TextField();
			nameField.defaultTextFormat = tf;
			nameField.text = name.toUpperCase();
			nameField.width = 88;
			nameField.x = 42;
			nameField.autoSize = TextFieldAutoSize.LEFT;
			//nameField.y = (height - 8) / 2 - nameField.height / 2;
			nameField.mouseEnabled = false;
			addChild(nameField);
			
			while(nameField.width > 88) {
				tf.size = (int)(tf.size) - 1;
				nameField.setTextFormat(tf);
			}
			if(rating == 0)
				nameField.y = 3 + 30 / 2 - nameField.height / 2;
			else
				nameField.y = 4 + 15 / 2 - nameField.height / 2;
			
			tf.size = 10;
			
			if(rating != 0) {
				var ratingField:TextField = new TextField();
				ratingField.defaultTextFormat = tf;
				ratingField.text = "R: " + rating;
				ratingField.width = 88;
				ratingField.x = 42;
				ratingField.autoSize = TextFieldAutoSize.LEFT;
				ratingField.y = 17 + 15 / 2 - ratingField.height / 2;
				ratingField.mouseEnabled = false;
				addChild(ratingField);
			}
			
			// don't show rank for guests
			if(level > 0) {
				var rankSprite:LevelIcon = new LevelIcon(level);
				rankSprite.x = 35 / 2 - rankSprite.width / 2;
				rankSprite.y = 4;
				addChild(rankSprite);
			}
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			detailClickSprite = new Sprite();
			detailClickSprite.graphics.beginFill(0, 0);
			detailClickSprite.graphics.drawRect(35, 0, width - 35, height);
			detailClickSprite.graphics.endFill();
			addChild(detailClickSprite);

			if(username != G.user.name && !isModerator) {
				muteButton = new Button(null, onMutePressed, G.user.isPlayerMuted(name) ? ResList.GetArtResource("mute_on") : ResList.GetArtResource("mute_off"));
				muteButton.x = -1;
				muteButton.y = 25;
				addChild(muteButton);
				
				var tooltip:TextTooltip = new TextTooltip("Mute player", muteButton);
			}
			
			// enable info popup for registered players (but not me)
			if(username != G.user.name && playerKey != "") {
				this.playerKey = playerKey;
				detailClickSprite.addEventListener(MouseEvent.CLICK, onMouseClicked);
				detailClickSprite.useHandCursor = true;
				detailClickSprite.buttonMode = true;
			}
		}
		
		private function getCorrectBg():Bitmap {
			if(isModerator) {
				return ResList.GetArtResource("lobby_chatListUserModerator_bg");
			}
			else {
				// check if is friend
				isFriend = false;
				if(!G.user.isGuest) {
					var friends:Array = G.user.playerObject.Friends;
					for each(var friend:Object in friends) {
						if(friend.a == playerKey) {
							isFriend = true;
							break;
						}
					}
				}
				if(isFriend) {
					return ResList.GetArtResource("lobby_chatListUserFriend_bg");
					//addChild(ResList.GetArtResource("lobby_chatListUser_bg"));
				}
				else if(isPremium) {
					return ResList.GetArtResource("lobby_chatListUserPremium_bg");
				}
				else {
					return ResList.GetArtResource("lobby_chatListUser_bg");
				}
			}
		}
		
		public function refreshBg():void {
			removeChildAt(0);
			addChildAt(getCorrectBg(), 0);
		}
		
		private function onRemovedFromStage(event:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			//if(bd)
			//	bd.dispose();
			
			detailClickSprite.removeEventListener(MouseEvent.CLICK, onMouseClicked);
		}
		
		private function onMouseClicked(event:MouseEvent):void {
			if(!G.user.isGuest) {
				G.errorSprite.addChild(new PlayerInfoPopup(playerKey, localToGlobal(new Point(0, 0)).x, localToGlobal(new Point(0, 0)).y + height - 2, height, this));
			}
		}
		
		private function onMutePressed(button:Button):void {
			muteButton.setImage(G.user.toggleMute(username) ? "mute_on" : "mute_off");
		}
	}
}