package Menu.PlayerProfile
{
	import Errors.ErrorManager;
	
	import Game.Races.Race;
	
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.LevelIcon;
	import Menu.NinePatchSprite;
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
	
	public class ProfileBadge extends Sprite
	{
		private var levelLabel:TextField;
		private var xpLabel:TextField;
		private var progressFill:Sprite;
		private var newProgressFill:Sprite;
		private var rankSprite:LevelIcon;
		
		private var delayTimer:Number;
		private var oldXp:Number;
		private var oldLvl:int;
		
		private var timeDelta:Number = 0;
		private var oldTime:Number = 0;
		private var prevTimeDelta:Number = 0;
		
		private var raceImg:Sprite;
		private var availableRaces:Array = new Array();
		private var currentRace:int;
		
		public function ProfileBadge()
		{
			super();
			
			addChild(new NinePatchSprite("9patch_transparent_panel", 408, 153));
			x = 40;
			y = 20;
			
			var imgBg:NinePatchSprite = new NinePatchSprite("9patch_emboss_panel", 98, 98);
			imgBg.x = 30;
			imgBg.y = 8;
			addChild(imgBg);
			
			raceImg = new Sprite();
			raceImg.addChild(G.user.race.profileImage);
			raceImg.x = 4;
			raceImg.y = 4;
			raceImg.scaleX = 0.5;
			raceImg.scaleY = 0.5;
			imgBg.addChild(raceImg);
			
			var buttonHex:ButtonHex = new ButtonHex("PROFILE", onMoreClicked, "button_small_gold");
			buttonHex.x = 28 + 103 / 2 - buttonHex.width / 2;
			buttonHex.y = 106;
			addChild(buttonHex);
			
			if(!G.user.isGuest) {
				var button:Button = new Button(null, onPrevRace, ResList.GetArtResource("selector_arrow_disabled"));
				button.x = imgBg.x - button.width - 6;
				button.y = imgBg.y + imgBg.height / 2 - button.height / 2;
				addChild(button);
				
				button = new Button(null, onNextRace, ResList.GetArtResource("selector_arrow_disabled"));
				button.x = imgBg.x + imgBg.width + 6 + button.width;
				button.scaleX = -1;
				button.y = imgBg.y + imgBg.height / 2 - button.height / 2;
				addChild(button);
			}
			
			var tf:TextFormat = new TextFormat("Arial", 24, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			var emboss:NinePatchSprite = new NinePatchSprite("9patch_emboss_panel", 211, 31);
			emboss.x = 166;
			emboss.y = 17;
			addChild(emboss);
			
			var name:TextField = new TextField();
			name.text = G.user.name;
			name.setTextFormat(tf);
			name.width = emboss.width;
			name.autoSize = TextFieldAutoSize.CENTER;
			name.mouseEnabled = false;
			emboss.addChild(name);
			
			while(name.width > emboss.width) {
				tf.size = (int)(tf.size) - 1;
				name.setTextFormat(tf);
			} 
			name.y = emboss.height / 2 - name.height / 2;
			
			tf.size = 18;
			
			if(G.user.isGuest) {
				var loginNeeded:TextField = new TextField();
				loginNeeded.text = "Register for free to get xp and level up";
				loginNeeded.setTextFormat(tf);
				loginNeeded.width = 183;
				loginNeeded.x = 180;
				loginNeeded.y = 72;
				loginNeeded.multiline = true;
				loginNeeded.wordWrap = true;
				loginNeeded.autoSize = TextFieldAutoSize.CENTER;
				loginNeeded.mouseEnabled = false;
				addChild(loginNeeded);
			}
			else {
				emboss = new NinePatchSprite("9patch_emboss_panel", 198, 33);
				emboss.x = 171;
				emboss.y = 63;
				addChild(emboss);
				
				var levelTF:TextFormat = new TextFormat("Arial", 18, -1, true);
				
				levelLabel = new TextField();
				levelLabel.defaultTextFormat = levelTF;
				levelLabel.text = "R: " + G.user.rating;
				levelLabel.width = 134;
				levelLabel.autoSize = TextFieldAutoSize.CENTER;
				levelLabel.y = emboss.height / 2 - levelLabel.height / 2;
				levelLabel.mouseEnabled = false;
				emboss.addChild(levelLabel);
				
				rankSprite = new LevelIcon(G.user.level);
				rankSprite.x = 162;
				rankSprite.y = emboss.height / 2 - rankSprite.height / 2;
				emboss.addChild(rankSprite);
				
				var tooltip:TextTooltip = new TextTooltip("LVL " + G.user.level, rankSprite);
				
				tf.size = 14;
				
				var levelProgressSprite:Sprite = new Sprite();
				levelProgressSprite.addChild(ResList.GetArtResource("level_progress_bg"));
				levelProgressSprite.x = 165;
				levelProgressSprite.y = 108;
				addChild(levelProgressSprite);
				
				newProgressFill = new Sprite();
				newProgressFill.addChild(ResList.GetArtResource("level_progress_fill_yellow"));
				levelProgressSprite.addChild(newProgressFill);
				
				var newLevelProgressMask:Sprite = new Sprite();
				newLevelProgressMask.graphics.beginFill(0);
				newLevelProgressMask.graphics.drawRect(9, 0, 0, newProgressFill.height);
				levelProgressSprite.addChild(newLevelProgressMask);
				newProgressFill.mask = newLevelProgressMask;
				
				progressFill = new Sprite();
				progressFill.addChild(ResList.GetArtResource("level_progress_fill_blue"));
				levelProgressSprite.addChild(progressFill);
				
				var levelProgressMask:Sprite = new Sprite();
				levelProgressMask.graphics.beginFill(0);
				levelProgressMask.graphics.drawRect(9, 0, 195 * G.user.xp / G.user.getNextLvlXP(), progressFill.height);
				levelProgressSprite.addChild(levelProgressMask);
				progressFill.mask = levelProgressMask;
				
				oldXp = G.user.xp;
				oldLvl = G.user.level;
				
				xpLabel = new TextField();
				xpLabel.defaultTextFormat = tf;
				xpLabel.text = G.user.xp + " / " + G.user.getNextLvlXP() + " xp";
				xpLabel.width = levelProgressSprite.width;
				xpLabel.x = 0;
				xpLabel.autoSize = TextFieldAutoSize.CENTER;
				xpLabel.y = (levelProgressSprite.height - 5) / 2 - xpLabel.height / 2;
				xpLabel.mouseEnabled = false;
				levelProgressSprite.addChild(xpLabel);
				
				addEventListener(Event.ENTER_FRAME, update, false, 0, true);
				addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			}
			
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
			
			for(var i:int = 0; i < availableRaces.length; i++) {
				if(G.user.race.ID == availableRaces[i]) {
					currentRace = i;
					break;
				}
			}
			
			var deco:Sprite = new Sprite();
			deco.addChild(ResList.GetArtResource("menu_deco_snow"));
			deco.x = -10;
			deco.y = -16;
			addChild(deco);
		}
		
		private function onRemovedFromStage(event:Event):void {
			removeEventListener(Event.ENTER_FRAME, update);
			
			//if(rankSprite) {
				//Bitmap(rankSprite.getChildAt(0)).bitmapData.dispose();
			//}
		}
		
		private function setRace(raceID:int):void {
			G.user.race = Race.Create(raceID);
			
			G.userConnection.send(MessageID.USER_SET_RACE, G.user.race.ID);
			raceImg.removeChildAt(0);
			raceImg.addChild(G.user.race.profileImage);
		}
		
		private function onNextRace(button:Button):void {
			currentRace = (currentRace + 1) % availableRaces.length;
			setRace(availableRaces[currentRace]);
		}
		
		private function onPrevRace(button:Button):void {
			currentRace = (currentRace + availableRaces.length - 1) % availableRaces.length;
			setRace(availableRaces[currentRace]);
		}
		
		private function update(event:Event):void	{
			prevTimeDelta = timeDelta;
			var time:Number = (new Date).getTime();
			timeDelta = (5*prevTimeDelta + (time - oldTime)/1000)/6;
			oldTime = time;
			if (timeDelta > 0.1)
				timeDelta = 0.1;
			
			if(delayTimer > 0) {
				delayTimer -= timeDelta;
				return;
			}
			
			if(oldLvl != G.user.level) {
				oldXp += timeDelta * 0.3 * G.user.getNextLvlXP(oldLvl);
				if(oldXp >= G.user.getNextLvlXP(oldLvl)) {
					oldLvl++;
					oldXp = 0;
					
					levelLabel.text = "R: " + G.user.rating;
					
					var fillMask:Sprite = (Sprite)(newProgressFill.mask);
					
					fillMask.graphics.clear();
					fillMask.graphics.beginFill(0);
					fillMask.graphics.drawRect(3, 0, 148 * G.user.xp / G.user.getNextLvlXP(), progressFill.height);
					
					rankSprite.setLevel(G.user.level);
					
					// todo: play sound or something
					G.errorSprite.addChild(new LevelUpScreen());
				}
			}
			else if(oldXp != G.user.xp) {
				oldXp += timeDelta * 0.3 * G.user.getNextLvlXP(oldLvl);
				if(oldXp >= G.user.xp) {
					oldXp = G.user.xp;
				}
			}
			
			xpLabel.text = (int)(oldXp) + " / " + G.user.getNextLvlXP(oldLvl) + " xp";
			
			fillMask = (Sprite)(progressFill.mask);
			
			fillMask.graphics.clear();
			fillMask.graphics.beginFill(0);
			fillMask.graphics.drawRect(9, 0, 195 * oldXp / G.user.getNextLvlXP(oldLvl), progressFill.height);
		}
		
		private function onMoreClicked():void {
			if(G.user.isGuest) {
				ErrorManager.showCustomError("Log in to access profile screen", ErrorManager.ERROR_GUEST_PROFILE_ACCESS);
				return;
			}
			parent.parent.addChild(new ProfileScreen());
			parent.parent.removeChild(parent);
		}
		
		public function updateValues(prevXP:int, prevLvl:int):void {
			delayTimer = 1;
			
			oldXp = prevXP;
			oldLvl = prevLvl;
			
			levelLabel.text = "R: " + G.user.rating;
			
			var fillMask:Sprite = (Sprite)(newProgressFill.mask);
			
			fillMask.graphics.clear();
			fillMask.graphics.beginFill(0);
			if(oldLvl != G.user.level)
				fillMask.graphics.drawRect(9, 0, 195, progressFill.height);
			else 
				fillMask.graphics.drawRect(9, 0, 195 * G.user.xp / G.user.getNextLvlXP(), progressFill.height);
			
			xpLabel.text = oldXp + " / " + G.user.getNextLvlXP(oldLvl) + " xp";
			
			if(!G.user.isGuest && G.host == G.HOST_KONGREGATE) {
				G.kongregate.stats.submit("LevelReached", G.user.level);
			}
		}
	}
}