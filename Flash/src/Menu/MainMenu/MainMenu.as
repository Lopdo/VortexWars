package Menu.MainMenu
{
	import IreUtils.ResList;
	
	import MapEditor.MapEditorHome;
	import MapEditor.MapEditorScreen;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.HowToPlay.HowToPlayScreen;
	import Menu.Lobby.Lobby;
	import Menu.Login.LoginScreen;
	import Menu.Login.LoginScreenAG;
	import Menu.Login.LoginScreenKong;
	import Menu.Login.RegisterScreen;
	import Menu.NinePatchSprite;
	import Menu.PlayerProfile.ProfileBadge;
	import Menu.SaleScreen;
	import Menu.Upgrades.RanksScreen;
	import Menu.Upgrades.ShopScreen;
	
	import Tutorial.TutorialGame;
	import Tutorial.WelcomeScreen;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.SharedObject;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class MainMenu extends Sprite
	{
		public function MainMenu()
		{
			super();

			graphics.beginBitmapFill(ResList.GetArtResource("bg").bitmapData);
			graphics.drawRect(0, 0, 800, 600);
			
			addChild(new ProfileBadge());
			
			var playPanel:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 288, 452);
			playPanel.x = 470;
			playPanel.y = 20;
			addChild(playPanel);
			
			var dynamicPanel:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 408, 236);
			dynamicPanel.x = 40;
			dynamicPanel.y = playPanel.y + playPanel.height - dynamicPanel.height;
			addChild(dynamicPanel);
			
			var tf:TextFormat = new TextFormat("Arial", 12, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			var versionLabel:TextField = new TextField();
			versionLabel.text = "v" + G.gameVersion;
			versionLabel.setTextFormat(tf);
			versionLabel.mouseEnabled = false;
			versionLabel.autoSize = TextFieldAutoSize.LEFT;
			versionLabel.x = 10;
			versionLabel.y = 580;
			addChild(versionLabel);
			
			tf.size = 20;
			
			var button:ButtonHex;
			
			if(!G.user.isGuest) {
				button = new ButtonHex("RANKS", onRanksPressed, "button_medium_gray", 16, -1, 170);
				button.x = dynamicPanel.width / 2 - button.width / 2;
				button.y = 15;
				dynamicPanel.addChild(button);
				
				button = new ButtonHex("NEWSLETTER", onNewsletterPressed, "button_medium_gray", 16, -1, 170);
				button.x = dynamicPanel.width / 2 - button.width / 2;
				button.y = 75;
				dynamicPanel.addChild(button);
				
				button = new ButtonHex("SHOP", onShopPressed, "button_big_gold", 24, -1, 260);
				button.x = dynamicPanel.width / 2 - button.width / 2;
				button.y = 140;
				dynamicPanel.addChild(button);
					
				var s:Sprite = new Sprite();
				s.addChild(ResList.GetArtResource("menu_shop_deco"));
				//s.x = button.x + button.width - s.width - 4;
				s.x = button.x + button.width - s.width + 22;
				s.y = button.y + 6;
				dynamicPanel.addChild(s);
				s.mouseEnabled = false;
			}
			else {
				tf.size = 24;
				tf.color = 0xFBD21E;
				
				var loginText:TextField = new TextField();
				loginText.text = "REGISTER FOR FREE!";
				loginText.setTextFormat(tf);
				loginText.width = dynamicPanel.width;
				loginText.autoSize = TextFieldAutoSize.CENTER;
				loginText.y = 14;
				loginText.mouseEnabled = false;
				dynamicPanel.addChild(loginText);
				
				tf.size = 12;
				tf.color = -1;
				
				loginText = new TextField();
				loginText.text = "GAIN EXPERIENCE AND VORTEX SHARDS\nAND UNLOCK NEW THINGS";
				loginText.width = dynamicPanel.width - 40;
				loginText.x = 20;
				loginText.multiline = true;
				loginText.wordWrap = true;
				loginText.setTextFormat(tf);
				loginText.autoSize = TextFieldAutoSize.CENTER;
				loginText.y = 46;
				loginText.mouseEnabled = false;
				dynamicPanel.addChild(loginText);
				
				button = new ButtonHex("REGISTER", onRegisterPressed, "button_medium_gold", 20, -1, 182);
				button.x = dynamicPanel.width / 2 - button.width / 2;
				button.y = 96;
				dynamicPanel.addChild(button);

				button = new ButtonHex("LOG IN", onLoginPressed, "button_medium_gold", 20, -1, 182);
				button.x = dynamicPanel.width / 2 - button.width / 2;
				button.y = 162;
				dynamicPanel.addChild(button);
			}
			
			button = new ButtonHex("PLAY ONLINE", onPlayOnlinePressed, "button_big_gold", 24, -1, 240);
			button.x = playPanel.width / 2 - button.width / 2;
			button.y = 24;
			playPanel.addChild(button);
			
			if(G.user.level >= 10) {
				button = new ButtonHex("MAP EDITOR", onMapEditorPressed, "button_big_gray", 24, -1, 240);
				button.x = playPanel.width / 2 - button.width / 2;
				button.y = 140;
				playPanel.addChild(button);
			}
			else {
				var mapEditor:NinePatchSprite = new NinePatchSprite("9patch_emboss_panel", 234, 62);
				mapEditor.x = playPanel.width / 2 - button.width / 2;
				mapEditor.y = 140;
				playPanel.addChild(mapEditor);
				
				tf.size = 24;
				tf.color = 0x5E5E5E;
				
				var label:TextField = new TextField();
				label.text = "MAP EDITOR";
				label.setTextFormat(tf);
				label.autoSize = TextFieldAutoSize.CENTER;
				label.x = mapEditor.width / 2 - label.width / 2;
				label.y = 6;
				label.mouseEnabled = false;
				mapEditor.addChild(label);
				
				tf.size = 14;
				
				label = new TextField();
				label.text = "Reach level 10 to unlock";
				label.setTextFormat(tf);
				label.autoSize = TextFieldAutoSize.CENTER;
				label.x = mapEditor.width / 2 - label.width / 2;
				label.y = 38;
				label.mouseEnabled = false;
				mapEditor.addChild(label);
			}
			
			button = new ButtonHex("HOW TO PLAY", onHowToPlayPressed, "button_big_gray", 24, -1, 240);
			button.x = playPanel.width / 2 - button.width / 2;
			button.y = 250;
			playPanel.addChild(button);
			
			button = new ButtonHex("CREDITS", onCreditsPressed, "button_big_gray", 24, -1, 240);
			button.x = playPanel.width / 2 - button.width / 2;
			button.y = 360;
			playPanel.addChild(button);
			
			addChild(new MenuShortcutsPanel(null));
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			/*var so:SharedObject = SharedObject.getLocal("prefs");
			if(!so.data.hasOwnProperty("tutorialDisplayed") && (!G.user.isGuest && !G.user.playerObject.hasOwnProperty("TutorialFinished"))) {
				G.errorSprite.addChild(new WelcomeScreen(this));
				so.data.tutorialDisplayed = true;
				so.flush();
				
			}*/
			
			/*var so:SharedObject = SharedObject.getLocal("prefs");
			if(!so.data.hasOwnProperty("saleDisplayed")) {
				G.errorSprite.addChild(new SaleScreen());
				so.data.saleDisplayed = true;
				so.flush();
			}*/
			
			//new AchievementWindow(101, "test", 100, 100);
			
			G.gatracker.trackPageview("/mainMenu");
		}
		
		private function onAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			if(G.invitedTo != null) {
				onPlayOnlinePressed();
			}
		}
		
		private function onNewsletterPressed():void {
			parent.addChild(new NewsletterScreen());
			parent.removeChild(this);
		}
		
		private function onRegisterPressed():void {
			if(G.userConnection) {
				G.userConnection.disconnect();
				G.userConnection = null;
			}
			
			if(G.host == G.HOST_ARMORGAMES) {
				parent.addChild(new LoginScreenAG());
				parent.removeChild(this);
			}
			else if(G.host == G.HOST_KONGREGATE) {
				G.kongregate.services.showSignInBox();
			}
			else {
				parent.addChild(new RegisterScreen());
				parent.removeChild(this);
			}
			
		}
		
		private function onLoginPressed():void {
			if(G.userConnection) {
				G.userConnection.disconnect();
				G.userConnection = null;
			}
			
			parent.parent.addChild(G.getLoginScreen());
			parent.removeChild(this);
		}
		
		private function onRanksPressed():void {
			parent.addChild(new RanksScreen());
			parent.removeChild(this);
		}
		
		private function onLBPressed():void {
			parent.addChild(new LeaderboardsScreen());
		}
		
		private function onCreditsPressed():void {
			parent.addChild(new CreditsScreen());
		}
		
		private function onShopPressed():void {
			parent.addChild(new ShopScreen());
			parent.removeChild(this);
		}
		
		private function onPlayOnlinePressed():void {
			parent.addChild(new Lobby());
			parent.removeChild(this);
		}
		
		private function onHowToPlayPressed():void {
			parent.addChild(new HowToPlayScreen());
			parent.removeChild(this);
		}
		
		private function onMapEditorPressed():void {
			parent.addChild(new MapEditorHome());
			parent.removeChild(this);
		}
	}
}