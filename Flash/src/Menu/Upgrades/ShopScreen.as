package Menu.Upgrades
{
	import Errors.ErrorManager;
	
	import Game.Backgrounds.BackgoundPreview;
	import Game.Backgrounds.Background;
	import Game.Races.Race;
	
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.ConfirmationDialog;
	import Menu.Loading;
	import Menu.MainMenu.MainMenu;
	import Menu.MainMenu.MenuShortcutsPanel;
	import Menu.NinePatchSprite;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.globalization.DateTimeFormatter;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import playerio.DatabaseObject;
	import playerio.Message;
	import playerio.PlayerIOError;
	
	public class ShopScreen extends Sprite
	{
		private var buttonPremium:ButtonHex;
		private var buttonRaces:ButtonHex;
		private var buttonMaps:ButtonHex;
		private var buttonBackgrounds:ButtonHex;
		private var buttonUpgrades:ButtonHex;
		private var buttonBoosts:ButtonHex;
		private var buttonEditor:ButtonHex;
		
		private var balanceCoinsIcon:Bitmap;
		private var balanceCoinsLabel:TextField;
		private var balanceShardsIcon:Bitmap;
		private var balanceShardsLabel:TextField;
		
		private var shopContent:Sprite;
		private var shopContentType:int;
		
		private var payvaultKeys:Array = new Array( "ArmyStorageUpg1", "ArmyStorageUpg2", "ArmyStorageUpg3", "ArmyStorageUpg4", 
													"MapPack_0", "MapPack_1", "MapPack_2", "MapPack_3",
													"Premium3Months", "PremiumLifetime", "PremiumMonth", "PremiumWeek", 
													"RaceSoldiers", "RaceRobots", "RaceElementals", "RacePirates", "RaceNinjas", "RaceAngels", "RaceDemons", "RaceInsectoids", "RaceVampires", "RacePumpkins", "RaceDragons", "RaceReptiles", "RaceArachnids", "RaceSantas", "RaceReindeers", "RaceSnowmen","RaceNatives","RaceUndead","RaceTerminators","RaceBladeMasters","RaceCyborgs","RaceDarkKnights","RaceTeddyBears","RaceWerewolves","RaceFrankensteins","RaceTannenbaums","RaceSnowflakes",
													"MapBackground1", "MapBackground2", "MapBackground3", "MapBackground4", "MapBackground5", "MapBackground6", "MapBackground7", "MapBackground9", "MapBackground10", "MapBackground11", "MapBackground12", "MapBackground13", "MapBackground14",
													"AttackBoostPack10", "AttackBoostPack50", "AttackBoostPack200", "AttackBoostPack1000", 
													"DefenseBoostPack10", "DefenseBoostPack50", "DefenseBoostPack200", "DefenseBoostPack1000",
													"EditorDeluxe", "EditorSlot");
		
		private var shopItems:Array = null;
		
		private var currentMap:int = 2;
		private const MAP_COUNT:int = 3;
		
		private var currentRace:int = 18;
		private const RACE_COUNT:int = 27;

		private var currentBg:int = 0;
		//private var BG_COUNT:int = 7;
		private var availableBackgrounds:Array = new Array();
		
		private var loading:Loading;
		
		public function ShopScreen(activeTab:int = 0)
		{
			super();
			
			graphics.beginBitmapFill(ResList.GetArtResource("bg").bitmapData);
			graphics.drawRect(0, 0, 800, 600);
			
			var tabbar:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 224, 514);
			tabbar.x = 6;
			tabbar.y = 18;
			addChild(tabbar);
			
			buttonPremium = new ButtonHex("PREMIUM ACCOUNT", showPremiumContent, "button_medium_gold", 16, -1, 210);
			buttonPremium.x = tabbar.width / 2 - buttonPremium.width / 2 + 2;
			buttonPremium.y = 10;
			tabbar.addChild(buttonPremium);
			
			buttonRaces = new ButtonHex("RACES", showRacesContent, "button_medium_gray", 16, -1, 210);
			buttonRaces.x = tabbar.width / 2 - buttonRaces.width / 2 + 2;
			buttonRaces.y = 70;
			tabbar.addChild(buttonRaces);
			
			/*var s:Sprite = new Sprite();
			s.addChild(ResList.GetArtResource("shop_splash_new"));
			s.scaleX = 0.6;
			s.scaleY = 0.6;
			s.x = buttonRaces.x + buttonRaces.width - s.width + 5;
			s.y = buttonRaces.y + buttonRaces.height / 2 - s.height / 2 - 5;
			s.mouseEnabled = false;
			tabbar.addChild(s);*/
			
			buttonMaps = new ButtonHex("MAP PACKS", showMapsContent, "button_medium_gray", 16, -1, 210);
			buttonMaps.x = tabbar.width / 2 - buttonMaps.width / 2 + 2;
			buttonMaps.y = 130;
			tabbar.addChild(buttonMaps);
			
			buttonBackgrounds = new ButtonHex("BACKGROUNDS", showBackgroundsContent, "button_medium_gray", 16, -1, 210);
			buttonBackgrounds.x = tabbar.width / 2 - buttonBackgrounds.width / 2 + 2;
			buttonBackgrounds.y = 190;
			tabbar.addChild(buttonBackgrounds);
			
			/*s = new Sprite();
			s.addChild(ResList.GetArtResource("shop_splash_new"));
			s.scaleX = 0.6;
			s.scaleY = 0.6;
			s.x = buttonBackgrounds.x + buttonBackgrounds.width - s.width + 5;
			s.y = buttonBackgrounds.y + buttonBackgrounds.height / 2 - s.height / 2 - 5;
			s.mouseEnabled = false;
			tabbar.addChild(s);*/
			
			buttonUpgrades = new ButtonHex("UPGRADES", showUpgradesContent, "button_medium_gray", 16, -1, 210);
			buttonUpgrades.x = tabbar.width / 2 - buttonUpgrades.width / 2 + 2;
			buttonUpgrades.y = 250;
			tabbar.addChild(buttonUpgrades);
			
			buttonBoosts = new ButtonHex("BOOSTS", showBoostsContent, "button_medium_gray", 16, -1, 210);
			buttonBoosts.x = tabbar.width / 2 - buttonBoosts.width / 2 + 2;
			buttonBoosts.y = 310;
			tabbar.addChild(buttonBoosts);
			
			buttonEditor = new ButtonHex("MAP EDITOR", showEditorContent, "button_medium_gray", 16, -1, 210);
			buttonEditor.x = tabbar.width / 2 - buttonEditor.width / 2 + 2;
			buttonEditor.y = 370;
			tabbar.addChild(buttonEditor);
			//buttonEditor.visible = G.localServer;
			
			var contentPanel:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 560, 514);
			contentPanel.x = 236;
			contentPanel.y = 18;
			addChild(contentPanel);
			
			var emboss:NinePatchSprite = new NinePatchSprite("9patch_emboss_panel", 492, 80);
			emboss.x = contentPanel.width / 2 - emboss.width / 2;
			emboss.y = 414;
			contentPanel.addChild(emboss);
			
			var balanceTF:TextFormat = new TextFormat("Arial", 20, -1, true);
			balanceTF.align = TextFormatAlign.CENTER;
			
			var balanceLabel:TextField = new TextField();
			balanceLabel.text = "BALANCE:";
			balanceLabel.setTextFormat(balanceTF);
			balanceLabel.x = 20;
			balanceLabel.autoSize = TextFieldAutoSize.CENTER;
			balanceLabel.y = emboss.height / 2 - balanceLabel.height / 2;
			balanceLabel.mouseEnabled = false;
			emboss.addChild(balanceLabel);
			
			balanceCoinsLabel = new TextField();
			balanceCoinsLabel.defaultTextFormat = balanceTF;
			balanceCoinsLabel.text = "---";
			balanceCoinsLabel.x = 128;
			balanceCoinsLabel.autoSize = TextFieldAutoSize.LEFT;
			balanceCoinsLabel.y = 10;
			balanceCoinsLabel.mouseEnabled = false;
			emboss.addChild(balanceCoinsLabel);
			
			balanceCoinsIcon = ResList.GetArtResource("shop_coin");
			balanceCoinsIcon.x = balanceCoinsLabel.x + balanceCoinsLabel.width;
			balanceCoinsIcon.y = balanceCoinsLabel.y + balanceCoinsLabel.height / 2 - balanceCoinsIcon.height / 2;
			emboss.addChild(balanceCoinsIcon);
			
			balanceShardsLabel = new TextField();
			balanceShardsLabel.defaultTextFormat = balanceTF;
			balanceShardsLabel.text = "---";
			balanceShardsLabel.x = 128;
			balanceShardsLabel.autoSize = TextFieldAutoSize.LEFT;
			balanceShardsLabel.y = 44;
			balanceShardsLabel.mouseEnabled = false;
			emboss.addChild(balanceShardsLabel);
			
			balanceShardsIcon = ResList.GetArtResource("shop_shard");
			balanceShardsIcon.x = balanceShardsLabel.x + balanceShardsLabel.width;
			balanceShardsIcon.y = balanceShardsLabel.y + balanceShardsLabel.height / 2 - balanceShardsIcon.height / 2;
			emboss.addChild(balanceShardsIcon);
			
			var moreCoinsButton:ButtonHex = new ButtonHex("ADD MORE COINS", onMoreCoinsClicked, "button_big_gold", 20);
			moreCoinsButton.x = 236;
			moreCoinsButton.y = emboss.height / 2 - moreCoinsButton.height / 2;
			emboss.addChild(moreCoinsButton);
			
			shopContent = new Sprite();
			contentPanel.addChild(shopContent);
			
			addChild(new MenuShortcutsPanel(onBack));
			
			//updateShop();
			refresh();
			
			G.userConnection.addMessageHandler(MessageID.ITEM_BOUGHT, messageReceived);
			G.userConnection.addMessageHandler(MessageID.ITEM_BUY_FAILED, messageReceived);
			
			availableBackgrounds.push(Background.BACKGROUND_DESERT);
			availableBackgrounds.push(Background.BACKGROUND_NIGHT_SKY);
			availableBackgrounds.push(Background.BACKGROUND_RED_SKIES);
			availableBackgrounds.push(Background.BACKGROUND_ICE);
			availableBackgrounds.push(Background.BACKGROUND_ALIEN_HOMEWORLD);
			availableBackgrounds.push(Background.BACKGROUND_STEEL);
			availableBackgrounds.push(Background.BACKGROUND_MOON);
			availableBackgrounds.push(Background.BACKGROUND_CRACKED_ICE);
			availableBackgrounds.push(Background.BACKGROUND_TUNDRA);
			availableBackgrounds.push(Background.BACKGROUND_FROZEN_LAKE);
			availableBackgrounds.push(Background.BACKGROUND_FOREST);
			// halloween
			availableBackgrounds.push(Background.BACKGROUND_PUMPKIN);
			availableBackgrounds.push(Background.BACKGROUND_BLOOD);
			
			currentBg = 9;
			
			shopContentType = activeTab;
			updateContent();
			
			G.gatracker.trackPageview("/shop");
		}
		
		////////////////////////
		//// PREMIUM
		///////////////////////
		protected function showPremiumContent():void {
			shopContentType = 0;
			
			buttonPremium.setImage("button_medium_gold");
			buttonRaces.setImage("button_medium_gray");
			buttonMaps.setImage("button_medium_gray");
			buttonBackgrounds.setImage("button_medium_gray");
			buttonUpgrades.setImage("button_medium_gray");
			buttonBoosts.setImage("button_medium_gray");
			buttonEditor.setImage("button_medium_gray");
			
			while(shopContent.numChildren > 0) shopContent.removeChildAt(shopContent.numChildren - 1);
			
			if(shopItems == null) return;
			
			var tf:TextFormat = new TextFormat("Arial", 24, -1, true);
			
			var title:TextField = new TextField();
			title.text = "PREMIUM ACCOUNT";
			title.setTextFormat(tf);
			title.width = shopContent.parent.width;
			title.y = 10;
			title.autoSize = TextFieldAutoSize.CENTER;
			title.mouseEnabled = false;
			shopContent.addChild(title);
			
			if(G.user.isPremium()) {
				tf.size = 12;
				tf.color = 0x808080;
				
				var premiumUntil:TextField = new TextField();
				if((G.user.premiumUntil.getTime() - (new Date()).time) > 1000 * 60 * 60 * 24 * 365 * 10) {
					premiumUntil.text = "VALID UNTIL: FOREVER";
				}
				else {
					var dateFormatter:DateTimeFormatter = new DateTimeFormatter("d.M Y");
					premiumUntil.text = "VALID UNTIL: " + dateFormatter.format(G.user.premiumUntil);
				}
				premiumUntil.setTextFormat(tf);
				premiumUntil.width = shopContent.parent.width;
				premiumUntil.y = 42;
				premiumUntil.autoSize = TextFieldAutoSize.CENTER;
				premiumUntil.mouseEnabled = false;
				shopContent.addChild(premiumUntil);
			}
			
			tf.size = 14;
			tf.color = -1;
			
			var bonuses:TextField = new TextField();
			bonuses.text = "- UNIQUE RACE  - UNIQUE BACKGROUND  - DOUBLE XP REWARDS";
			bonuses.setTextFormat(tf);
			bonuses.width = shopContent.parent.width;
			bonuses.y = 70;
			bonuses.autoSize = TextFieldAutoSize.CENTER;
			bonuses.mouseEnabled = false;
			shopContent.addChild(bonuses);
			
			if(G.client.payVault.has("PremiumLifetime")) {
				tf.size = 20;
				tf.align = TextFormatAlign.CENTER;
				
				var premiumLifetimeLabel:TextField = new TextField();
				premiumLifetimeLabel.text = "YOU ALREADY HAVE LIFETIME SUBSCRIPTION FOR PREMIUM ACCOUNT. THANKS FOR YOUR SUPPORT!";
				premiumLifetimeLabel.setTextFormat(tf);
				premiumLifetimeLabel.x = 100;
				premiumLifetimeLabel.width = shopContent.parent.width - 200;
				premiumLifetimeLabel.y = 200;
				premiumLifetimeLabel.multiline = true;
				premiumLifetimeLabel.wordWrap = true;
				premiumLifetimeLabel.autoSize = TextFieldAutoSize.CENTER;
				shopContent.addChild(premiumLifetimeLabel);
				
				return;
			}

			for(var i:int = 0; i < 4; ++i) {
				var divider:Sprite = new Sprite();
				divider.addChild(ResList.GetArtResource("menu_divider_horizontal"));
				divider.width = 520;
				divider.y = 108 + i*71;
				divider.x = shopContent.parent.width / 2 - divider.width / 2;
				shopContent.addChild(divider);
				
				tf.size = 28;
				
				var label:TextField = new TextField();
				
				switch(i) {
					case 0: label.text = "1 WEEK"; break;
					case 1: label.text = "1 MONTH"; break;
					case 2: label.text = "3 MONTHS"; break;
					case 3: label.text = "LIFETIME"; break;
				}
				label.setTextFormat(tf);
				label.x = 48;
				label.autoSize = TextFieldAutoSize.LEFT;
				label.y = 108 + i * 71 + 35 - label.height / 2;
				label.mouseEnabled = false;
				shopContent.addChild(label);
				
				tf.size = 14;
				
				var vaultItem:DatabaseObject;
				if(shopItems != null) {
					switch(i) {
						case 0: vaultItem = shopItems["PremiumWeek"]; break;
						case 1: vaultItem = shopItems["PremiumMonth"]; break;
						case 2: vaultItem = shopItems["Premium3Months"]; break;
						case 3: vaultItem = shopItems["PremiumLifetime"]; break;
					}
				}
				
				label = new TextField();
				label.text = "" + vaultItem.PriceCoins; 
				label.setTextFormat(tf);
				label.x = 210;
				label.width = 68;
				label.autoSize = TextFieldAutoSize.RIGHT;
				label.y = 108 + i * 71 + 35 - label.height / 2;
				shopContent.addChild(label);
				
				var icon:Sprite = new Sprite();
				icon.addChild(ResList.GetArtResource("shop_coin"));
				icon.x = 278;
				icon.y = 108 + i * 71 + 35 - icon.height / 2;
				shopContent.addChild(icon);
				
				var button:ButtonHex;
				
				if(shopItems != null) {
					switch(i) {
						case 0: button = new ButtonHex("BUY", function():void {buyItem("PremiumWeek");}, "button_small_gold"); break;
						case 1: button = new ButtonHex("BUY", function():void {buyItem("PremiumMonth");}, "button_small_gold"); break;
						case 2: button = new ButtonHex("BUY", function():void {buyItem("Premium3Months");}, "button_small_gold"); break;
						case 3: button = new ButtonHex("BUY", function():void {buyItem("PremiumLifetime");}, "button_small_gold"); break;
					}
				}
				button.x = 306;
				button.y = 108 + i * 71 + 35 - button.height / 2;
				shopContent.addChild(button);
				
				if(vaultItem.PriceShards > 0) {
					label = new TextField();
					label.text = "" + vaultItem.PriceShards; 
					label.setTextFormat(tf);
					label.x = 382;
					label.width = 58;
					label.autoSize = TextFieldAutoSize.RIGHT;
					label.y = 108 + i * 71 + 35 - label.height / 2;
					shopContent.addChild(label);
					
					icon = new Sprite();
					icon.addChild(ResList.GetArtResource("shop_shard"));
					icon.x = 442;
					icon.y = 108 + i * 71 + 35 - icon.height / 2;
					shopContent.addChild(icon);
					
					if(shopItems != null) {
						switch(i) {
							case 0: button = new ButtonHex("BUY", function():void {buyItemShards("PremiumWeek");}, "button_small_gray"); break;
							case 1: button = new ButtonHex("BUY", function():void {buyItemShards("PremiumMonth");}, "button_small_gray"); break;
							case 2: button = new ButtonHex("BUY", function():void {buyItemShards("Premium3Months");}, "button_small_gray"); break;
							case 3: button = new ButtonHex("BUY", function():void {buyItemShards("PremiumLifetime");}, "button_small_gray"); break;
						}
					}
					button.x = 470;
					button.y = 108 + i * 71 + 35 - button.height / 2;
					shopContent.addChild(button);
				}
			}
			
			divider = new Sprite();
			divider.addChild(ResList.GetArtResource("menu_divider_horizontal"));
			divider.width = 520;
			divider.y = 108 + 4*71;
			divider.x = shopContent.parent.width / 2 - divider.width / 2;
			shopContent.addChild(divider);
			
			G.gatracker.trackPageview("/shop/premium");
		}
		
		///////////////////////
		//// RACES
		////////////////////
		protected function showRacesContent():void {
			shopContentType = 1;
			
			buttonPremium.setImage("button_medium_gray");
			buttonRaces.setImage("button_medium_gold");
			buttonMaps.setImage("button_medium_gray");
			buttonBackgrounds.setImage("button_medium_gray");
			buttonUpgrades.setImage("button_medium_gray");
			buttonBoosts.setImage("button_medium_gray");
			buttonEditor.setImage("button_medium_gray");
			
			while(shopContent.numChildren > 0) shopContent.removeChildAt(shopContent.numChildren - 1);
			
			if(shopItems == null) return;
			
			var tf:TextFormat = new TextFormat("Arial", 24, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			var label:TextField = new TextField();
			label.text = "RACES";
			label.setTextFormat(tf);
			label.width = shopContent.parent.width;
			label.y = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.mouseEnabled = false;
			shopContent.addChild(label);
			
			var race:Race;
			switch(currentRace) {
				case 0:
					race = Race.Create(Race.RACE_SOLDIERS);
					break;
				case 1:
					race = Race.Create(Race.RACE_ROBOTS);
					break;
				case 2:
					race = Race.Create(Race.RACE_ELEMENTALS);
					break;
				case 3:
					race = Race.Create(Race.RACE_PIRATES);
					break;
				case 4:
					race = Race.Create(Race.RACE_NINJAS);
					break;
				case 5:
					race = Race.Create(Race.RACE_ANGELS);
					break;
				case 6:
					race = Race.Create(Race.RACE_DEMONS);
					break;
				case 7:
					race = Race.Create(Race.RACE_INSECTOIDS);
					break;
				case 8:
					race = Race.Create(Race.RACE_ARACHNIDS);
					break;
				case 9:
					race = Race.Create(Race.RACE_REPTILES);
					break;
				case 10:
					race = Race.Create(Race.RACE_DRAGONS);
					break;
				case 11:
					race = Race.Create(Race.RACE_NATIVES);
					break;
				case 12:
					race = Race.Create(Race.RACE_UNDEAD);
					break;
				case 13:
					race = Race.Create(Race.RACE_TERMINATORS);
					break;
				case 14:
					race = Race.Create(Race.RACE_BLADE_MASTERS);
					break;
				case 15:
					race = Race.Create(Race.RACE_DARK_KNIGHTS);
					break;
				case 16:
					race = Race.Create(Race.RACE_CYBORGS);
					break;
				case 17:
					race = Race.Create(Race.RACE_TEDDY_BEARS);
					break;
				case 18:
					race = Race.Create(Race.RACE_WEREWOLVES);
					break;
				case 19:
					race = Race.Create(Race.RACE_FRANKENSTEINS);
					break;
				case 20:
					race = Race.Create(Race.RACE_PUMPKINS);
					break;
				case 21:
					race = Race.Create(Race.RACE_VAMPIRES);
					break;
				case 22:
					race = Race.Create(Race.RACE_SANTAS);
					break;
				case 23:
					race = Race.Create(Race.RACE_REINDEERS);
					break;
				case 24:
					race = Race.Create(Race.RACE_SNOWMEN);
					break;
				case 25:
					race = Race.Create(Race.RACE_SNOWFLAKES);
					break;
				case 26:
					race = Race.Create(Race.RACE_TANNENBAUMS);
					break;
			}
			var shopItem:DatabaseObject = shopItems[race.shopName];
			var raceBought:Boolean = G.client.payVault.has(race.shopName);

			var imgBg:NinePatchSprite = new NinePatchSprite("9patch_emboss_panel", 188, 188);
			imgBg.x = shopContent.parent.width / 2 - imgBg.width / 2;
			imgBg.y = 44;
			shopContent.addChild(imgBg);
			
			var raceImage:Sprite = new Sprite();
			raceImage.addChild(race.profileImage);
			raceImage.y = 4;
			raceImage.x = 4;
			imgBg.addChild(raceImage);
			
			var button:Button = new Button(null, onPrevRace, ResList.GetArtResource("selector_arrow_big"));
			button.x = 100;
			button.y = imgBg.y + imgBg.height / 2 - button.height / 2;
			shopContent.addChild(button);
			
			button = new Button(null, onNextRace, ResList.GetArtResource("selector_arrow_big"));
			button.scaleX = -1;
			button.x = shopContent.parent.width - 100;
			button.y = imgBg.y + imgBg.height / 2 - button.height / 2;
			shopContent.addChild(button);
			
			label = new TextField();
			label.text = race.name;
			label.setTextFormat(tf);
			label.width = shopContent.parent.width;
			label.y = 236;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.mouseEnabled = false;
			shopContent.addChild(label);
			
			tf.color = 0xA0A0A0;
			tf.size = 16;
				
			label = new TextField();
			label.text = race.description;
			label.setTextFormat(tf);
			label.width = shopContent.parent.width - 60;
			label.x = 30;
			label.y = 270;
			label.multiline = true;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.mouseEnabled = false;
			shopContent.addChild(label);
			
			tf.size = 14;
			tf.color = 0xFF5030;
			tf.bold = false;
			
			/*if(currentRace >= 18) {
				label = new TextField();
				label.text = "Will be removed from shop shortly after Halloween 2012";
				label.setTextFormat(tf);
				label.width = shopContent.parent.width - 100;
				label.x = 50;
				label.y = 346;
				label.autoSize = TextFieldAutoSize.CENTER;
				label.mouseEnabled = false;
				shopContent.addChild(label);
			
				var s:Sprite = new Sprite();
				s.addChild(ResList.GetArtResource("shop_splash_new"));
				s.x = imgBg.x + imgBg.width - s.width / 2;
				s.y = imgBg.y - s.height / 2;
				shopContent.addChild(s);
			}*/
			
			tf.bold = true;
			tf.size = 16;
			tf.color = -1;

			if(raceBought) {
				label = new TextField();
				label.text = "You already own this race";
				label.setTextFormat(tf);
				label.width = shopContent.parent.width;
				label.y = 376;
				label.autoSize = TextFieldAutoSize.CENTER;
				label.mouseEnabled = false;
				shopContent.addChild(label);
			}
			else {
				var buttonWrap:Sprite = new Sprite;
				
				label = new TextField();
				label.text = "" + shopItem.PriceCoins; 
				label.setTextFormat(tf);
				label.width = 68;
				label.autoSize = TextFieldAutoSize.LEFT;
				label.y = 50 - label.height / 2;
				buttonWrap.addChild(label);
				
				var icon:Sprite = new Sprite();
				icon.addChild(ResList.GetArtResource("shop_coin"));
				icon.x = label.width + 5;
				icon.y = 50 - icon.height / 2;
				buttonWrap.addChild(icon);
				
				var buttonHex:ButtonHex = new ButtonHex("BUY", function():void {buyItem(race.shopName);}, "button_small_gold"); 
				buttonHex.x = icon.x + icon.width + 10;
				buttonHex.y = 50 - buttonHex.height / 2;
				buttonWrap.addChild(buttonHex);
				
				if(shopItem.PriceShards > 0) {
					label = new TextField();
					label.text = "" + shopItem.PriceShards; 
					label.setTextFormat(tf);
					label.x = buttonHex.x + buttonHex.width + 20;
					label.width = 58;
					label.autoSize = TextFieldAutoSize.RIGHT;
					label.y = 50 - label.height / 2;
					buttonWrap.addChild(label);
					
					icon = new Sprite();
					icon.addChild(ResList.GetArtResource("shop_shard"));
					icon.x = label.x + label.width + 5;
					icon.y = 50 - icon.height / 2;
					buttonWrap.addChild(icon);
					
					buttonHex = new ButtonHex("BUY", function():void {buyItemShards(race.shopName);}, "button_small_gray"); 
					buttonHex.x = icon.x + icon.width + 10;
					buttonHex.y = 50 - buttonHex.height / 2;
					buttonWrap.addChild(buttonHex);
				}
				
				buttonWrap.x = shopContent.parent.width / 2 - buttonWrap.width / 2;
				buttonWrap.y = 336;
				shopContent.addChild(buttonWrap);
			}
			
			G.gatracker.trackPageview("/shop/races/" + currentRace);
		}
		
		////////////////////
		//// MAPS
		///////////////////
		protected function showMapsContent():void {
			shopContentType = 2;
			
			buttonPremium.setImage("button_medium_gray");
			buttonRaces.setImage("button_medium_gray");
			buttonMaps.setImage("button_medium_gold");
			buttonBackgrounds.setImage("button_medium_gray");
			buttonUpgrades.setImage("button_medium_gray");
			buttonBoosts.setImage("button_medium_gray");
			buttonEditor.setImage("button_medium_gray");
			
			while(shopContent.numChildren > 0) shopContent.removeChildAt(shopContent.numChildren - 1);
			
			if(shopItems == null) return;
			
			var tf:TextFormat = new TextFormat("Arial", 24, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			var label:TextField = new TextField();
			label.text = "MAP PACKS";
			label.setTextFormat(tf);
			label.width = shopContent.parent.width;
			label.y = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.mouseEnabled = false;
			shopContent.addChild(label);
			
			var mapName:String;
			var packIndex:int;
			
			switch(currentMap) {
				case 0:	mapName = "World"; packIndex = 0; break;
				case 1: mapName = "Symmetries"; packIndex = 1; break;
				case 2: mapName = "Races"; packIndex = 2; break;
			}

			var mapBought:Boolean = G.client.payVault.has("MapPack_" + packIndex); 
			var shopItem:DatabaseObject = shopItems["MapPack_" + packIndex];
			
			var mapsWrap:Sprite = new Sprite();
			for(var i:int = 0; i < 4; ++i) {
				var mapImage:Sprite = new Sprite();
				mapImage.addChild(ResList.GetArtResource("mapPreview_" + packIndex + "_" + i));
				mapImage.x = (i % 2) * 130;
				mapImage.y = int(i / 2) * 130;
				mapsWrap.addChild(mapImage);
			}
			
			mapsWrap.y = 50;
			mapsWrap.x = shopContent.parent.width / 2 - mapsWrap.width / 2;
			shopContent.addChild(mapsWrap);
			
			var button:Button = new Button(null, onPrevMap, ResList.GetArtResource("selector_arrow_big"));
			button.x = 60;
			button.y = mapsWrap.y + mapsWrap.height / 2 - button.height / 2;
			shopContent.addChild(button);
			
			button = new Button(null, onNextMap, ResList.GetArtResource("selector_arrow_big"));
			button.scaleX = -1;
			button.x = shopContent.parent.width - 60;
			button.y = mapsWrap.y + mapsWrap.height / 2 - button.height / 2;
			shopContent.addChild(button);
			
			label = new TextField();
			label.text = mapName;
			label.setTextFormat(tf);
			label.width = shopContent.parent.width;
			label.y = 290;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.mouseEnabled = false;
			shopContent.addChild(label);
			
			tf.size = 14;
			tf.color = 0xFF5030;
			tf.bold = false;
			
			/*if(currentMap == 2) {
				label = new TextField();
				label.text = "Will be removed from shop shortly after Halloween 2011";
				label.setTextFormat(tf);
				label.width = shopContent.parent.width - 100;
				label.x = 50;
				label.y = 322;
				label.autoSize = TextFieldAutoSize.CENTER;
				label.mouseEnabled = false;
				shopContent.addChild(label);
			}*/
			tf.color = -1;
			tf.bold = true;
			tf.size = 16;
			
			if(mapBought) {
				label = new TextField();
				label.text = "You already own this map pack";
				label.setTextFormat(tf);
				label.width = shopContent.parent.width;
				label.y = 360;
				label.autoSize = TextFieldAutoSize.CENTER;
				label.mouseEnabled = false;
				shopContent.addChild(label);
			}
			else {
				var buttonWrap:Sprite = new Sprite;
				
				label = new TextField();
				label.text = "" + shopItem.PriceCoins; 
				label.setTextFormat(tf);
				label.width = 68;
				label.autoSize = TextFieldAutoSize.LEFT;
				label.y = 50 - label.height / 2;
				buttonWrap.addChild(label);
				
				var icon:Sprite = new Sprite();
				icon.addChild(ResList.GetArtResource("shop_coin"));
				icon.x = label.width + 5;
				icon.y = 50 - icon.height / 2;
				buttonWrap.addChild(icon);
				
				var buttonHex:ButtonHex = new ButtonHex("BUY", function():void {buyItem("MapPack_" + packIndex);}, "button_small_gold"); 
				buttonHex.x = icon.x + icon.width + 10;
				buttonHex.y = 50 - buttonHex.height / 2;
				buttonWrap.addChild(buttonHex);
				
				if(shopItem.PriceShards > 0) {
					label = new TextField();
					label.text = "" + shopItem.PriceShards; 
					label.setTextFormat(tf);
					label.x = buttonHex.x + buttonHex.width + 20;
					label.width = 58;
					label.autoSize = TextFieldAutoSize.RIGHT;
					label.y = 50 - label.height / 2;
					buttonWrap.addChild(label);
					
					icon = new Sprite();
					icon.addChild(ResList.GetArtResource("shop_shard"));
					icon.x = label.x + label.width + 5;
					icon.y = 50 - icon.height / 2;
					buttonWrap.addChild(icon);
					
					buttonHex = new ButtonHex("BUY", function():void {buyItemShards("MapPack_" + packIndex);}, "button_small_gray"); 
					buttonHex.x = icon.x + icon.width + 10;
					buttonHex.y = 50 - buttonHex.height / 2;
					buttonWrap.addChild(buttonHex);
				}
				
				buttonWrap.x = shopContent.parent.width / 2 - buttonWrap.width / 2;
				buttonWrap.y = 320;
				shopContent.addChild(buttonWrap);
			}
			
			G.gatracker.trackPageview("/shop/maps/" + currentMap);
		}
		
		/////////////////////
		//// BACKGROUNDS
		/////////////////////
		protected function showBackgroundsContent():void {
			shopContentType = 3;
			
			buttonPremium.setImage("button_medium_gray");
			buttonRaces.setImage("button_medium_gray");
			buttonMaps.setImage("button_medium_gray");
			buttonBackgrounds.setImage("button_medium_gold");
			buttonUpgrades.setImage("button_medium_gray");
			buttonBoosts.setImage("button_medium_gray");
			buttonEditor.setImage("button_medium_gray");
			
			while(shopContent.numChildren > 0) shopContent.removeChildAt(shopContent.numChildren - 1);
			
			if(shopItems == null) return;
			
			var tf:TextFormat = new TextFormat("Arial", 24, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			var label:TextField = new TextField();
			label.text = "BACKGROUNDS";
			label.setTextFormat(tf);
			label.width = shopContent.parent.width;
			label.y = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.mouseEnabled = false;
			shopContent.addChild(label);
			
			var currentBgIndex:int = availableBackgrounds[currentBg];
			
			var shopItem:DatabaseObject = shopItems["MapBackground" + currentBgIndex];
			var bgBought:Boolean = G.client.payVault.has("MapBackground" + currentBgIndex);
			
			var bgImage:Background = new Background(currentBgIndex, 150, 150);
			bgImage.y = 60;
			bgImage.x = shopContent.parent.width / 2 - bgImage.width / 2;
			shopContent.addChild(bgImage);
			
			var button:Button = new Button(null, onPrevBg, ResList.GetArtResource("selector_arrow_big"));
			button.x = 100;
			button.y = bgImage.y + bgImage.height / 2 - button.height / 2;
			shopContent.addChild(button);
			
			button = new Button(null, onNextBg, ResList.GetArtResource("selector_arrow_big"));
			button.scaleX = -1;
			button.x = shopContent.parent.width - 100;
			button.y = bgImage.y + bgImage.height / 2 - button.height / 2;
			shopContent.addChild(button);
			
			label = new TextField();
			label.text = Background.getName(currentBgIndex);
			label.setTextFormat(tf);
			label.width = shopContent.parent.width;
			label.y = 234;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.mouseEnabled = false;
			shopContent.addChild(label);
			
			var previewButton:ButtonHex = new ButtonHex("PREVIEW", onPreview, "button_small_gold");
			previewButton.x = shopContent.parent.width / 2 - previewButton.width / 2;
			previewButton.y = 276;
			shopContent.addChild(previewButton);
			
			tf.size = 14;
			tf.color = 0xFF5030;
			tf.bold = false;
			
			if(currentBgIndex == Background.BACKGROUND_BLOOD || currentBgIndex == Background.BACKGROUND_PUMPKIN) {
				label = new TextField();
				label.text = "Will be removed from shop shortly after Halloween 2012";
				label.setTextFormat(tf);
				label.width = shopContent.parent.width - 100;
				label.x = 50;
				label.y = 322;
				label.autoSize = TextFieldAutoSize.CENTER;
				label.mouseEnabled = false;
				shopContent.addChild(label);
			
				var s:Sprite = new Sprite();
				s.addChild(ResList.GetArtResource("shop_splash_new"));
				s.x = bgImage.x + bgImage.width - s.width / 2;
				s.y = bgImage.y - s.height / 2;
				shopContent.addChild(s);
			}
			
			tf.color = -1;
			tf.bold = true;
			tf.size = 16;
			
			if(bgBought) {
				label = new TextField();
				label.text = "You already own this background";
				label.setTextFormat(tf);
				label.width = shopContent.parent.width;
				label.y = 360;
				label.autoSize = TextFieldAutoSize.CENTER;
				label.mouseEnabled = false;
				shopContent.addChild(label);
			}
			else {
				var buttonWrap:Sprite = new Sprite;
				
				label = new TextField();
				label.text = "" + shopItem.PriceCoins; 
				label.setTextFormat(tf);
				label.width = 68;
				label.autoSize = TextFieldAutoSize.LEFT;
				label.y = 50 - label.height / 2;
				buttonWrap.addChild(label);
				
				var icon:Sprite = new Sprite();
				icon.addChild(ResList.GetArtResource("shop_coin"));
				icon.x = label.width + 5;
				icon.y = 50 - icon.height / 2;
				buttonWrap.addChild(icon);
				
				var buttonHex:ButtonHex = new ButtonHex("BUY", function():void {buyItem("MapBackground" + currentBgIndex);}, "button_small_gold"); 
				buttonHex.x = icon.x + icon.width + 10;
				buttonHex.y = 50 - buttonHex.height / 2;
				buttonWrap.addChild(buttonHex);
				
				if(shopItem.PriceShards > 0) {
					label = new TextField();
					label.text = "" + shopItem.PriceShards; 
					label.setTextFormat(tf);
					label.x = buttonHex.x + buttonHex.width + 20;
					label.width = 58;
					label.autoSize = TextFieldAutoSize.RIGHT;
					label.y = 50 - label.height / 2;
					buttonWrap.addChild(label);
					
					icon = new Sprite();
					icon.addChild(ResList.GetArtResource("shop_shard"));
					icon.x = label.x + label.width + 5;
					icon.y = 50 - icon.height / 2;
					buttonWrap.addChild(icon);
					
					buttonHex = new ButtonHex("BUY", function():void {buyItemShards("MapBackground" + currentBgIndex);}, "button_small_gray"); 
					buttonHex.x = icon.x + icon.width + 10;
					buttonHex.y = 50 - buttonHex.height / 2;
					buttonWrap.addChild(buttonHex);
				}
				
				buttonWrap.x = shopContent.parent.width / 2 - buttonWrap.width / 2;
				buttonWrap.y = 320;
				shopContent.addChild(buttonWrap);
			}
			
			G.gatracker.trackPageview("/shop/backgrounds/" + currentBg);
		}
		
		//////////////////
		///// UPGRADES
		/////////////////
		protected function showUpgradesContent():void {
			shopContentType = 4;
			
			buttonPremium.setImage("button_medium_gray");
			buttonRaces.setImage("button_medium_gray");
			buttonMaps.setImage("button_medium_gray");
			buttonBackgrounds.setImage("button_medium_gray");
			buttonUpgrades.setImage("button_medium_gold");
			buttonBoosts.setImage("button_medium_gray");
			buttonEditor.setImage("button_medium_gray");
			
			while(shopContent.numChildren > 0) shopContent.removeChildAt(shopContent.numChildren - 1);
			
			if(shopItems == null) return;
			
			var tf:TextFormat = new TextFormat("Arial", 24, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			var title:TextField = new TextField();
			title.text = "UPGRADES";
			title.setTextFormat(tf);
			title.width = shopContent.parent.width;
			title.y = 10;
			title.autoSize = TextFieldAutoSize.CENTER;
			title.mouseEnabled = false;
			shopContent.addChild(title);
			
			tf.size = 18;
			
			var label:TextField = new TextField();
			label.text = "Upgrade your army storage capacity\n(you can store more unused army at the end of your turn).";
			label.setTextFormat(tf);
			label.x = 50;
			label.width = shopContent.parent.width - 100;
			label.y = 58;
			label.multiline = true;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.mouseEnabled = false;
			shopContent.addChild(label);
			
			/*var divider:Sprite = new Sprite();
			divider.addChild(ResList.GetArtResource("menu_divider_horizontal"));
			divider.width = 500;
			divider.y = 128;
			divider.x = shopContent.parent.width / 2 - divider.width / 2;
			shopContent.addChild(divider);*/
			
			for(var i:int = 0; i < 4; i++) {
				tf.size = 16;
				
				label = new TextField();
				switch(i) {
					case 0:label.text = "Upgrade 1\n(+10 storage)"; break;
					case 1:label.text = "Upgrade 2\n(+10 storage)"; break;
					case 2:label.text = "Upgrade 3\n(+10% of map region count, up to 10 storage)"; break;
					case 3:label.text = "Upgrade 4\n(+10% of map region count, up to 10 storage)"; break;
				}
				label.setTextFormat(tf, 0, 9);
				//if(i > 1) {
					label.setTextFormat(new TextFormat("Arial", 14, 0xAAAAAA, true, null, null, null, null, TextFormatAlign.CENTER), 10, label.text.length);
				//}
				
				label.x = 6;
				label.width = shopContent.parent.width - 370;
				label.multiline = true;
				label.wordWrap = true;
				label.autoSize = TextFieldAutoSize.CENTER;
				label.y = 128 + i * 68 + 68 / 2 - label.height / 2;
				label.mouseEnabled = false;
				shopContent.addChild(label);
				
				var itemName:String = "ArmyStorageUpg" + (i + 1);
				var shopItem:DatabaseObject = shopItems[itemName];
				if(G.client.payVault.has(itemName)) {
					label = new TextField();
					label.text = "You already own this upgrade";
					label.setTextFormat(tf);
					label.x = shopContent.width - 350;
					label.width = 350;
					label.autoSize = TextFieldAutoSize.CENTER;
					label.y = 128 + i * 68 + 68 / 2 - label.height / 2;
					label.mouseEnabled = false;
					shopContent.addChild(label);
				}
				else {
					var buttonWrap:Sprite = new Sprite;
					
					label = new TextField();
					label.text = "" + shopItem.PriceCoins; 
					label.setTextFormat(tf);
					label.width = 68;
					label.autoSize = TextFieldAutoSize.LEFT;
					label.y = 20 - label.height / 2;
					buttonWrap.addChild(label);
					
					var icon:Sprite = new Sprite();
					icon.addChild(ResList.GetArtResource("shop_coin"));
					icon.x = label.width + 5;
					icon.y = 20 - icon.height / 2;
					buttonWrap.addChild(icon);
					
					var buttonHex:ButtonHex;
					switch(i) {
						case 0: buttonHex = new ButtonHex("BUY", function():void {buyItem("ArmyStorageUpg1");}, "button_small_gold"); break;
						case 1: buttonHex = new ButtonHex("BUY", function():void {buyItem("ArmyStorageUpg2");}, "button_small_gold"); break;
						case 2: buttonHex = new ButtonHex("BUY", function():void {buyItem("ArmyStorageUpg3");}, "button_small_gold"); break;
						case 3: buttonHex = new ButtonHex("BUY", function():void {buyItem("ArmyStorageUpg4");}, "button_small_gold"); break;
					}
					 
					buttonHex.x = icon.x + icon.width + 8;
					buttonHex.y = 20 - buttonHex.height / 2;
					buttonWrap.addChild(buttonHex);
					
					if(shopItem.PriceShards > 0) {
						label = new TextField();
						label.text = "" + shopItem.PriceShards; 
						label.setTextFormat(tf);
						label.x = buttonHex.x + buttonHex.width + 4;
						label.width = 58;
						label.autoSize = TextFieldAutoSize.RIGHT;
						label.y = 20 - label.height / 2;
						buttonWrap.addChild(label);
						
						icon = new Sprite();
						icon.addChild(ResList.GetArtResource("shop_shard"));
						icon.x = label.x + label.width + 5;
						icon.y = 20 - icon.height / 2;
						buttonWrap.addChild(icon);
						
						switch(i) {
							case 0: buttonHex = new ButtonHex("BUY", function():void {buyItemShards("ArmyStorageUpg1");}, "button_small_gray"); break;
							case 1: buttonHex = new ButtonHex("BUY", function():void {buyItemShards("ArmyStorageUpg2");}, "button_small_gray"); break;
							case 2: buttonHex = new ButtonHex("BUY", function():void {buyItemShards("ArmyStorageUpg3");}, "button_small_gray"); break;
							case 3: buttonHex = new ButtonHex("BUY", function():void {buyItemShards("ArmyStorageUpg4");}, "button_small_gray"); break;
						}
						 
						buttonHex.x = icon.x + icon.width + 8;
						buttonHex.y = 20 - buttonHex.height / 2;
						buttonWrap.addChild(buttonHex);
					}
					
					buttonWrap.x = shopContent.parent.width - buttonWrap.width - 20;
					buttonWrap.y = 128 + i * 68 + 68 / 2 - buttonWrap.height / 2;
					shopContent.addChild(buttonWrap);
				}
				
				var divider:Sprite = new Sprite();
				divider.addChild(ResList.GetArtResource("menu_divider_horizontal"));
				divider.width = 500;
				divider.y = 128 + i * 68;
				divider.x = shopContent.parent.width / 2 - divider.width / 2;
				shopContent.addChild(divider);
			}
			
			
			/*label = new TextField();
			label.text = "Upgrade 2 (+10 storage)";
			label.setTextFormat(tf);
			label.x = 50;
			label.width = shopContent.parent.width - 100;
			label.y = 250;
			label.multiline = true;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.mouseEnabled = false;
			shopContent.addChild(label);
			
			shopItem = shopItems["ArmyStorageUpg2"];
			if(G.client.payVault.has("ArmyStorageUpg2")) {
				label = new TextField();
				label.text = "You already own this upgrade";
				label.setTextFormat(tf);
				label.width = shopContent.parent.width;
				label.y = 300;
				label.autoSize = TextFieldAutoSize.CENTER;
				label.mouseEnabled = false;
				shopContent.addChild(label);
			}
			else {
				buttonWrap = new Sprite;
				
				label = new TextField();
				label.text = "" + shopItem.PriceCoins; 
				label.setTextFormat(tf);
				label.width = 68;
				label.autoSize = TextFieldAutoSize.LEFT;
				label.y = 50 - label.height / 2;
				buttonWrap.addChild(label);
				
				icon = new Sprite();
				icon.addChild(ResList.GetArtResource("shop_coin"));
				icon.x = label.width + 5;
				icon.y = 50 - icon.height / 2;
				buttonWrap.addChild(icon);
				
				buttonHex = new ButtonHex("BUY", function():void {buyItem("ArmyStorageUpg2");}, "button_small_gold"); 
				buttonHex.x = icon.x + icon.width + 10;
				buttonHex.y = 50 - buttonHex.height / 2;
				buttonWrap.addChild(buttonHex);
				
				if(shopItem.PriceShards > 0) {
					label = new TextField();
					label.text = "" + shopItem.PriceShards; 
					label.setTextFormat(tf);
					label.x = buttonHex.x + buttonHex.width + 20;
					label.width = 58;
					label.autoSize = TextFieldAutoSize.RIGHT;
					label.y = 50 - label.height / 2;
					buttonWrap.addChild(label);
					
					icon = new Sprite();
					icon.addChild(ResList.GetArtResource("shop_shard"));
					icon.x = label.x + label.width + 5;
					icon.y = 50 - icon.height / 2;
					buttonWrap.addChild(icon);
					
					buttonHex = new ButtonHex("BUY", function():void {buyItemShards("ArmyStorageUpg2");}, "button_small_gray"); 
					buttonHex.x = icon.x + icon.width + 10;
					buttonHex.y = 50 - buttonHex.height / 2;
					buttonWrap.addChild(buttonHex);
				}
				
				buttonWrap.x = shopContent.parent.width / 2 - buttonWrap.width / 2;
				buttonWrap.y = 260;
				shopContent.addChild(buttonWrap);
			}
			
			divider = new Sprite();
			divider.addChild(ResList.GetArtResource("menu_divider_horizontal"));
			divider.width = 500;
			divider.y = 400;
			divider.x = shopContent.parent.width / 2 - divider.width / 2;
			shopContent.addChild(divider);*/
			
			G.gatracker.trackPageview("/shop/backgrounds");
		}
		
		//////////////////
		///// Boosts
		/////////////////
		protected function showBoostsContent():void {
			shopContentType = 5;
			
			buttonPremium.setImage("button_medium_gray");
			buttonRaces.setImage("button_medium_gray");
			buttonMaps.setImage("button_medium_gray");
			buttonBackgrounds.setImage("button_medium_gray");
			buttonUpgrades.setImage("button_medium_gray");
			buttonBoosts.setImage("button_medium_gold");
			buttonEditor.setImage("button_medium_gray");
			
			while(shopContent.numChildren > 0) shopContent.removeChildAt(shopContent.numChildren - 1);
			
			if(shopItems == null) return;
			
			var tf:TextFormat = new TextFormat("Arial", 24, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			var title:TextField = new TextField();
			title.text = "BOOSTS";
			title.setTextFormat(tf);
			title.width = shopContent.parent.width;
			title.y = 10;
			title.autoSize = TextFieldAutoSize.CENTER;
			title.mouseEnabled = false;
			shopContent.addChild(title);
			
			tf.size = 18;
			
			/*var divider:Sprite = new Sprite();
			divider.addChild(ResList.GetArtResource("menu_divider_horizontal"));
			divider.width = 500;
			divider.y = 128;
			divider.x = shopContent.parent.width / 2 - divider.width / 2;
			shopContent.addChild(divider);*/
			
			tf.size = 16;
			
			var icon:Sprite = new Sprite();
			icon.addChild(ResList.GetArtResource("boost_attack_icon"));
			icon.x = 206;
			icon.y = 62;
			shopContent.addChild(icon);
			
			var label:TextField = new TextField();
			label.text = "Attack boosts";
			label.setTextFormat(tf);
			label.x = 50;
			label.width = shopContent.parent.width - 100;
			label.y = 60;
			label.multiline = true;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.mouseEnabled = false;
			shopContent.addChild(label);
			
			icon = new Sprite();
			icon.addChild(ResList.GetArtResource("boost_defense_icon"));
			icon.x = 200;
			icon.y = 242;
			shopContent.addChild(icon);
			
			label = new TextField();
			label.text = "Defense boosts";
			label.setTextFormat(tf);
			label.x = 54;
			label.width = shopContent.parent.width - 100;
			label.y = 242;
			label.multiline = true;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.mouseEnabled = false;
			shopContent.addChild(label);
			
			for(var i:int = 0; i < 3; i++) {
				var amount:int;
				switch(i) {
					case 0: amount = 10; break;
					case 1: amount = 50; break;
					case 2: amount = 200; break;
				}
				
				var shopItem:DatabaseObject = shopItems["AttackBoostPack"+amount];
				
				label = new TextField();
				label.text = amount + " boost pack";
				label.setTextFormat(tf);
				label.x = 50;
				label.y = 100 + i * 44;
				label.autoSize = TextFieldAutoSize.RIGHT;
				label.mouseEnabled = false;
				shopContent.addChild(label);
				
				label = new TextField();
				label.text = "" + shopItem.PriceCoins; 
				label.setTextFormat(tf);
				label.x = 160;
				label.width = 58;
				label.autoSize = TextFieldAutoSize.RIGHT;
				label.y = 100 + i * 44;
				shopContent.addChild(label);
				
				icon = new Sprite();
				icon.addChild(ResList.GetArtResource("shop_coin"));
				icon.x = label.x + label.width + 5;
				icon.y = 100 + i * 44;
				shopContent.addChild(icon);
				
				var buttonHex:ButtonHex
				if(i == 0) {
					buttonHex = new ButtonHex("BUY", function():void {buyItem("AttackBoostPack10");}, "button_small_gold");
				}
				else if(i == 1) {
					buttonHex = new ButtonHex("BUY", function():void {buyItem("AttackBoostPack50");}, "button_small_gold");
				}
				else {
					buttonHex = new ButtonHex("BUY", function():void {buyItem("AttackBoostPack200");}, "button_small_gold");
				}
				buttonHex.x = icon.x + icon.width + 10;
				buttonHex.y = 92 + i * 44;
				shopContent.addChild(buttonHex);
				
				if(shopItem.PriceShards > 0) {
					label = new TextField();
					label.text = "" + shopItem.PriceShards; 
					label.setTextFormat(tf);
					label.x = 330;
					label.width = 58;
					label.autoSize = TextFieldAutoSize.RIGHT;
					label.y = 100 + i * 44;
					shopContent.addChild(label);
					
					icon = new Sprite();
					icon.addChild(ResList.GetArtResource("shop_shard"));
					icon.x = label.x + label.width + 5;
					icon.y = 100 + i * 44;
					shopContent.addChild(icon);
					
					if(i == 0) {
						buttonHex = new ButtonHex("BUY", function():void {buyItemShards("AttackBoostPack10");}, "button_small_gray");
					}
					else if(i == 1) {
						buttonHex = new ButtonHex("BUY", function():void {buyItemShards("AttackBoostPack50");}, "button_small_gray");
					}
					else {
						buttonHex = new ButtonHex("BUY", function():void {buyItemShards("AttackBoostPack200");}, "button_small_gray");
					}
					//buttonHex = new ButtonHex("BUY", function():void {buyItemShards("AttackBoostPack"+amount);}, "button_small_gray"); 
					buttonHex.x = icon.x + icon.width + 10;
					buttonHex.y = 92 + i * 44;
					shopContent.addChild(buttonHex);
				}
				
				shopItem = shopItems["DefenseBoostPack"+amount];
				
				label = new TextField();
				label.text = amount + " boost pack";
				label.setTextFormat(tf);
				label.x = 50;
				label.y = 280 + i * 44;
				label.autoSize = TextFieldAutoSize.RIGHT;
				label.mouseEnabled = false;
				shopContent.addChild(label);
				
				label = new TextField();
				label.text = "" + shopItem.PriceCoins; 
				label.setTextFormat(tf);
				label.x = 160;
				label.width = 58;
				label.autoSize = TextFieldAutoSize.RIGHT;
				label.y = 280 + i * 44;
				shopContent.addChild(label);
				
				icon = new Sprite();
				icon.addChild(ResList.GetArtResource("shop_coin"));
				icon.x = label.x + label.width + 5;
				icon.y = 280 + i * 44;
				shopContent.addChild(icon);
				
				if(i == 0) {
					buttonHex = new ButtonHex("BUY", function():void {buyItem("DefenseBoostPack10");}, "button_small_gold");
				}
				else if(i == 1) {
					buttonHex = new ButtonHex("BUY", function():void {buyItem("DefenseBoostPack50");}, "button_small_gold");
				}
				else {
					buttonHex = new ButtonHex("BUY", function():void {buyItem("DefenseBoostPack200");}, "button_small_gold");
				}
				buttonHex.x = icon.x + icon.width + 10;
				buttonHex.y = 272 + i * 44;
				shopContent.addChild(buttonHex);
				
				if(shopItem.PriceShards > 0) {
					label = new TextField();
					label.text = "" + shopItem.PriceShards; 
					label.setTextFormat(tf);
					label.x = 330;
					label.width = 58;
					label.autoSize = TextFieldAutoSize.RIGHT;
					label.y = 280 + i * 44;
					shopContent.addChild(label);
					
					icon = new Sprite();
					icon.addChild(ResList.GetArtResource("shop_shard"));
					icon.x = label.x + label.width + 5;
					icon.y = 280 + i * 44;
					shopContent.addChild(icon);
					
					if(i == 0) {
						buttonHex = new ButtonHex("BUY", function():void {buyItemShards("DefenseBoostPack10");}, "button_small_gray");
					}
					else if(i == 1) {
						buttonHex = new ButtonHex("BUY", function():void {buyItemShards("DefenseBoostPack50");}, "button_small_gray");
					}
					else {
						buttonHex = new ButtonHex("BUY", function():void {buyItemShards("DefenseBoostPack200");}, "button_small_gray");
					}
					buttonHex.x = icon.x + icon.width + 10;
					buttonHex.y = 272 + i * 44;
					shopContent.addChild(buttonHex);
				}
			}
			
			G.gatracker.trackPageview("/shop/boosts");
		}
		
		//////////////////
		///// Map editor
		/////////////////
		protected function showEditorContent():void {
			shopContentType = 6;
			
			buttonPremium.setImage("button_medium_gray");
			buttonRaces.setImage("button_medium_gray");
			buttonMaps.setImage("button_medium_gray");
			buttonBackgrounds.setImage("button_medium_gray");
			buttonUpgrades.setImage("button_medium_gray");
			buttonBoosts.setImage("button_medium_gray");
			buttonEditor.setImage("button_medium_gold");
			
			while(shopContent.numChildren > 0) shopContent.removeChildAt(shopContent.numChildren - 1);
			
			if(shopItems == null) return;
			
			var tf:TextFormat = new TextFormat("Arial", 24, -1, true);
			tf.align = TextFormatAlign.LEFT;
			
			var title:TextField = new TextField();
			title.text = "MAP EDITOR";
			title.setTextFormat(tf);
			title.width = shopContent.parent.width;
			title.y = 10;
			title.autoSize = TextFieldAutoSize.CENTER;
			title.mouseEnabled = false;
			shopContent.addChild(title);
			
			tf.size = 18;
			
			var shopItem:DatabaseObject;
			if(G.client.payVault.has("EditorDeluxe")) {
				shopItem = shopItems["EditorSlot"];
				
				var label:TextField = new TextField();
				label.text = "You already own Deluxe editor. Now you can buy aditional slots for maps.\n\nYou currently own " + G.user.mapSlots + " slots";
				label.setTextFormat(tf);
				label.x = 40;
				label.y = 80;
				label.width = shopContent.parent.width - 80;
				label.mouseEnabled = false;
				label.multiline = true;
				label.wordWrap = true;
				label.autoSize = TextFieldAutoSize.LEFT;
				shopContent.addChild(label);
				
				label = new TextField();
				label.text = "New map slot";
				label.x = 60;
				label.y = 220;
				label.setTextFormat(tf);
				label.autoSize = TextFieldAutoSize.LEFT;
				label.mouseEnabled = false;
				shopContent.addChild(label);
				
				label = new TextField();
				label.text = shopItem.PriceCoins.toString();
				label.x = 200;
				label.y = 220;
				label.setTextFormat(tf);
				label.autoSize = TextFieldAutoSize.LEFT;
				label.mouseEnabled = false;
				shopContent.addChild(label);
				
				var coinIcon:Sprite = new Sprite();
				coinIcon.addChild(ResList.GetArtResource("shop_coin"));
				coinIcon.x = label.x + label.width + 6;
				coinIcon.y = label.y + label.height / 2 - coinIcon.height / 2;
				shopContent.addChild(coinIcon);
				
				var button:ButtonHex = new ButtonHex("BUY", function():void {buyItem("EditorSlot");}, "button_small_gold");
				button.x = coinIcon.x + coinIcon.width + 10;
				button.y = label.y + int(label.height / 2 - button.height / 2);
				shopContent.addChild(button);
				
				label = new TextField();
				label.text = shopItem.PriceShards.toString();
				label.x = button.x + button.width + 20;;
				label.y = 220;
				label.setTextFormat(tf);
				label.autoSize = TextFieldAutoSize.LEFT;
				label.mouseEnabled = false;
				shopContent.addChild(label);
				
				var shardIcon:Sprite = new Sprite();
				shardIcon.addChild(ResList.GetArtResource("shop_shard"));
				shardIcon.x = label.x + label.width + 6;
				shardIcon.y = label.y + label.height / 2 - shardIcon.height / 2;
				shopContent.addChild(shardIcon);
				
				button = new ButtonHex("BUY", function():void {buyItemShards("EditorSlot");}, "button_small_gray");
				button.x = shardIcon.x + shardIcon.width + 10;
				button.y = label.y + int(label.height / 2 - button.height / 2);
				shopContent.addChild(button);
			}
			else {
				shopItem = shopItems["EditorDeluxe"];
				
				label = new TextField();
				label.text = "If you buy Deluxe editor, you will get the following bonuses:";
				label.setTextFormat(tf);
				label.x = 40;
				label.y = 80;
				label.mouseEnabled = false;
				label.autoSize = TextFieldAutoSize.LEFT;
				shopContent.addChild(label);
				
				label = new TextField();
				label.text = "  - Region limit raised to 250 regions per map";
				label.setTextFormat(tf);
				label.x = 50;
				label.y = 110;
				label.autoSize = TextFieldAutoSize.LEFT;
				label.mouseEnabled = false;
				shopContent.addChild(label);
				
				label = new TextField();
				label.text = "  - Greatly increased size of map canvas";
				label.setTextFormat(tf);
				label.x = 50;
				label.y = 140;
				label.autoSize = TextFieldAutoSize.LEFT;
				label.mouseEnabled = false;
				shopContent.addChild(label);
				
				label = new TextField();
				label.text = "  - 2 additional map slots";
				label.setTextFormat(tf);
				label.x = 50;
				label.y = 170;
				label.autoSize = TextFieldAutoSize.LEFT;
				label.mouseEnabled = false;
				shopContent.addChild(label);
				
				label = new TextField();
				label.text = "  - Ability to unlock more slots";
				label.setTextFormat(tf);
				label.x = 50;
				label.y = 200;
				label.autoSize = TextFieldAutoSize.LEFT;
				label.mouseEnabled = false;
				shopContent.addChild(label);
				
				label = new TextField();
				label.text = shopItem.PriceCoins.toString();
				label.x = 200;
				label.y = 270;
				label.setTextFormat(tf);
				label.autoSize = TextFieldAutoSize.LEFT;
				label.mouseEnabled = false;
				shopContent.addChild(label);
				
				coinIcon = new Sprite();
				coinIcon.addChild(ResList.GetArtResource("shop_coin"));
				coinIcon.x = label.x + label.width + 6;
				coinIcon.y = label.y + label.height / 2 - coinIcon.height / 2;
				shopContent.addChild(coinIcon);
				
				button = new ButtonHex("BUY", function():void {buyItem("EditorDeluxe");}, "button_small_gold");
				button.x = coinIcon.x + coinIcon.width + 10;
				button.y = label.y + int(label.height / 2 - button.height / 2);
				shopContent.addChild(button);
			}
			
			G.gatracker.trackPageview("/shop/mapEditor");
		}
		
		protected function updateContent():void {
			switch(shopContentType) {
				case 0: showPremiumContent(); break;
				case 1: showRacesContent(); break;
				case 2: showMapsContent(); break;
				case 3: showBackgroundsContent(); break;
				case 4: showUpgradesContent(); break;
				case 5: showBoostsContent(); break;
				case 6: showEditorContent(); break;
			}
		}
		
		protected function onNextRace(button:Button):void {
			currentRace = (currentRace + 1) % RACE_COUNT;
			showRacesContent();
		}
		
		protected function onPrevRace(button:Button):void {
			currentRace = (currentRace + (RACE_COUNT - 1)) % RACE_COUNT;
			showRacesContent();
		}
		
		protected function onNextMap(button:Button):void {
			currentMap = (currentMap + 1) % MAP_COUNT;
			showMapsContent();
		}
		
		protected function onPrevMap(button:Button):void {
			currentMap = (currentMap + (MAP_COUNT - 1)) % MAP_COUNT;
			showMapsContent();
		}
		
		protected function onNextBg(button:Button):void {
			currentBg = (currentBg + 1) % availableBackgrounds.length;
			showBackgroundsContent();
		}
		
		protected function onPrevBg(button:Button):void {
			currentBg = (currentBg - 1 + (availableBackgrounds.length)) % availableBackgrounds.length;
			showBackgroundsContent();
		}
		
		private function onPreview():void {
			addChild(new BackgoundPreview(availableBackgrounds[currentBg]));
		}
		
		private function onMoreCoinsClicked():void {
			if(G.host == G.HOST_KONGREGATE) {
				addChild(new KongregatePricePicker());
			}
			else if(G.host == G.HOST_FACEBOOK) {
				addChild(new FacebookPricePicker());
			}
			else {
				addChild(new CoinProviderPicker());
			}
		}
		
		private function messageReceived(message:Message):void {
			if(message.type == MessageID.ITEM_BOUGHT) {
				G.client.bigDB.loadMyPlayerObject(function(playerobject:DatabaseObject):void{
					try {
						refresh();
						
						ErrorManager.showCustomError2("Purchase successful", "SUCCESS", ErrorManager.ERROR_BUY_SUCCES);
						//var confDialog:ConfirmationDialog = new ConfirmationDialog("Purchase succesful", "OK", new function():void {confDialog.parent.removeChild(confDialog);}); 
						//addChild(confDialog);
					}
					catch(errObject:Error) {
						G.client.errorLog.writeError("handle load my player objects", "shop message received item bought", errObject.message, null);
					}
				});
			}
			if(message.type == MessageID.ITEM_BUY_FAILED) {
				var errCode:String = message.getString(0);
				if(errCode == "NotEnoughCoins")
					ErrorManager.showCustomError("YOU DON'T HAVE ENOUGH COINS TO BUY THIS ITEM", ErrorManager.ERROR_BUY_FAILED);
				else if(errCode == "NotEnoughShards") 
					ErrorManager.showCustomError("YOU DON'T HAVE ENOUGH SHARDS TO BUY THIS ITEM", ErrorManager.ERROR_BUY_FAILED);
				else 
					ErrorManager.showCustomError(errCode, ErrorManager.ERROR_BUY_FAILED);
				
				if(loading) {
					removeChild(loading);
					loading = null;
				}
			}
		}
		
		public function updateShop():void {
			G.client.bigDB.loadMyPlayerObject(function(playerobject:DatabaseObject):void{
				G.user.shards = playerobject.Shards;
				G.user.mapSlots = playerobject.EditorSlots;
				G.user.premiumUntil = playerobject.PremiumUntil;
				G.user.playerObject = playerobject;
				
				balanceCoinsLabel.text = "" + G.client.payVault.coins;
				balanceShardsLabel.text = "" + G.user.shards;
				var widerLabel:int = balanceCoinsLabel.width > balanceShardsLabel.width ? balanceCoinsLabel.width : balanceShardsLabel.width;
				balanceCoinsIcon.x = balanceCoinsLabel.x + widerLabel + 6;
				balanceShardsIcon.x = balanceCoinsLabel.x + widerLabel + 6;

				G.client.bigDB.loadKeys("PayVaultItems", payvaultKeys, function(objects:Array):void {
					shopItems = new Array();
					for each(var dbo:DatabaseObject in objects) {
						shopItems[dbo.key] = dbo;
					}
					
					if(loading) {
						removeChild(loading);
						loading = null;
					}
					
					updateContent();
				});
			});
		}
		
		public function refresh():void {
			if(loading == null) {
				loading = new Loading("LOADING...");
				addChild(loading);
			}
			G.client.payVault.refresh(function():void{
				updateShop();
				
			});
		}
		
		private function onBack():void {
			G.userConnection.removeMessageHandler(MessageID.ITEM_BOUGHT, messageReceived);
			G.userConnection.removeMessageHandler(MessageID.ITEM_BUY_FAILED, messageReceived);
			
			parent.addChild(new MainMenu());
			parent.removeChild(this);
		}
		
		private function buyItem(itemName:String):void {
			loading = new Loading("BUYING...");
			addChild(loading);
			G.userConnection.send(MessageID.ITEM_BUY, itemName, true);
			
			G.gatracker.trackPageview("/shop/purchase/" + itemName);
			G.gatracker.trackEvent("Purchase", "Coins", itemName);
		}
		
		private function buyItemShards(itemName:String):void {
			loading = new Loading("BUYING...");
			addChild(loading);
			G.userConnection.send(MessageID.ITEM_BUY, itemName, false);
			
			G.gatracker.trackPageview("/shop/purchaseShards/" + itemName);
			G.gatracker.trackEvent("Purchase", "Shards", itemName);
		}
	}
}