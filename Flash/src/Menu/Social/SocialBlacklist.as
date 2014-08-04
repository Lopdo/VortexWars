package Menu.Social
{
	import Errors.ErrorManager;
	
	import Menu.Loading;
	import Menu.MainMenu.ScrollableSprite;
	import Menu.NinePatchSprite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import playerio.Message;
	
	public class SocialBlacklist extends Sprite
	{
		private var blacklistPanel:ScrollableSprite;
		private var loading:Loading;
		
		public function SocialBlacklist()
		{
			super();
			
			//blacklistPanel = new NinePatchSprite("9patch_emboss_panel", 200, 460);
			//addChild(blacklistPanel);
			
			/*loading = new Loading("LOADING...", false);
			loading.x = friendListPanel.width / 2 - loading.width / 2;
			loading.y = friendListPanel.height / 2 - loading.height / 2;
			friendListPanel.addChild(loading);*/
			
			blacklistPanel = new ScrollableSprite(420, 464);
			addChild(blacklistPanel);
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			G.userConnection.addMessageHandler(MessageID.SOCIAL_REMOVE_FROM_BLACKLIST, onMessageReceived);
			
			fillBanlist();
			
			G.gatracker.trackPageview("/social/blacklist");
		}
		
		private function fillBanlist():void {
			blacklistPanel.removeAllItems();
			
			var offset:int = 0;
			//for(var i:int = 0; i < 10; i++) {
			for each(var blacklistObj:Object in G.user.blackList) {
				if(blacklistObj.a != null) {
					var cell:BlacklistPlayerCell = new BlacklistPlayerCell(blacklistObj.a, blacklistObj.b, blacklistObj.c, this);
					cell.y = offset;
					blacklistPanel.addSprite(cell);
					offset += (cell.height + 4);
				}
			}
			//}
		}
		
		private function onRemovedFromStage(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			G.userConnection.removeMessageHandler(MessageID.SOCIAL_REMOVE_FROM_BLACKLIST, onMessageReceived);
		}
		
		private function onMessageReceived(message:Message):void {
			if(message.type == MessageID.SOCIAL_REMOVE_FROM_BLACKLIST) {
				if(message.getBoolean(0)) {
					var playerKey:String = message.getString(1);
					for(var i:int = G.user.blackList.length - 1; i >= 0; i--) { 
						if(G.user.blackList[i].a == playerKey) {
							G.user.blackList.splice(i, 1);
						}
					}
				}
				else {
					ErrorManager.showCustomError2("Could not unban player, please try again later", "Error", 0);
				}
				
				fillBanlist();

				blacklistPanel.removeChild(loading);
				loading = null;
			}
		}
		
		public function unbanPlayer(playerKey:String):void {
			G.userConnection.send(MessageID.SOCIAL_REMOVE_FROM_BLACKLIST, playerKey);
			
			blacklistPanel.removeAllItems();
			
			loading = new Loading("LOADING...", false);
			loading.x = blacklistPanel.width / 2 - loading.width / 2;
			loading.y = blacklistPanel.height / 2 - loading.height / 2;
			blacklistPanel.addChild(loading);
		}
	}
}