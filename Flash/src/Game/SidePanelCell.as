package Game
{
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.LevelIcon;
	import Menu.Lobby.PlayerInfoPopup;
	import Menu.Tooltips.TextTooltip;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class SidePanelCell extends Sprite
	{
		private var longBg:Sprite;
		private var longMeBg:Sprite;
		private var longOffBg:Sprite;
		private var shortBg:Sprite;
		private var shortMeBg:Sprite;
		private var shortOffBg:Sprite;
		private var strength:TextField;
		private var rankSprite:LevelIcon;
		private var playerName:TextField;
		private var playerRating:TextField;
		private var logo:Sprite;
		private var army:TextField;
		private var drawFlag:Sprite;
		private var attackBoostButton:Button;
		private var defenceBoostButton:Button;
		private var attackBoostCount:TextField;
		private var defenceBoostCount:TextField
		private var muteButton:Button;
		private var playerKey:String;
		
		private var toolTipRace:TextTooltip;
		private var toolTipDraw:TextTooltip;
		private var toolTipAttackB:TextTooltip;
		private var toolTipDefenceB:TextTooltip;
		
		private var strengthWhiteTextFormat:TextFormat;
		private var nameWhiteTextFormat:TextFormat;
		private var armyTextFormat:TextFormat;

		private var boostTF:TextFormat, freeBoostTF:TextFormat;
		
		private var game:Game;
		private var isWide:Boolean;
		private var isMe:Boolean;
		
		public function SidePanelCell(player:Player, isWide:Boolean, game:Game)
		{
			super();
			
			this.game = game;
			this.isWide = isWide;
			
			strengthWhiteTextFormat = new TextFormat("Arial", 16, -1, true);
			strengthWhiteTextFormat.align = TextFormatAlign.CENTER;
			
			nameWhiteTextFormat = new TextFormat("Arial", 14, -1, true);
			nameWhiteTextFormat.align = TextFormatAlign.CENTER;
			
			armyTextFormat = new TextFormat("Arial", 11, -1, true);
			armyTextFormat.align = TextFormatAlign.CENTER;
			
			boostTF = new TextFormat("Arial", 12, 0xD2E4f9, true);
			freeBoostTF = new TextFormat("Arial", 12, -1, true);

			isMe = player.ID == G.user.ID;
			
			longBg = new Sprite();
			longBg.addChild(ResList.GetArtResource("gamePanel_player_long_" + player.colorID));
			longBg.x = 18;
			longBg.y = 55;
			addChild(longBg);
			longBg.visible = isWide;
			
			longMeBg = new Sprite();
			longMeBg.addChild(ResList.GetArtResource("gamePanel_player_long_me"));
			longMeBg.x = 18;
			longMeBg.y = 55;
			addChild(longMeBg);
			longMeBg.visible = isWide;
			
			longOffBg = new Sprite();
			longOffBg.addChild(ResList.GetArtResource("gamePanel_player_long_off"));
			longOffBg.x = 18;
			longOffBg.y = 55;
			addChild(longOffBg);
			longOffBg.visible = isWide;
			
			shortBg = new Sprite();
			shortBg.addChild(ResList.GetArtResource("gamePanel_player_short_" + player.colorID));
			shortBg.x = 121;
			shortBg.y = 55;
			addChild(shortBg);
			shortBg.visible = !isWide;
			
			shortMeBg = new Sprite();
			shortMeBg.addChild(ResList.GetArtResource("gamePanel_player_short_me"));
			shortMeBg.x = 121;
			shortMeBg.y = 55;
			addChild(shortMeBg);
			shortMeBg.visible = !isWide;
			
			shortOffBg = new Sprite();
			shortOffBg.addChild(ResList.GetArtResource("gamePanel_player_short_off"));
			shortOffBg.x = 121;
			shortOffBg.y = 55;
			addChild(shortOffBg);
			shortOffBg.visible = !isWide;
			
			strength = new TextField();
			strength.mouseEnabled = false;
			strength.defaultTextFormat = strengthWhiteTextFormat; 
			strength.text = "" + player.strength;
			strength.autoSize = TextFieldAutoSize.CENTER;
			strength.x = (isWide ? 32 : 135) + 14/2 - strength.width / 2;
			strength.y = 60 + 26 / 2 - strength.height / 2 + 1;
			addChild(strength);
			
			// don't show rank for guests
			if(player.level > 0) {
				rankSprite = new LevelIcon(player.level);
				rankSprite.x = 62;
				rankSprite.y =  59 + 30 / 2 - rankSprite.height / 2;
				addChild(rankSprite);
				rankSprite.visible = isWide;
			}
			
			var outline:GlowFilter = new GlowFilter(0x000000,1.0,2.0,2.0,10);
			outline.quality=BitmapFilterQuality.HIGH;
			
			playerName = new TextField();
			playerName.mouseEnabled = false;
			playerName.defaultTextFormat = nameWhiteTextFormat;
			playerName.text = player.name.toLocaleUpperCase();
			playerName.autoSize = TextFieldAutoSize.LEFT;
			playerName.x = 82;
			//name.y = 58 + 30 / 2 - name.height / 2 + 58*i;
			addChild(playerName);
			playerName.visible = isWide;
			playerName.filters = [outline];
			
			var tf:TextFormat = playerName.defaultTextFormat;
			while(playerName.width > 110) {
				tf.size = (int)(tf.size) - 1;
				playerName.setTextFormat(tf);
			}
			playerName.y = 58 + 30 / 2 - playerName.height / 2;
			playerName.defaultTextFormat = nameWhiteTextFormat;
			
			if(player.rating != 0) {
				playerRating = new TextField();
				playerRating.mouseEnabled = false;
				playerRating.defaultTextFormat = new TextFormat("Arial", 10, -1, true);
				playerRating.text = "R: " + player.rating;
				playerRating.autoSize = TextFieldAutoSize.LEFT;
				playerRating.x = 82;
				//name.y = 58 + 30 / 2 - name.height / 2 + 58*i;
				addChild(playerRating);
				playerRating.visible = isWide;
				playerRating.filters = [outline];
				playerRating.y = 73 + 15 / 2 - playerName.height / 2 + 3;
				
				playerName.y = 58 + 15 / 2 - playerName.height / 2 + 2;
			}
			
			logo = new Sprite();
			logo.addChild(new Bitmap(player.race.symbolSmall.bitmapData.clone()));
			logo.x = 186;
			logo.y = 45;
			addChild(logo);
			
			toolTipRace = new TextTooltip(player.race.name + "\n" + player.race.bonusDesc, logo);
			
			army = new TextField();
			army.defaultTextFormat = armyTextFormat;
			army.text = "0";
			army.autoSize = TextFieldAutoSize.CENTER;
			army.x = logo.x + logo.width / 2 - army.width / 2;
			army.y = logo.y + logo.height / 2 - army.height / 2 - 2;
			army.mouseEnabled = false;
			addChild(army);
			
			drawFlag = new Sprite();
			drawFlag.addChild(ResList.GetArtResource("draw_flag"));
			if(isWide)
				drawFlag.x = longOffBg.x + 2;
			else
				drawFlag.x = shortOffBg.x + 2;
			drawFlag.y = longOffBg.y;
			addChild(drawFlag);
			drawFlag.visible = false;
			
			if(game.boostsEnabled || game.isTutorial) {
				attackBoostButton = new Button(null, player.ID == G.user.ID ? attackBoostPressed : null, ResList.GetArtResource("boost_attack_button"));
				if(isWide)
					attackBoostButton.x = longBg.x + 50;
				else
					attackBoostButton.x = shortBg.x;
				attackBoostButton.y = longBg.y + 35;
				addChild(attackBoostButton);
				
				attackBoostCount = new TextField();
				if(G.host == G.HOST_PLAYSMART) {
					attackBoostCount.text = player.freeAttackBoosts + "";
					attackBoostCount.setTextFormat(boostTF, 0, 1);
				}
				else {
					attackBoostCount.text = player.freeAttackBoosts + "+" + player.attackBoosts;
					attackBoostCount.setTextFormat(freeBoostTF, 0, 1);
					attackBoostCount.setTextFormat(boostTF, 1, 3);
				}
				attackBoostCount.mouseEnabled = false;
				attackBoostCount.x = 20;
				attackBoostCount.y = 1;
				attackBoostButton.addChild(attackBoostCount);
				
				toolTipAttackB = new TextTooltip("Attack boost" + (player.ID == G.user.ID ? ", click to activate" : ""), attackBoostButton);
				
				defenceBoostButton = new Button(null, player.ID == G.user.ID ? defenseBoostPressed : null, ResList.GetArtResource("boost_defense_button"));
				if(isWide)
					defenceBoostButton.x = longBg.x + 100;
				else 
					defenceBoostButton.x = shortBg.x + 50;
				defenceBoostButton.y = longBg.y + 35;
				addChild(defenceBoostButton);
				
				defenceBoostCount = new TextField();
				//boostCount.defaultTextFormat = boostTF;
				if(G.host == G.HOST_PLAYSMART) {
					defenceBoostCount.text = player.freeDefenseBoosts + "";
					defenceBoostCount.setTextFormat(boostTF, 0, 1);
				}
				else {
					defenceBoostCount.text = player.freeDefenseBoosts + "+" + player.defenseBoosts;
					defenceBoostCount.setTextFormat(freeBoostTF, 0, 1);
					defenceBoostCount.setTextFormat(boostTF, 1, 3);
				}
				defenceBoostCount.mouseEnabled = false;
				defenceBoostCount.x = 20;
				defenceBoostCount.y = 1;
				defenceBoostButton.addChild(defenceBoostCount);
				
				toolTipDefenceB = new TextTooltip("Defense boost" + (player.ID == G.user.ID ? ", click to place on region" : ""), defenceBoostButton);
			}
			
			toolTipDraw = new TextTooltip("This player offered draw", drawFlag);
			
			if(player.name != G.user.name) {
				muteButton = new Button(null, onMutePressed, G.user.isPlayerMuted(player.name) ? ResList.GetArtResource("mute_on") : ResList.GetArtResource("mute_off"));
				if(isWide)
					muteButton.x = longBg.x - 1;
				else 
					muteButton.x = shortBg.x - 1;
				muteButton.y = longBg.y + 25;
				addChild(muteButton);
				
				var tooltip:TextTooltip = new TextTooltip("Mute player", muteButton);
				
				if(player.playerKey != "") {
					playerKey = player.playerKey;
					//playerKeys[i] = player.playerKey;
					longBg.addEventListener(MouseEvent.CLICK, onMouseClicked, false, 0, true);
					longOffBg.addEventListener(MouseEvent.CLICK, onMouseClicked, false, 0, true);
					shortBg.addEventListener(MouseEvent.CLICK, onMouseClicked, false, 0, true);
					shortOffBg.addEventListener(MouseEvent.CLICK, onMouseClicked, false, 0, true);
					longBg.useHandCursor = true;
					longBg.buttonMode = true;
					shortBg.useHandCursor = true;
					shortBg.buttonMode = true;
					longOffBg.useHandCursor = true;
					longOffBg.buttonMode = true;
					shortOffBg.useHandCursor = true;
					shortOffBg.buttonMode = true;
				}
			}
			
			//addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
		}

		/*private function onRemovedFromStage(event:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			//Bitmap(rankSprite.getChildAt(0)).bitmapData.dispose();
		}*/
		
		private function onMutePressed(button:Button):void {
			button.setImage(G.user.toggleMute(playerName.text) ? "mute_on" : "mute_off");
		}
		
		public function setWide(isWide:Boolean):void {
			this.isWide = isWide;
			
			longBg.visible = isWide;
			shortBg.visible = !isWide;
			strength.x = (isWide ? 32 : 135) + 14/2 - strength.width / 2;
			if(rankSprite) 
				rankSprite.visible = isWide;
			playerName.visible = isWide;
			if(playerRating)
				playerRating.visible = isWide;
			
			if(isWide) {
				longMeBg.visible = shortMeBg.visible;
				shortMeBg.visible = false;
				longOffBg.visible = shortOffBg.visible;
				shortOffBg.visible = false;
				drawFlag.x = longOffBg.x + 2;
				if(attackBoostButton) {
					attackBoostButton.x = longOffBg.x + 50;
					defenceBoostButton.x = longOffBg.x + 100;
				}
				if(muteButton) {
					muteButton.x = longOffBg.x - 1;
				}
			}
			else {
				shortMeBg.visible = longMeBg.visible;
				longMeBg.visible = false;
				shortOffBg.visible = longOffBg.visible;
				longOffBg.visible = false;
				drawFlag.x = shortOffBg.x + 2;
				if(attackBoostButton) {
					attackBoostButton.x = shortOffBg.x;
					defenceBoostButton.x = shortOffBg.x + 50;
				}
				if(muteButton) {
					muteButton.x = shortOffBg.x - 1;
				}
			}
		}
		
		private function attackBoostPressed(button:Button):void {
			game.attackBoostPressed();
		}
		
		private function defenseBoostPressed(button:Button):void {
			game.defenseBoostPressed();
		}
		
		private function onMouseClicked(event:MouseEvent):void {
			if(playerKey != "" && !G.user.isGuest) {
				var pos:Point = new Point(event.target.width / 2 - 136 / 2, 0);
				pos = event.target.localToGlobal(pos);
				G.errorSprite.addChild(new PlayerInfoPopup(playerKey, pos.x, pos.y + event.target.height - 6, event.target.height, null));
			}
		}
		
		public function setActive(active:Boolean):void {
			longOffBg.visible = false;
			shortOffBg.visible = false;
			longMeBg.visible = false;
			shortMeBg.visible = false;
			if(!active) {
				if(isWide) {
					if(isMe) {
						longMeBg.visible = true;
					}
					else {
						longOffBg.visible = true;
					}
				}
				else {
					if(isMe) {
						shortMeBg.visible = true;
					}
					else {
						shortOffBg.visible = true;
					}
				}
			}

			if(attackBoostButton)
				attackBoostButton.setImage("boost_attack_button");
			if(defenceBoostButton)
				defenceBoostButton.setImage("boost_defense_button");
		}
		
		public function setAttackBoostActive(active:Boolean):void {
			if(attackBoostButton)
				attackBoostButton.setImage("boost_attack_button" + (active ? "_active" : ""));
		}
		
		public function setDefenseBoostActive(active:Boolean):void {
			if(defenceBoostButton)
				defenceBoostButton.setImage("boost_defense_button" + (active ? "_active" : ""));
		}
		
		public function setAttackBoostsCount(count:int, freeCount:int):void {
			if(attackBoostCount) {
				if(G.host == G.HOST_PLAYSMART) {
					attackBoostCount.text = freeCount + "";
					attackBoostCount.setTextFormat(boostTF, 0, 1);
				}
				else {
					attackBoostCount.text = freeCount + "+" + count;
					attackBoostCount.setTextFormat(freeBoostTF, 0, 1);
					attackBoostCount.setTextFormat(boostTF, 1, 3);
				}
			}
		}
		
		public function setDefenseBoostsCount(count:int, freeCount:int):void {
			if(defenceBoostCount) {
				if(G.host == G.HOST_PLAYSMART) {
					defenceBoostCount.text = freeCount + "";
					defenceBoostCount.setTextFormat(boostTF, 0, 1);
				}
				else {
					defenceBoostCount.text = freeCount + "+" + count;
					defenceBoostCount.setTextFormat(freeBoostTF, 0, 1);
					defenceBoostCount.setTextFormat(boostTF, 1, 3);
				}
			}
		}
		
		public function setRegionSize(str:int):void {
			if(strength)
				strength.text = "" + str;
		}
		
		public function setArmySize(armyCount:int):void {
			if(army)
				army.text = "" + armyCount;
		}
		
		public function setOfferedDraw(offered:Boolean):void {
			drawFlag.visible = offered;
		}
		
		public function removePlayer():void {
			if(playerName) {
				playerName.text = "DISCONNECTED";
				playerName.y = 58 + 30 / 2 - playerName.height / 2;
				if(playerRating)
					playerRating.visible = false;
			}
			
			try {
				//removeChild(strength);
				//removeChild(army);
				//removeChild(logo);
				//removeChild(drawFlag);
				strength.visible = false;
				army.visible = false;
				logo.visible = false;
				drawFlag.visible = false;
				
				playerKey = "";
				
				if(rankSprite) {
					rankSprite.setLevel(0);
				}
				if(toolTipRace)
					toolTipRace.remove();
				
				if(toolTipDraw)
					toolTipDraw.remove();
				
				if(toolTipAttackB)
					toolTipAttackB.remove();
				if(toolTipDefenceB)
					toolTipDefenceB.remove();
				
				if(attackBoostButton)
				//	removeChild(attackBoostButton);
					attackBoostButton.visible = false;
				if(defenceBoostButton)
				//	removeChild(defenceBoostButton);
					defenceBoostButton.visible = false;
				
				if(muteButton) {
					//removeChild(muteButton);
					muteButton.visible = false;
				}
			}
			catch(errObject:Error) {
				G.client.errorLog.writeError("SidePanel::removePlayer", errObject.message, "", null);
			}
		}
		
		public function setBoostsVisible(v:Boolean):void {
			if(attackBoostButton)
				attackBoostButton.visible = v;
			if(defenceBoostButton)
				defenceBoostButton.visible = v;
		}
	}
}