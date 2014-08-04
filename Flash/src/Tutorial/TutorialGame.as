package Tutorial
{
	import Errors.ErrorManager;
	
	import Game.FightScreens.SingleThrowFightScreen;
	import Game.Game;
	import Game.Map;
	import Game.Player;
	import Game.Region;
	import Game.TutorialMessage;
	
	import Menu.ConfirmationDialog;
	
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import playerio.Message;
	
	
	public class TutorialGame extends Game
	{
		private const TUTORIAL_START:int = 0;
		private const TUTORIAL_INTRO_1:int = 1;
		private const TUTORIAL_INTRO_2:int = 2;
		private const TUTORIAL_INTRO_3:int = 3;
		private const TUTORIAL_CLAIMING_FIRST_REGION:int = 4;
		private const TUTORIAL_FIRST_REGION_CLAIMED:int = 5;
		private const TUTORIAL_WAITING_FOR_FIRST_ENDTURN:int = 6;
		private const TUTORIAL_FIRST_ENDTURN_PRESSED:int = 7;
		private const TUTORIAL_WAITING_FOR_FIRST_DISTRIBUTION:int = 8;
		private const TUTORIAL_FIRST_TUTOR_TURN_START:int = 9;
		private const TUTORIAL_FIRST_TUTOR_TURN_PROGRESS_1:int = 10;
		private const TUTORIAL_FIRST_TUTOR_TURN_PROGRESS_2:int = 11;
		private const TUTORIAL_FIRST_TUTOR_TURN_PROGRESS_3:int = 12;
		private const TUTORIAL_SECOND_TURN_START:int = 13;
		private const TUTORIAL_SECOND_TURN_EXPANDED:int = 14;
		private const TUTORIAL_SECOND_TURN_EXPANDING:int = 15;
		private const TUTORIAL_SECOND_TURN_REINFORCING:int = 16;
		private const TUTORIAL_SECOND_TUTOR_TURN_START:int = 17;
		private const TUTORIAL_SECOND_TUTOR_TURN_PROGRESS_1:int = 18;
		private const TUTORIAL_SECOND_TUTOR_TURN_PROGRESS_2:int = 19;
		private const TUTORIAL_THIRD_TURN_START:int = 20;
		private const TUTORIAL_THIRD_TURN_PROGRESS_1:int = 21;
		private const TUTORIAL_THIRD_TURN_PROGRESS_2:int = 22;
		private const TUTORIAL_THIRD_TURN_PROGRESS_3:int = 23;
		private const TUTORIAL_THIRD_TURN_PROGRESS_4:int = 24;
		private const TUTORIAL_THIRD_TURN_PROGRESS_5:int = 28;
		private const TUTORIAL_THIRD_TURN_PROGRESS_6:int = 29;
		private const TUTORIAL_THIRD_TUTOR_TURN_START:int = 25;
		private const TUTORIAL_THIRD_TUTOR_TURN_PROGRESS_1:int = 26;
		private const TUTORIAL_THIRD_TUTOR_TURN_PROGRESS_2:int = 27;
		private const TUTORIAL_FOURTH_TURN_START:int = 30;
		private const TUTORIAL_FOURTH_TURN_PROGRESS_1:int = 31;
		private const TUTORIAL_FOURTH_TURN_PROGRESS_2:int = 32;
		private const TUTORIAL_FOURTH_TURN_PROGRESS_3:int = 33;
		private const TUTORIAL_FOURTH_TURN_PROGRESS_4:int = 34
		private const TUTORIAL_FOURTH_TURN_PROGRESS_5:int = 35;
		private const TUTORIAL_FOURTH_TURN_PROGRESS_6:int = 36;
		private const TUTORIAL_FOURTH_TURN_PROGRESS_7:int = 37;
		private const TUTORIAL_FOURTH_TURN_PROGRESS_8:int = 38;
		
		private var tutorialProgress:int = 0;
		
		private var currentMessageNumber:int;
		private var currentMessageText:String;
		private var currentMessageRect:Rectangle;
		
		public function TutorialGame()
		{
			isTutorial = true;
			
			super(null, "");
			
			quit.setText("QUIT");
			quit.setCallback(onQuit);
			
			offerDrawButton.setText("HELP");
			offerDrawButton.visible = true;
			offerDrawButton.setCallback(onHelp);
			
			initGame();
			
			sidePanel.setBoostsVisible(false);
			sidePanel.removeToggleWideButton();
			
			removeChild(chatPanel);
			chatPanel = null;
			
			if(!G.user.isGuest)
				G.userConnection.send(MessageID.GAME_TUTORIAL_FINISHED);

			nextTutorialStep();
		}
		
		private function onHelp():void {
			showTutorialMessage(currentMessageNumber, currentMessageText, currentMessageRect, true);
		}
		
		private function onQuit():void {
			ErrorManager.errorSprite.addChild(new ConfirmationDialog("Are you sure you want to exit the tutorial?", "QUIT", onQuitConfirmed, "CANCEL", null));
		}
		
		private function onQuitConfirmed():void {
			exitGame();
		}
		
		protected function initGame():void {
			var index:int = 0;
			startType = 1;
			gameType = 1;
			troopsDist = 1;
			
			fightScreen = new SingleThrowFightScreen();
			
			players[0] = new Player(0, G.user.name, 0, 0, 0, G.user.level, 0, 0, 1, 1);
			players[1] = new Player(1, "Tutor", 1, 0, 1, 54, 0, 0, 1, 1);
			G.user.colorID = 0;
			G.user.ID = 0;
			
			var width:int = 23;
			var height:int = 17;
			var tiles:Array = new Array(
				 0, 0, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
				 0, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
				 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 9, 9, 0, 0,16,16,16,16,00,00,
				01,01,01,01,01,02,02,02,03,03,03,03,09,09,09,00,16,16,16,16,16,00,00,
				00,01,01,01,01,04,04,04,04,04,04,09,09,09,09,09,09,15,16,16,16,16,00,
				05,05,05,05,04,04,04,04,04,04,09,09,09,09,09,09,15,15,15,16,16,00,00,
				00,05,05,05,05,04,04,04,04,00,00,00,09,09,09,09,15,15,15,14,14,14,00,
				05,05,05,05,05,04,04,04,00,00,00,00,11,11,11,15,15,15,14,14,14,00,00,
				00,00,05,05,05,06,04,04,00,00,00,00,11,11,11,11,15,15,15,14,14,14,00,
				00,05,05,06,06,06,06,00,00,00,00,00,11,11,11,11,13,13,13,14,14,14,00,
				00,00,05,06,06,06,06,06,00,00,00,00,11,11,11,11,13,13,13,13,14,14,14,
				00,00,06,06,06,06,06,07,08,08,08,08,11,11,11,13,13,13,13,13,14,14,00,
				00,00,00,06,06,06,07,07,08,08,08,08,08,10,10,10,13,13,13,13,14,14,00,
				00,00,00,00,06,07,07,07,08,08,08,08,10,10,10,10,13,12,12,12,12,12,00,
				00,00,00,00,00,07,07,07,07,08,08,08,08,10,10,10,10,12,12,12,12,12,00,
				00,00,00,00,07,07,07,07,07,08,08,08,10,10,10,10,12,12,12,12,12,00,00,
				00,00,00,00,00,00,07,07,07,07,00,00,00,10,10,10,12,12,12,12,12,00,00
			);
			
			map = new Map(width, height, tiles);
			mapSprite.addChild(map);
			
			var mapMask:Sprite = new Sprite();
			mapMask.graphics.beginFill(0);
			mapMask.graphics.drawRect(5, 5, 550, 590);
			map.mask = mapMask;
			addChild(mapMask);
			
			var regionCount:int = 16;
			supposedRegionCount = regionCount;
			for(var i:int = 0; i < regionCount; ++i) {
				map.AddRegion(null, 0);
			}
			map.Finalize(G.user.background);
			map.setMapScale(1);
			
			addChild(fightScreen);
			
			sidePanel.setGameType(troopsDist, gameType);
			sidePanel.AddPlayers(players);
		}
		
		private function showTutorialMessage(index:int, text:String, rect:Rectangle, helpPressed:Boolean = false):void {
			currentMessageNumber = index;
			currentMessageText = text;
			currentMessageRect = rect;
			
			while(G.errorSprite.numChildren > 0) G.errorSprite.removeChildAt(G.errorSprite.numChildren - 1);
			
			G.errorSprite.addChild(new TutorialMessage(index, text, this, rect, helpPressed));			
		}
		
		public function nextTutorialStep():void {
			switch(tutorialProgress) {
				case TUTORIAL_START:
					showTutorialMessage(1, "Welcome to the Vortex Wars tutorial. You will learn all important things here. Press next to continue", null);
					tutorialProgress = TUTORIAL_INTRO_1;
					break;
				case TUTORIAL_INTRO_1:
					showTutorialMessage(2, "Here you can see the world map. It is divided into regions. To win the game, you need to eliminate all oponents by taking all their regions.", new Rectangle(5, 5, 550, 590));
					tutorialProgress = TUTORIAL_INTRO_2;
					break;
				case TUTORIAL_INTRO_2:
					showTutorialMessage(3, "Here is the list of players. You can see player's strength (how many region he has) on the left, his rank, name, what race is he playing with and how many units he has stored on the right.", new Rectangle(565, 46, 226, 116));
					tutorialProgress = TUTORIAL_INTRO_3;
					break;
				case TUTORIAL_INTRO_3:
					setActivePlayer(0, 1);
					startMyTurn();
					turnTimer.stop();
					
					map.GetRegion(13).startPulsing();
					
					showTutorialMessage(4, "Current player is highlighted with his color. Looks like it is your turn.\n\nSince we are playing \"Conquer\" mode, we have to choose our starting region first. Go ahead and claim your first region. Click on the flashing region to conquer it.", new Rectangle(565, 46, 226, 116));
					tutorialProgress = TUTORIAL_CLAIMING_FIRST_REGION;
					break;
				case TUTORIAL_FIRST_REGION_CLAIMED:
					showTutorialMessage(5, "Great! You have your first region and, as you can see, there is one unit guarding it. You need to have at least two units in region to be able to attack or expand. As we can't do anything else right now, press \"End Turn\" button in lower left corner to get reinforcements.", new Rectangle(326, 292, 98, 88));
					tutorialProgress = TUTORIAL_WAITING_FOR_FIRST_ENDTURN;
					break;
				case TUTORIAL_FIRST_ENDTURN_PRESSED:
					showTutorialMessage(6, "You will get reinforcements at the end of each turn. Their number is equal to the number of regions in your largest connected group. Remember to always connect all your regions to get the most reinforcements.\n\nSince we are playing \"Manual\" distribution mode you have to distribute them manually. Click on your region to assign your new unit there.", null);
					tutorialProgress = TUTORIAL_WAITING_FOR_FIRST_DISTRIBUTION;
					break;
				case TUTORIAL_FIRST_TUTOR_TURN_START:
					showTutorialMessage(7, "Now it is your enemy's turn, don't worry, it won't take long. In real game, all turns are limited by time so you don't have to wait indefinitely for others to finish their turns.", null);
					tutorialProgress = TUTORIAL_FIRST_TUTOR_TURN_PROGRESS_1;
					break;
				case TUTORIAL_FIRST_TUTOR_TURN_PROGRESS_1:
					var t:Timer = new Timer(2000, 1);
					t.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void {tutorialProgress = TUTORIAL_FIRST_TUTOR_TURN_PROGRESS_2; nextTutorialStep();});
					t.start();
					break;
				case TUTORIAL_FIRST_TUTOR_TURN_PROGRESS_2:
					conquerFirstRegion(1, 9);
					t = new Timer(2000, 1);
					t.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void {tutorialProgress = TUTORIAL_FIRST_TUTOR_TURN_PROGRESS_3; nextTutorialStep();});
					t.start();
					break;
				case TUTORIAL_FIRST_TUTOR_TURN_PROGRESS_3:
					t = new Timer(500, 1);
					t.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void {onEndTurn();});
					t.start();
					
					break;
				case TUTORIAL_SECOND_TURN_START:
					showTutorialMessage(8, "It is your turn once again, time to expand! Normaly, you would be able to expand to any neighboring region, but you are limited to the flashing region in this tutorial.\n\nClick your region to select it and then click neighboring region to expand there.\n\nDon't forget to press \"End Turn\" button when you are done.", null);
					tutorialProgress = TUTORIAL_SECOND_TURN_EXPANDING;
					map.GetRegion(11).startPulsing();
					break;
				case TUTORIAL_SECOND_TURN_EXPANDED:
					showTutorialMessage(9, "Since you have 2 regions now, you got 2 units to distribute.\n\nThis expansion brought you right to the enemy so put all units to the region that borders with him.", null);
					tutorialProgress = TUTORIAL_SECOND_TURN_REINFORCING;
					break;
				case TUTORIAL_SECOND_TUTOR_TURN_START:
					t = new Timer(2000, 1);
					t.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void {attackRegion(9, 4);});
					t.start();
					break;
				case TUTORIAL_SECOND_TUTOR_TURN_PROGRESS_1:
					t = new Timer(2000, 1);
					t.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void {onEndTurn()});
					t.start();
					break;
				case TUTORIAL_THIRD_TURN_START:
					showTutorialMessage(10, "It is time to attack! Your forces are equal so it will be tough fight. Attack enemy region now.\n\nAttacking works same way as expanding, click on your region with 3 units and then click on enemy region.", null);
					tutorialProgress = TUTORIAL_THIRD_TURN_PROGRESS_1;
					break;
				case TUTORIAL_THIRD_TURN_PROGRESS_2:
					showTutorialMessage(11, "Dang, that was close! Since we are playing \"Attrition\" mode, you hurt your oponent a bit.", null);
					tutorialProgress = TUTORIAL_THIRD_TURN_PROGRESS_3;
					break;
				case TUTORIAL_THIRD_TURN_PROGRESS_3:
					sidePanel.setBoostsVisible(true);
					showTutorialMessage(12, "At the beggining of each game, you will receive free attack and defense boosts. Their number depends on the size of the map you are playing.\n\nAttack boost increases chances you win your next attack, defense boost empowers your region to increase your chances of succesful defense. (See How to Play for more details)\n\nLet's use defense boost now to defend your border region. Click on defense boost and then click on the region that borders with enemy.", new Rectangle(598, 80, 150, 42));
					tutorialProgress = TUTORIAL_THIRD_TURN_PROGRESS_4;
					break;
				case TUTORIAL_THIRD_TURN_PROGRESS_5:
					sidePanel.setBoostsVisible(true);
					showTutorialMessage(13, "Good job! You should be safer now. End your turn and put all your new units to same region as before, you can't afford to lose that region.", null);
					tutorialProgress = TUTORIAL_THIRD_TURN_PROGRESS_6;
					break;
				case TUTORIAL_THIRD_TUTOR_TURN_START:
					t = new Timer(2000, 1);
					t.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void {attackRegion(9, 11);});
					t.start();
					break;
				case TUTORIAL_THIRD_TUTOR_TURN_PROGRESS_1:
					showTutorialMessage(14, "Even though your enemy was weaker, he got lucky and he won his first fight. You were saved by your defense boost that forced him to reroll and he lost this time.", null);
					tutorialProgress = TUTORIAL_THIRD_TUTOR_TURN_PROGRESS_2;
					break;
				case TUTORIAL_THIRD_TUTOR_TURN_PROGRESS_2:
					t = new Timer(2000, 1);
					t.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void {onEndTurn()});
					t.start();
					break;
				case TUTORIAL_FOURTH_TURN_START:
					showTutorialMessage(15, "You got lucky and didn't lose any units during that attack. Time to retaliate! Activate attack boost to make sure you will win this time.\n\nTo activate Attack boost, click on boost button and then attack enemy.", new Rectangle(598, 80, 150, 42));
					tutorialProgress = TUTORIAL_FOURTH_TURN_PROGRESS_1;
					break;
				case TUTORIAL_FOURTH_TURN_PROGRESS_4:
					showTutorialMessage(16, "Great! You still have 2 units remaining so go ahead and finish him.", null);
					tutorialProgress = TUTORIAL_FOURTH_TURN_PROGRESS_5;
					break;
				case TUTORIAL_FOURTH_TURN_PROGRESS_7:
					showTutorialMessage(17, "Conragtulations! You defeated your enemy and finished this tutorial. You are now ready to play against real people and find your own strategies. Good luck!", null);
					tutorialProgress = TUTORIAL_FOURTH_TURN_PROGRESS_8;
					break;
			}
		}
		
		protected override function regionClicked(region:Region):void {
			if(G.errorSprite.numChildren > 0) return;
			
			if(tutorialProgress == TUTORIAL_CLAIMING_FIRST_REGION) {
				if(region && region.ID == 13) {
					super.regionClicked(region);
				}
				return;
			}
			if(tutorialProgress == TUTORIAL_WAITING_FOR_FIRST_DISTRIBUTION) {
				if(region && region.ID == 13) {
					super.regionClicked(region);
				}
				return;
			}
			if(tutorialProgress == TUTORIAL_SECOND_TURN_EXPANDING) {
				if(region && (region.ID == 11 || region.ID == 13)) {
					super.regionClicked(region);
				}
				return;
			}
			if(tutorialProgress == TUTORIAL_SECOND_TURN_REINFORCING) {
				if(region && region.ID == 11) {
					super.regionClicked(region);
				}
				return;
			}
			if(tutorialProgress == TUTORIAL_THIRD_TURN_PROGRESS_1) {
				if(region && (region.ID == 11 || region.ID == 9)) {
					super.regionClicked(region);
				}
				return;
			}
			if(tutorialProgress == TUTORIAL_THIRD_TURN_PROGRESS_2) {
				if(region && region.ID == 11) {
					super.regionClicked(region);
				}
				return;
			}
			if(tutorialProgress == TUTORIAL_THIRD_TURN_PROGRESS_4) {
				if(region && region.ID == 11) {
					super.regionClicked(region);
				}
				return;
			}
			if(tutorialProgress == TUTORIAL_THIRD_TURN_PROGRESS_5) {
				if(region && region.ID == 11) {
					super.regionClicked(region);
				}
				return;
			}
			if(tutorialProgress == TUTORIAL_THIRD_TURN_PROGRESS_6) {
				if(region && region.ID == 11) {
					super.regionClicked(region);
				}
				return;
			}
			if(tutorialProgress == TUTORIAL_FOURTH_TURN_PROGRESS_2) {
				if(region && (region.ID == 11 || region.ID == 9)) {
					super.regionClicked(region);
				}
				return;
			}
			if(tutorialProgress == TUTORIAL_FOURTH_TURN_PROGRESS_5) {
				if(region && (region.ID == 9 || region.ID == 4)) {
					super.regionClicked(region);
				}
				return;
			}
		}
		
		protected override function conquerFirstRegion(playerID:int, regionID:int):void {
			handleInitialRegionConquer(playerID, regionID, 1);
			if(tutorialProgress == TUTORIAL_CLAIMING_FIRST_REGION) {
				tutorialProgress = TUTORIAL_FIRST_REGION_CLAIMED;
				nextTutorialStep();
			}
		}
		
		protected override function attackRegion(sourceID:int, targetID:int):void {
			if(tutorialProgress == TUTORIAL_SECOND_TURN_EXPANDING) {
				handleRegionConquered(13, 11, 1, 2);
				tutorialProgress = TUTORIAL_SECOND_TURN_EXPANDED;
				return;
			}
			if(tutorialProgress == TUTORIAL_SECOND_TUTOR_TURN_START) {
				handleRegionConquered(9, 4, 1, 2);
				tutorialProgress = TUTORIAL_SECOND_TUTOR_TURN_PROGRESS_1;
				var t:Timer = new Timer(1000, 1);
				t.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void {nextTutorialStep();});
				t.start();
				//nextTutorialStep();
			}
			if(tutorialProgress == TUTORIAL_THIRD_TURN_PROGRESS_1) {
				tutorialProgress = TUTORIAL_THIRD_TURN_PROGRESS_2;
				handleFightResult(null);
			}
			if(tutorialProgress == TUTORIAL_THIRD_TUTOR_TURN_START) {
				handleFightResult(null);
			}
			if(tutorialProgress == TUTORIAL_FOURTH_TURN_PROGRESS_2) {
				tutorialProgress = TUTORIAL_FOURTH_TURN_PROGRESS_3;
				handleFightResult(null);
			}
			if(tutorialProgress == TUTORIAL_FOURTH_TURN_PROGRESS_5) {
				tutorialProgress = TUTORIAL_FOURTH_TURN_PROGRESS_6;
				handleFightResult(null);
			}
			//connection.send(MessageID.GAME_ATTACK, sourceID, targetID);
		}
		
		protected override function handleFightResult(m:Message):void {
			if(tutorialProgress == TUTORIAL_THIRD_TURN_PROGRESS_2) {
				var sourceRegion:Region = map.GetRegion(11);
				var targetRegion:Region = map.GetRegion(9);
			
				var attackBoost:Boolean = false;
				var defenseBoost:Boolean = false;
			
				var throws:Array = new Array();
				throws.push(11);
				throws.push(12);
				
				fightScreen.startFight(sourceRegion, targetRegion, throws, attackBoost, defenseBoost, 1);
				bufferedFightResults = new Array(sourceRegion.ID, 1, // new dice count for source 
												 targetRegion.ID, 2, // and target regions
												 0, 2, // attacker ID and new strength 
												 1, 2, // defender ID and new strength 
												 0, 					// fight result (1 - win, 0 - loss)
												 0, 1, false);	// remaining attack boosts of attacker
			
				if(sourceRegion.owner && sourceRegion.owner.ID != G.user.ID) {
					// move map and highlight regions if we are not attacker
					sourceRegion.SetActive(true);
					targetRegion.SetActive(true);
				}
			}
			if(tutorialProgress == TUTORIAL_THIRD_TUTOR_TURN_START) {
				sourceRegion = map.GetRegion(9);
				targetRegion = map.GetRegion(11);
				
				attackBoost = false;
				defenseBoost = true;
				
				throws = new Array();
				throws.push(10);
				throws.push(7);
				throws.push(7);
				throws.push(12);
				
				fightScreen.startFight(sourceRegion, targetRegion, throws, attackBoost, defenseBoost, 2);
				bufferedFightResults = new Array(sourceRegion.ID, 1, // new dice count for source 
					targetRegion.ID, 3, // and target regions
					0, 2, // attacker ID and new strength 
					1, 2, // defender ID and new strength 
					0, 					// fight result (1 - win, 0 - loss)
					0, 1, false);	// remaining attack boosts of attacker
				
				if(sourceRegion.owner && sourceRegion.owner.ID != G.user.ID) {
					// move map and highlight regions if we are not attacker
					sourceRegion.SetActive(true);
					targetRegion.SetActive(true);
				}
				
				tutorialProgress = TUTORIAL_THIRD_TUTOR_TURN_PROGRESS_1;
			}
			if(tutorialProgress == TUTORIAL_FOURTH_TURN_PROGRESS_3) {
				sourceRegion = map.GetRegion(11);
				targetRegion = map.GetRegion(9);
				
				attackBoost = true;
				defenseBoost = false;
				
				throws = new Array();
				throws.push(12);
				throws.push(9);
				
				fightScreen.startFight(sourceRegion, targetRegion, throws, attackBoost, defenseBoost, 2);
				bufferedFightResults = new Array(sourceRegion.ID, 1, // new dice count for source 
					targetRegion.ID, 2, // and target regions
					0, 3, // attacker ID and new strength 
					1, 1, // defender ID and new strength 
					1, 					// fight result (1 - win, 0 - loss)
					0, 0, false);	// remaining attack boosts of attacker
				
				if(sourceRegion.owner && sourceRegion.owner.ID != G.user.ID) {
					// move map and highlight regions if we are not attacker
					sourceRegion.SetActive(true);
					targetRegion.SetActive(true);
				}
				
				tutorialProgress = TUTORIAL_FOURTH_TURN_PROGRESS_4;
			}
			if(tutorialProgress == TUTORIAL_FOURTH_TURN_PROGRESS_6) {
				sourceRegion = map.GetRegion(9);
				targetRegion = map.GetRegion(4);
				
				attackBoost = false;
				defenseBoost = false;
				
				throws = new Array();
				throws.push(4);
				throws.push(2);
				
				fightScreen.startFight(sourceRegion, targetRegion, throws, attackBoost, defenseBoost, 2);
				bufferedFightResults = new Array(sourceRegion.ID, 1, // new dice count for source 
					targetRegion.ID, 1, // and target regions
					0, 4, // attacker ID and new strength 
					1, 0, // defender ID and new strength 
					1, 					// fight result (1 - win, 0 - loss)
					0, 0, false);	// remaining attack boosts of attacker
				
				if(sourceRegion.owner && sourceRegion.owner.ID != G.user.ID) {
					// move map and highlight regions if we are not attacker
					sourceRegion.SetActive(true);
					targetRegion.SetActive(true);
				}
				
				tutorialProgress = TUTORIAL_FOURTH_TURN_PROGRESS_7;
			}
		}
		
		public override function fightFinished():void {
			super.fightFinished();
			
			if(tutorialProgress == TUTORIAL_THIRD_TURN_PROGRESS_2) {
				var t:Timer = new Timer(500, 1);
				t.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void { nextTutorialStep(); });
				t.start();
			}
			if(tutorialProgress == TUTORIAL_THIRD_TUTOR_TURN_PROGRESS_1) {
				t = new Timer(200, 1);
				t.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void { nextTutorialStep(); });
				t.start();
			}
			if(tutorialProgress == TUTORIAL_FOURTH_TURN_PROGRESS_4) {
				t = new Timer(500, 1);
				t.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void { nextTutorialStep(); });
				t.start();
			}
			if(tutorialProgress == TUTORIAL_FOURTH_TURN_PROGRESS_7) {
				t = new Timer(500, 1);
				t.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void { nextTutorialStep(); });
				t.start();
			}
			
			turnTimer.stop();
		}
		
		protected override function setDefenseBoost(r:Region):void {
			if(tutorialProgress == TUTORIAL_THIRD_TURN_PROGRESS_4) {
				sidePanel.setDefenseBoostsCount(0, 0, 0);
			
				var region:Region = map.GetRegion(11);
				region.setDefenseBoost(true);
			
				defenceBoostActivated = false;
				
				tutorialProgress = TUTORIAL_THIRD_TURN_PROGRESS_5;
					
				var t:Timer = new Timer(200, 1);
				t.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void { nextTutorialStep(); });
				t.start();
			}
		}
		
		protected override function onEndTurn():void {
			if( tutorialProgress != TUTORIAL_WAITING_FOR_FIRST_ENDTURN && 
				tutorialProgress != TUTORIAL_SECOND_TURN_EXPANDED &&
				tutorialProgress != TUTORIAL_FIRST_TUTOR_TURN_PROGRESS_3 &&
				tutorialProgress != TUTORIAL_SECOND_TUTOR_TURN_PROGRESS_1 &&
				tutorialProgress != TUTORIAL_THIRD_TURN_PROGRESS_6 &&
				tutorialProgress != TUTORIAL_THIRD_TUTOR_TURN_PROGRESS_2)
			{
				return;
			}

			if(tutorialProgress == TUTORIAL_WAITING_FOR_FIRST_ENDTURN) {
				tutorialProgress = TUTORIAL_FIRST_ENDTURN_PRESSED;
				
				nextTutorialStep();
			}
			if(tutorialProgress == TUTORIAL_SECOND_TURN_EXPANDED) {
				nextTutorialStep();
			}
			
			if(isMyTurn) {
				if(roundCounter == 1)
					startManualDistribution(1, 20);
				if(roundCounter == 2)
					startManualDistribution(2, 20);
				if(roundCounter == 3) 
					startManualDistribution(2, 20);
				
				turnTimer.stop();
			}
			else {
				if(roundCounter == 1) {
					startManualDistribution(1, 20);
					activePlayer.stackedDice = 1;
				}
				if(roundCounter == 2) {
					startManualDistribution(2, 20);
					activePlayer.stackedDice = 2;
				}
				if(roundCounter == 3) {
					startManualDistribution(2, 20);
					activePlayer.stackedDice = 2;
				}
				endManualDistribution();
			}
		} 
		
		protected override function endManualDistribution():void {
			turnTimer.stop();
			
			//connection.send(MessageID.GAME_DISTRIBUTION_RESULTS, b);
			newTroopsRegions.length = 0;
			manualDistribution = false;
			
			handlePostTurn(null);
			//isMyTurn = false;
		}
		
		protected override function handlePostTurn(m:Message):void {
			var newDice:int = 0;
			
			if(roundCounter == 1) {
				if(isMyTurn) {
					newDice += map.UpdateRegionDice(13, 2);
				}
				else {
					newDice += map.UpdateRegionDice(9, 2);
				}
			}
			if(roundCounter == 2) {
				if(isMyTurn) {
					newDice += map.UpdateRegionDice(11, 3);
				}
				else {
					newDice += map.UpdateRegionDice(9, 3);
				}
			}
			if(roundCounter == 3) {
				if(isMyTurn) {
					newDice += map.UpdateRegionDice(11, 3);
				}
				else {
					newDice += map.UpdateRegionDice(9, 3);
				}
			}

			if(isMyTurn) {
				turnCounter++;
			}
				
			map.deselectAllRegions();
			turnTimer.setEndTurnButtonVisible(false);
				
			autodistributingUnits = true;
			if(newDice == 0) {
				onDistributionCompleted(null);
			}
			else {
				var t:Timer = new Timer(newDice * 250, 1);
				t.addEventListener(TimerEvent.TIMER, onDistributionCompleted);
				t.start();
			}
			
			if(isMyTurn) {
				setActivePlayer(1, roundCounter);
				turnTimer.stop();
				//isMyTurn = false;
				
				if(roundCounter == 1) {
					tutorialProgress = TUTORIAL_FIRST_TUTOR_TURN_START;
					nextTutorialStep();
				}
				if(roundCounter == 2) {
					tutorialProgress = TUTORIAL_SECOND_TUTOR_TURN_START;
					nextTutorialStep();
				}
				if(roundCounter == 3) {
					tutorialProgress = TUTORIAL_THIRD_TUTOR_TURN_START;
					nextTutorialStep();
				}
			}
			else {
				setActivePlayer(0, roundCounter + 1);
				startMyTurn();
				turnTimer.stop();
				
				if(roundCounter == 2) {
					tutorialProgress = TUTORIAL_SECOND_TURN_START;
					nextTutorialStep();
				}
				if(roundCounter == 3) {
					tutorialProgress = TUTORIAL_THIRD_TURN_START;
					t = new Timer(500, 1);
					t.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void { nextTutorialStep(); });
					t.start();
				}
				if(roundCounter == 4) {
					tutorialProgress = TUTORIAL_FOURTH_TURN_START;
					t = new Timer(500, 1);
					t.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void { nextTutorialStep(); });
					t.start();
				}
			}
		}
		
		public override function attackBoostPressed():void {
			if(tutorialProgress == TUTORIAL_FOURTH_TURN_PROGRESS_1) {
				sidePanel.setAttackBoostActive(0, true);
				tutorialProgress = TUTORIAL_FOURTH_TURN_PROGRESS_2;
			}
		}
	}
}