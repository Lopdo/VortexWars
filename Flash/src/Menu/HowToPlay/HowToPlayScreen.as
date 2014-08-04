package Menu.HowToPlay
{
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.MainMenu.MainMenu;
	import Menu.MainMenu.MenuShortcutsPanel;
	import Menu.MenuSelector;
	import Menu.NinePatchSprite;
	
	import Tutorial.TutorialGame;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class HowToPlayScreen extends Sprite
	{
		private var categoryButtons:Array = new Array();
		private var pageSelector:MenuSelector;
		
		private var howToText:TextField;
		private var howToImage:Sprite;
		
		private var currentCategory:int = 0;
		
		public function HowToPlayScreen()
		{
			super();
			
			graphics.beginBitmapFill(ResList.GetArtResource("bg").bitmapData);
			graphics.drawRect(0, 0, 800, 600);
			
			var categoriesBg:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 295, 424);
			categoriesBg.x = 8;
			categoriesBg.y = 60;
			addChild(categoriesBg);
			
			var tf:TextFormat = new TextFormat();
			tf.font = "Arial";
			tf.bold = true;
			tf.size = 18;
			tf.color = -1;
			tf.align = TextFormatAlign.LEFT;
			
			var title:TextField = new TextField();
			title.text = "CATEGORIES";
			title.setTextFormat(tf);
			title.width = categoriesBg.width;
			title.autoSize = TextFieldAutoSize.CENTER;
			title.y = 12;
			categoriesBg.addChild(title);
			
			var button:ButtonHex = new ButtonHex("BASICS", function():void { onCategoryClicked(0); }, "button_medium_gray", 24, -1, 250);
			button.x = categoriesBg.width / 2 - button.width / 2;
			button.y = 50;
			categoriesBg.addChild(button);
			categoryButtons[0] = button;
			
			button = new ButtonHex("GAME MODES", function():void { onCategoryClicked(1); }, "button_medium_gray", 24, -1, 250);
			button.x = categoriesBg.width / 2 - button.width / 2;
			button.y = 50 + 62;
			categoriesBg.addChild(button);
			categoryButtons[1] = button;
			
			button = new ButtonHex("DISTRIBUTIONS", function():void { onCategoryClicked(2); }, "button_medium_gray", 24, -1, 250);
			button.x = categoriesBg.width / 2 - button.width / 2;
			button.y = 50 + 124;
			categoriesBg.addChild(button);
			categoryButtons[2] = button;
			
			button = new ButtonHex("START TYPES", function():void { onCategoryClicked(3); }, "button_medium_gray", 24, -1, 250);
			button.x = categoriesBg.width / 2 - button.width / 2;
			button.y = 50 + 186;
			categoriesBg.addChild(button);
			categoryButtons[3] = button;
			
			button = new ButtonHex("BOOSTS", function():void { onCategoryClicked(4); }, "button_medium_gray", 24, -1, 250);
			button.x = categoriesBg.width / 2 - button.width / 2;
			button.y = 50 + 248;
			categoriesBg.addChild(button);
			categoryButtons[4] = button;
			
			var bx:int = button.x;
			
			button = new ButtonHex("TUTORIAL", onTutorialClicked, "button_small_gray");
			button.x = bx;
			button.y = 50 + 320;
			categoriesBg.addChild(button);
			
			var contentBg:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 470, 424);
			contentBg.x = 320;
			contentBg.y = 60;
			addChild(contentBg);
			
			pageSelector = new MenuSelector(160, 34);
			pageSelector.callback = onPageChanged;
			pageSelector.x = contentBg.width / 2 - pageSelector.width / 2;
			pageSelector.y = 10;
			contentBg.addChild(pageSelector);
			
			tf.size = 14;
			
			howToText = new TextField();
			howToText.defaultTextFormat = tf;
			howToText.text = " ";
			howToText.width = contentBg.width - 40;
			howToText.x = 20;
			howToText.y = 50;
			howToText.autoSize = TextFieldAutoSize.LEFT;
			howToText.multiline = true;
			howToText.wordWrap = true;
			contentBg.addChild(howToText);
			
			howToImage = new Sprite();
			contentBg.addChild(howToImage);
			
			addChild(new MenuShortcutsPanel(onBack));
			
			onCategoryClicked(0);
			
			if(!G.user.isGuest) {
				G.userConnection.send(MessageID.ACHIEVEMENT_HOWTOPLAY_VISITED);
			}
			
			G.gatracker.trackPageview("/howToPlay");
		}
		
		private function onCategoryClicked(catIndex:int):void {
			for(var i:int = 0; i < 5; i++) {
				categoryButtons[i].setImage(i == catIndex ? "button_medium_gold" : "button_medium_gray");
			}
			
			currentCategory = catIndex;
			
			pageSelector.removeAllItems();
			
			switch(catIndex) {
				case 0:
					for(i = 0; i < 5; i++)
						pageSelector.AddItem((i + 1) + " / 5", i);
					break;
				case 1:
					for(i = 0; i < 4; i++)
						pageSelector.AddItem((i + 1) + " / 4", i);
					break;
				case 2:
					for(i = 0; i < 3; i++)
						pageSelector.AddItem((i + 1) + " / 3", i);
					break;
				case 3:
					for(i = 0; i < 2; i++)
						pageSelector.AddItem((i + 1) + " / 2", i);
					break;
				case 4:
					for(i = 0; i < 3; i++)
						pageSelector.AddItem((i + 1) + " / 3", i);
					break;
			}
			
			pageSelector.SetActiveItem(0);
		}
		
		private function onPageChanged(index:int):void {
			while(howToImage.numChildren > 0) howToImage.removeChildAt(howToImage.numChildren - 1);
			
			switch(currentCategory) {
				case 0:
				{
					switch(index) {
						case 0:
							howToText.text = "The goal of the game is to conquer all regions. Each region can have an owner and an army.\n - The owner is represented by color (a gray region doesn't \n   have an owner).\n - Army size is represented by the number in the center of \n   the region's symbol.";
							break;
						case 1:
							howToText.text = "To conquer a region, you need to attack it first. You can attack only from a region that has an army size of at least TWO and you can attack only its neighboring regions.";
							break;
						case 2: 
							howToText.text = "Attacking consists of dice rolls (see GAME MODES tab for more details). You will capture a region only if you win the attack.\nAttacker is always on the left side of fight panel.";
							break;
						case 3: 
							howToText.text = "When you run out of moves, you can press the \"END TURN\" button. You will get some reinforcements based on your largest connected cluster of regions. Distribution of those reinforcements is based on DISTRIBUTION type.";
							break;
						case 4: 
							howToText.text = "You can see each player's strength and reserve army. Strength is equal to his largest connected cluster of regions and determines the number of reinforcements he will receive. If he gets more units than he can use (all regions are full), leftovers will be stored in his army stack. He can use them later.";
							break;
					}
				}
				break;
				case 1:
				{
					switch(index) {
						case 0:
							howToText.text = "There are three fight modes.\nFirst mode is HARDCORE (HC) which is basically winner takes all. When attacker loses, he loses all of his attacking dice (only one will remain on region he was attacking from). When attacker wins, he keeps all his dice (one will be left behind on original region).";
							break;
						case 1:
							howToText.text = "ATTRITION (Att) - similar to hardcore, but attacker can lose some dice even if he wins. Same applies to defender, even if attack fails, it can weaken defender. Exact amount of lost dice is determined by dice throws. In short, better your throws, less dice you lose.";
							break;
						case 2: 
							howToText.text = "ONE ON ONE (1v1). In this mode, each die fights individually. One die is taken from attacker and defender, they roll for attack, and winner can keep his die. Fist to lose all dice loses fight. Remaining dice determine resulting army size in regions.\nThis mode is no longer supported.";
							break;
						case 3: 
							howToText.text = "ONE ON ONE QUICK (1v1q). Same as ONE ON ONE, but all battles are calculated instantly to save time and only results are displayed. Unlike in other modes, fight results in this mode show number of armies destroyed on each side.";
							break;
					}
				}
				break;
				case 2:
				{
					switch(index) {
						case 0:
							howToText.text = "There are 3 army distribution modes. First mode is RANDOM. At the end of turn, armies are distributed randomly across all your regions that are not full yet. If all regions are full, remaining armies are stacked in your army reserve and can be used in next turn if there is enough space.";
							break;
						case 1:
							howToText.text = "Second mode is BORDERS. It works similar to RANDOM, but regions that borders with enemies are preferred (and from those, living enemies are preferred). Inland regions begin to fill after all border regions are full.";
							break;
						case 2: 
							howToText.text = "Last distribution mode is MANUAL. You have 12-20 seconds to manually distribute your reinforcements at the end of your turn. You can use 'SHIFT' button to fill region to the max with single click.";
							break;
					}
				}
					break;
				case 3:
				{
					switch(index) {
						case 0:
							howToText.text = "There are two options how you can start your game. First is FULL MAP. Each player gets equal amount of regions and army, randomly distributed. You can start fighting right away!";
							break;
						case 1:
							howToText.text = "Second option is CONQUER. Game starts with empty map and each player needs to pick his starting region in his first turn. Because of this, players are weaker from beginning, so it is advisable to conquer as much empty regions before attacking as possible to get some strength.";
							break;
					}
				}
				break;
				case 4:
				{
					switch(index) {
						case 0:
							howToText.text = "Boosts provide higher chance of winning for your next battle. There are 2 types of boosts at the moment, attack and defense. You will receive certain number of free boosts (of both kinds) at the beginning of each game. You will be also able to use same amount of boosts from your stock, thus effectively double your available boost count. Number of boosts you can use in one game depends on number of regions map has, more regions means more boosts. Free boosts are replenished at the beginning of every game, but when you use your own boost, it is lost forever. You can restock your boosts in shop anytime.";
							break;
						case 1:
							howToText.text = "Attack boost (shortcut A) is enabled  by clicking on attack boost icon before you attack. Attack boost is active only for next attack. If you attack with attack boost enabled and you lose, dice re-roll, thus giving you higher chance to win. Boost is consumed after battle even if you won on first try.";
							break;
						case 2:
							howToText.text = "Defense boost (shortcut D) can be placed on any of your regions. To place defense boost, click on defense boost icon and than on any terriroy under your control. Defense boost is active until enemy attack on its region. If enemy attacks on you region with defense boost dice will re-roll and boost will be destroyed";
							break;
					}
				}
			}
			
			if(currentCategory != 1 && currentCategory != 2 && currentCategory != 4) {
				howToImage.addChild(ResList.GetArtResource("howToPlay_" + currentCategory + "_" + index));
				howToImage.x = 470 / 2 - howToImage.width / 2;
				howToImage.y = howToText.y + howToText.height + (howToImage.parent.height - (howToText.y + howToText.height)) / 2 - howToImage.height / 2;
			}
		}
		
		private function onBack():void {
			parent.addChild(new MainMenu());
			parent.removeChild(this);
		}
		
		private function onTutorialClicked():void {
			parent.addChild(new TutorialGame());
			parent.removeChild(this);
		}
	}
}