package Menu.PlayerProfile
{
	import Game.Backgrounds.BackgoundPreview;
	import Game.Backgrounds.Background;
	import Game.Races.Race;
	
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.Lobby.CreateGameScreen;
	import Menu.Login.LoginScreen;
	import Menu.MainMenu.MainMenu;
	import Menu.MainMenu.MenuShortcutsPanel;
	import Menu.MenuSelector;
	import Menu.NinePatchSprite;
	import Menu.Tooltips.TextTooltip;
	
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import playerio.DatabaseObject;
	
	public class ProfileScreen extends Sprite
	{
		private var raceImage:Sprite;
		private var raceName:TextField;
		private var raceDescLabel:TextField;
		private var availableRaces:Array = new Array();
		private var currentRace:int;

		private var bgImage:Sprite;
		private var bgName:TextField;
		private var currentBg:int;
		private var availableBgs:Array = new Array();
		private var bgCount:int;
		
		private var achievementsPanel:AchievementsPanel;
		private var loading:TextField;
		private var statsBG:Sprite;
		
		private var hidePremium:Sprite;
		private var publicProfile:Sprite;
		
		public function ProfileScreen()
		{
			super();
			
			graphics.beginBitmapFill(ResList.GetArtResource("bg").bitmapData);
			graphics.drawRect(0, 0, 800, 600);
			
			var bg:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 780, 540);
			bg.x = width / 2 - bg.width / 2;
			bg.y = 8;
			addChild(bg);
			
			statsBG = new NinePatchSprite("9patch_transparent_panel", 370, 218);
			statsBG.x = 15;
			statsBG.y = 12;
			bg.addChild(statsBG);
			
			var tf:TextFormat = new TextFormat("Arial", 20, -1, true);
			
			var label:TextField = new TextField();
			label.text = G.user.name;
			label.setTextFormat(tf);
			label.mouseEnabled = false;
			label.x = 20;
			label.y = 8;
			label.autoSize = TextFieldAutoSize.LEFT;
			statsBG.addChild(label);
			
			tf.size = 16;
			
			label = new TextField();
			label.text = "R: " + G.user.rating;
			label.setTextFormat(tf);
			label.mouseEnabled = false;
			label.autoSize = TextFieldAutoSize.RIGHT;
			label.x = statsBG.width - label.width - 30;
			label.y = 8;
			statsBG.addChild(label);
			
			tf.size = 18;
			
			label = new TextField();
			label.text = "LEVEL " + G.user.level;
			label.setTextFormat(tf);
			label.mouseEnabled = false;
			label.x = 20;
			label.y = 45;
			statsBG.addChild(label);
			
			tf.size = 14;
			
			var levelProgressSprite:Sprite = new Sprite();
			levelProgressSprite.addChild(ResList.GetArtResource("level_progress_bg"));
			levelProgressSprite.x = 144;
			levelProgressSprite.y = 42;
			statsBG.addChild(levelProgressSprite);
			
			var levelProgressFill:Sprite = new Sprite();
			levelProgressFill.addChild(ResList.GetArtResource("level_progress_fill_blue"));
			levelProgressSprite.addChild(levelProgressFill);
			
			var levelProgressMask:Sprite = new Sprite();
			levelProgressMask.graphics.beginFill(0);
			levelProgressMask.graphics.drawRect(3, 0, 195 * G.user.xp / G.user.getNextLvlXP(), levelProgressFill.height);
			levelProgressSprite.addChild(levelProgressMask);
			levelProgressFill.mask = levelProgressMask;
			
			var levelProgress:TextField = new TextField();
			levelProgress.text = G.user.xp + " / " + G.user.getNextLvlXP() + " xp";
			levelProgress.setTextFormat(tf);
			levelProgress.width = levelProgressSprite.width;
			levelProgress.x = 0;
			levelProgress.autoSize = TextFieldAutoSize.CENTER;
			levelProgress.y = (levelProgressSprite.height - 5) / 2 - levelProgress.height / 2;
			levelProgress.mouseEnabled = false;
			levelProgressSprite.addChild(levelProgress);
			
			loading = new TextField();
			loading.text = "LOADING...";
			loading.width = statsBG.width;
			loading.setTextFormat(tf);
			loading.autoSize = TextFieldAutoSize.CENTER
			loading.y = 106;
			statsBG.addChild(loading);
			
			achievementsPanel = new AchievementsPanel(); 
			addChild(achievementsPanel);
			
			addChild(new MenuShortcutsPanel(onBack));
			
			var raceBg:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 370, 298);
			raceBg.x = 15;
			raceBg.y = 236;
			bg.addChild(raceBg);
			
			tf.size = 20;
			
			label = new TextField();
			label.text = "CHOOSE RACE";
			label.setTextFormat(tf);
			label.mouseEnabled = false;
			label.autoSize = TextFieldAutoSize.CENTER
			label.x = raceBg.width / 2 - label.width / 2;
			label.y = 3;
			raceBg.addChild(label);
			
			var imgBg:NinePatchSprite = new NinePatchSprite("9patch_emboss_panel", 188, 188);
			imgBg.x = raceBg.width / 2 - imgBg.width / 2;
			imgBg.y = 28;
			raceBg.addChild(imgBg);
			
			raceImage = new Sprite();
			raceImage.addChild(G.user.race.profileImage);
			raceImage.y = 4;
			raceImage.x = 4;
			imgBg.addChild(raceImage);
			
			var button:Button = new Button(null, onPrevRace, ResList.GetArtResource("selector_arrow_big"));
			button.x = 38;
			button.y = imgBg.y + imgBg.height / 2 - button.height / 2;
			raceBg.addChild(button);
			
			button = new Button(null, onNextRace, ResList.GetArtResource("selector_arrow_big"));
			button.scaleX = -1;
			button.x = raceBg.width - 38;
			button.y = imgBg.y + imgBg.height / 2 - button.height / 2;
			raceBg.addChild(button);
			
			var raceNameTF:TextFormat = new TextFormat("Arial", 20, -1, true);
			
			raceName = new TextField();
			raceName.defaultTextFormat = raceNameTF;
			raceName.text = G.user.race.name;
			raceName.x = 40;
			raceName.width = raceBg.width - 80;
			raceName.autoSize = TextFieldAutoSize.CENTER;
			raceName.y = 213;
			raceName.mouseEnabled = false;
			raceBg.addChild(raceName);
			
			var descTF:TextFormat = new TextFormat("Arial", 11, -1, true);
			descTF.align = TextFormatAlign.CENTER;
			
			raceDescLabel = new TextField();
			raceDescLabel.defaultTextFormat = descTF;
			raceDescLabel.text = G.user.race.description;
			raceDescLabel.multiline = true;
			raceDescLabel.wordWrap = true;
			raceDescLabel.x = 10;
			raceDescLabel.width = raceBg.width - 20;
			raceDescLabel.autoSize = TextFieldAutoSize.CENTER;
			raceDescLabel.y = 238;
			raceDescLabel.mouseEnabled = false;
			raceBg.addChild(raceDescLabel);
			
			// add available races
			
			var bgBg:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 370, 298);
			bgBg.x = 394;
			bgBg.y = 236;
			bg.addChild(bgBg);
			
			tf.size = 20;
			
			label = new TextField();
			label.text = "CHOOSE BACKGROUND";
			label.setTextFormat(tf);
			label.mouseEnabled = false;
			label.autoSize = TextFieldAutoSize.CENTER
			label.x = bgBg.width / 2 - label.width / 2;
			label.y = 8;
			bgBg.addChild(label);
			
			var bgImageBg:NinePatchSprite = new NinePatchSprite("9patch_emboss_panel", 170, 170);
			bgImageBg.x = bgBg.width / 2 - bgImageBg.width / 2;
			bgImageBg.y = 40;
			bgBg.addChild(bgImageBg);
			
			bgImage = new Sprite();
			bgImage.x = 10;
			bgImage.y = 10;
			bgImageBg.addChild(bgImage);
			
			var bgSprite:Background = new Background(G.user.background, 150, 150);
			bgImage.addChild(bgSprite);
			
			button = new Button(null, onPrevBg, ResList.GetArtResource("selector_arrow_big"));
			button.x = 38;
			button.y = bgImageBg.y + bgImageBg.height / 2 - button.height / 2;
			bgBg.addChild(button);
			
			button = new Button(null, onNextBg, ResList.GetArtResource("selector_arrow_big"));
			button.scaleX = -1;
			button.x = raceBg.width - 38;
			button.y = bgImageBg.y + bgImageBg.height / 2 - button.height / 2;
			bgBg.addChild(button);
			
			var bgNameTF:TextFormat = new TextFormat("Arial", 20, -1, true);
			
			bgName = new TextField();
			bgName.defaultTextFormat = bgNameTF;
			bgName.text = Background.getName(G.user.background);
			bgName.x = 40;
			bgName.width = bgBg.width - 80;
			bgName.autoSize = TextFieldAutoSize.CENTER;
			bgName.y = 216;
			bgName.mouseEnabled = false;
			bgBg.addChild(bgName);
			
			var previewButton:ButtonHex = new ButtonHex("PREVIEW", onPreview, "button_small_gold");
			previewButton.x = bgBg.width / 2 - previewButton.width / 2;
			previewButton.y = 246;
			bgBg.addChild(previewButton);
			
			// add available backgrounds
			availableBgs.push(0);
			if(Background.isUnlocked(100)) {
				availableBgs.push(100);
			}
			for(var i:int = 1; i < 15; i++) {
				if(Background.isUnlocked(i)) {
					availableBgs.push(i);
				}
			} 
			
			for(i = 0; i < availableBgs.length; i++) {
				if(G.user.background == availableBgs[i]) {
					currentBg = i;
					break;
				}
			}
			
			G.client.bigDB.loadMyPlayerObject(function(playerobject:DatabaseObject):void {
				try {
					G.user.achievements = playerobject.Achievements;
					G.user.stats = playerobject.Stats;
					G.user.hidePremium = playerobject.HidePremium;
					G.user.playerObject = playerobject;
					
					achievementsPanel.profileDataLoaded();
					
					statsBG.removeChild(loading);
					loading = null;
					
					tf.size = 14;
					
					label = new TextField();
					label.text = "Matches played:";
					label.setTextFormat(tf);
					label.mouseEnabled = false;
					label.autoSize = TextFieldAutoSize.LEFT;
					label.x = 20;
					label.y = 94;
					statsBG.addChild(label);
					
					label= new TextField();
					label.text = G.user.stats.TotalMatches;
					label.setTextFormat(tf);
					label.mouseEnabled = false;
					label.x = 170;
					label.y = 94;
					statsBG.addChild(label);
					
					label = new TextField();
					label.text = "Matches won:";
					label.autoSize = TextFieldAutoSize.LEFT;
					label.setTextFormat(tf);
					label.mouseEnabled = false;
					label.x = 20;
					label.y = 120;
					statsBG.addChild(label);
					
					label= new TextField();
					label.text = G.user.stats.TotalWins;
					label.setTextFormat(tf);
					label.mouseEnabled = false;
					label.x = 170;
					label.y = 120;
					statsBG.addChild(label);
					
					label = new TextField();
					label.text = "Regions conquered:";
					label.autoSize = TextFieldAutoSize.LEFT;
					label.setTextFormat(tf);
					label.mouseEnabled = false;
					label.x = 20;
					label.y = 146;
					statsBG.addChild(label);
					
					label= new TextField();
					label.text = G.user.stats.RegionsConquered;
					label.setTextFormat(tf);
					label.mouseEnabled = false;
					label.x = 170;
					label.y = 146;
					statsBG.addChild(label);
					
					label = new TextField();
					label.text = "Regions lost:";
					label.autoSize = TextFieldAutoSize.LEFT;
					label.setTextFormat(tf);
					label.mouseEnabled = false;
					label.x = 20;
					label.y = 172;
					statsBG.addChild(label);
					
					label= new TextField();
					label.text = G.user.stats.RegionsLost;
					label.setTextFormat(tf);
					label.mouseEnabled = false;
					label.x = 170;
					label.y = 172;
					statsBG.addChild(label);
					
					var icon:Sprite = new Sprite();
					icon.addChild(ResList.GetArtResource("boost_attack_icon"));
					icon.x = 260;
					icon.y = 96;
					statsBG.addChild(icon);
					
					label = new TextField();
					label.text = playerobject.AttackBoosts + "";
					label.setTextFormat(tf);
					label.x = 274;
					label.y = 94;
					label.mouseEnabled = false;
					statsBG.addChild(label);
					
					icon = new Sprite();
					icon.addChild(ResList.GetArtResource("boost_defense_icon"));
					icon.x = 260;
					icon.y = 122;
					statsBG.addChild(icon);
					
					label = new TextField();
					label.text = playerobject.DefenseBoosts + "";
					label.setTextFormat(tf);
					label.x = 274;
					label.y = 120;
					label.mouseEnabled = false;
					statsBG.addChild(label);
					
					publicProfile = new Sprite();
					publicProfile.x = 220;
					publicProfile.y = 166;
					publicProfile.addEventListener(MouseEvent.CLICK, onPublicProfile, false, 0, true);
					publicProfile.useHandCursor = true;
					publicProfile.buttonMode = true;
					statsBG.addChild(publicProfile);
					
					var checkbox:Sprite = new Sprite();
					checkbox.addChild(ResList.GetArtResource(G.user.playerObject.PublicProfile ? "checkbox_selected" : "checkbox"));
					checkbox.x = 110;
					publicProfile.addChild(checkbox);
					
					tf.size = 13;
					var rememberText:TextField = new TextField();
					rememberText.x = 8;
					rememberText.text = "Public profile";
					rememberText.setTextFormat(tf);
					rememberText.autoSize = TextFieldAutoSize.LEFT;
					rememberText.y = publicProfile.height / 2 - rememberText.height / 2;
					rememberText.mouseEnabled = false;
					publicProfile.addChild(rememberText);
					
					var tooltip:TextTooltip = new TextTooltip("If enabled, other players will be able to see your stats, achievements and races", publicProfile);
					
					if(G.user.isPremium()) {
						hidePremium = new Sprite();
						hidePremium.x = 220;
						hidePremium.y = 190;
						hidePremium.addEventListener(MouseEvent.CLICK, onHidePremium, false, 0, true);
						hidePremium.useHandCursor = true;
						hidePremium.buttonMode = true;
						statsBG.addChild(hidePremium);
						
						checkbox = new Sprite();
						checkbox.addChild(ResList.GetArtResource(G.user.hidePremium ? "checkbox_selected" : "checkbox"));
						checkbox.x = 110;
						hidePremium.addChild(checkbox);
						
						tf.size = 13;
						rememberText = new TextField();
						rememberText.x = 8;
						rememberText.text = "Hide premium";
						rememberText.setTextFormat(tf);
						rememberText.autoSize = TextFieldAutoSize.LEFT;
						rememberText.y = hidePremium.height / 2 - rememberText.height / 2;
						rememberText.mouseEnabled = false;
						hidePremium.addChild(rememberText);
						
						tooltip = new TextTooltip("If enabled, your premium status will be hidden from other players", hidePremium);
					}
				}
				catch(errObject:Error) {
					G.client.errorLog.writeError("handle load my player objects", "profile scree init", errObject.message, null);
				}
			});
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			availableRaces.push(Race.RACE_ELVES);
			availableRaces.push(Race.RACE_SNOW_GIANTS);
			availableRaces.push(Race.RACE_LEGIONAIRES);
			if(G.user.isPremium())
				availableRaces.push(Race.RACE_ALIENS);
			if(Race.Create(Race.RACE_SOLDIERS).isUnlocked()) 
				availableRaces.push(Race.RACE_SOLDIERS);
			if(Race.Create(Race.RACE_ROBOTS).isUnlocked()) 
				availableRaces.push(Race.RACE_ROBOTS);
			if(Race.Create(Race.RACE_ELEMENTALS).isUnlocked()) 
				availableRaces.push(Race.RACE_ELEMENTALS);
			if(Race.Create(Race.RACE_PIRATES).isUnlocked()) 
				availableRaces.push(Race.RACE_PIRATES);
			if(Race.Create(Race.RACE_NINJAS).isUnlocked()) 
				availableRaces.push(Race.RACE_NINJAS);
			if(Race.Create(Race.RACE_INSECTOIDS).isUnlocked()) 
				availableRaces.push(Race.RACE_INSECTOIDS);
			if(Race.Create(Race.RACE_DEMONS).isUnlocked()) 
				availableRaces.push(Race.RACE_DEMONS);
			if(Race.Create(Race.RACE_ANGELS).isUnlocked()) 
				availableRaces.push(Race.RACE_ANGELS);
			if(Race.Create(Race.RACE_VAMPIRES).isUnlocked()) 
				availableRaces.push(Race.RACE_VAMPIRES);
			if(Race.Create(Race.RACE_PUMPKINS).isUnlocked()) 
				availableRaces.push(Race.RACE_PUMPKINS);
			if(Race.Create(Race.RACE_REPTILES).isUnlocked()) 
				availableRaces.push(Race.RACE_REPTILES);
			if(Race.Create(Race.RACE_ARACHNIDS).isUnlocked()) 
				availableRaces.push(Race.RACE_ARACHNIDS);
			if(Race.Create(Race.RACE_DRAGONS).isUnlocked()) 
				availableRaces.push(Race.RACE_DRAGONS);
			if(Race.Create(Race.RACE_SNOWMEN).isUnlocked()) 
				availableRaces.push(Race.RACE_SNOWMEN);
			if(Race.Create(Race.RACE_REINDEERS).isUnlocked()) 
				availableRaces.push(Race.RACE_REINDEERS);
			if(Race.Create(Race.RACE_SANTAS).isUnlocked()) 
				availableRaces.push(Race.RACE_SANTAS);
			if(Race.Create(Race.RACE_NATIVES).isUnlocked()) 
				availableRaces.push(Race.RACE_NATIVES);
			if(Race.Create(Race.RACE_UNDEAD).isUnlocked()) 
				availableRaces.push(Race.RACE_UNDEAD);
			if(Race.Create(Race.RACE_TERMINATORS).isUnlocked()) 
				availableRaces.push(Race.RACE_TERMINATORS);
			if(Race.Create(Race.RACE_BLADE_MASTERS).isUnlocked()) 
				availableRaces.push(Race.RACE_BLADE_MASTERS);
			if(Race.Create(Race.RACE_CYBORGS).isUnlocked()) 
				availableRaces.push(Race.RACE_CYBORGS);
			if(Race.Create(Race.RACE_DARK_KNIGHTS).isUnlocked()) 
				availableRaces.push(Race.RACE_DARK_KNIGHTS);
			if(Race.Create(Race.RACE_TEDDY_BEARS).isUnlocked()) 
				availableRaces.push(Race.RACE_TEDDY_BEARS);
			if(Race.Create(Race.RACE_WATCHMEN).isUnlocked()) 
				availableRaces.push(Race.RACE_WATCHMEN);
			if(Race.Create(Race.RACE_WEREWOLVES).isUnlocked()) 
				availableRaces.push(Race.RACE_WEREWOLVES);
			if(Race.Create(Race.RACE_FRANKENSTEINS).isUnlocked()) 
				availableRaces.push(Race.RACE_FRANKENSTEINS);
			if(Race.Create(Race.RACE_SNOWFLAKES).isUnlocked()) 
				availableRaces.push(Race.RACE_SNOWFLAKES);
			if(Race.Create(Race.RACE_TANNENBAUMS).isUnlocked()) 
				availableRaces.push(Race.RACE_TANNENBAUMS);
			
			for(i = 0; i < availableRaces.length; i++) {
				if(G.user.race.ID == availableRaces[i]) {
					currentRace = i;
					break;
				}
			}
			
			G.gatracker.trackPageview("/profileScreen");
		}
		
		private function onPublicProfile(event:MouseEvent):void {
			G.user.playerObject.PublicProfile = !G.user.playerObject.PublicProfile;
			publicProfile.removeChildAt(0);
			var checkbox:Sprite = new Sprite();
			checkbox.addChild(ResList.GetArtResource(G.user.playerObject.PublicProfile ? "checkbox_selected" : "checkbox"));
			checkbox.x = 110;
			publicProfile.addChildAt(checkbox, 0);
			
			G.userConnection.send(MessageID.USER_SET_PUBLIC_PROFILE, G.user.playerObject.PublicProfile);
		}
		
		private function onHidePremium(event:MouseEvent):void {
			G.user.hidePremium = !G.user.hidePremium;
			hidePremium.removeChildAt(0);
			var checkbox:Sprite = new Sprite();
			checkbox.addChild(ResList.GetArtResource(G.user.hidePremium ? "checkbox_selected" : "checkbox"));
			checkbox.x = 110;
			hidePremium.addChildAt(checkbox, 0);
			
			G.userConnection.send(MessageID.USER_SET_HIDE_PREMIUM, G.user.hidePremium);
		}
		
		private function onRemovedFromStage(event:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);

			if(G.userConnection) {
				G.userConnection.send(MessageID.USER_SET_RACE, G.user.race.ID);
				G.userConnection.send(MessageID.USER_SET_BG, G.user.background);
			}
		}
		
		private function onNextBg(button:Button):void {
			currentBg = (currentBg + 1) % availableBgs.length;
			setBg(currentBg);
		}
		
		private function onPrevBg(button:Button):void {
			currentBg = (currentBg + availableBgs.length - 1) % availableBgs.length;
			setBg(currentBg);
		}
		
		private function setBg(bgIndex:int):void {
			var currentBgID:int = availableBgs[bgIndex];
	
			bgImage.removeChildAt(0);
			
			var bgSprite:Background = new Background(currentBgID, 150, 150);
			bgImage.addChild(bgSprite);
			
			bgName.text = Background.getName(currentBgID);
			G.user.background = currentBgID;
		}
		
		private function onPreview():void {
			addChild(new BackgoundPreview(availableBgs[currentBg]));
		}
		
		private function onNextRace(button:Button):void {
			currentRace = (currentRace + 1) % availableRaces.length;
			setRace(availableRaces[currentRace]);
		}
		
		private function onPrevRace(button:Button):void {
			currentRace = (currentRace + availableRaces.length - 1) % availableRaces.length;
			setRace(availableRaces[currentRace]);
		}
		
		private function setRace(newRace:int):void {
			var race:Race = Race.Create(newRace);
			G.user.race = race;

			raceImage.removeChildAt(0);
			raceImage.addChild(race.profileImage);
			raceDescLabel.text = race.description;
			raceName.text = race.name;
		}
		
		private function onBack():void {
			parent.addChild(new MainMenu());
			parent.removeChild(this);
		}
	}
}