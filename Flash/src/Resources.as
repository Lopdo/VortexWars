package
{
	import IreUtils.ResList;
	
	import flash.display.Bitmap;
	import flash.media.Sound;
	
	public class Resources
	{
		[Embed(source="../res/images/9patch_editText_topLeft.png")]		private var patch_editText_topLeft:Class;
		[Embed(source="../res/images/9patch_editText_top.png")]			private var patch_editText_top:Class;
		[Embed(source="../res/images/9patch_editText_topRight.png")]		private var patch_editText_topRight:Class;
		[Embed(source="../res/images/9patch_editText_left.png")]			private var patch_editText_left:Class;
		[Embed(source="../res/images/9patch_editText_right.png")]			private var patch_editText_right:Class;
		[Embed(source="../res/images/9patch_editText_bottomLeft.png")]		private var patch_editText_bottomLeft:Class;
		[Embed(source="../res/images/9patch_editText_bottomRight.png")]	private var patch_editText_bottomRight:Class;
		[Embed(source="../res/images/9patch_editText_bottom.png")]			private var patch_editText_bottom:Class;
		[Embed(source="../res/images/9patch_editText_center.png")]			private var patch_editText_center:Class;
		
		[Embed(source="../res/images/9patch_popup_topLeft.png")]		private var patch_popup_topLeft:Class;
		[Embed(source="../res/images/9patch_popup_top.png")]			private var patch_popup_top:Class;
		[Embed(source="../res/images/9patch_popup_topRight.png")]		private var patch_popup_topRight:Class;
		[Embed(source="../res/images/9patch_popup_left.png")]			private var patch_popup_left:Class;
		[Embed(source="../res/images/9patch_popup_right.png")]			private var patch_popup_right:Class;
		[Embed(source="../res/images/9patch_popup_bottomLeft.png")]	private var patch_popup_bottomLeft:Class;
		[Embed(source="../res/images/9patch_popup_bottomRight.png")]	private var patch_popup_bottomRight:Class;
		[Embed(source="../res/images/9patch_popup_bottom.png")]		private var patch_popup_bottom:Class;
		[Embed(source="../res/images/9patch_popup_center.png")]		private var patch_popup_center:Class;
		
		[Embed(source="../res/images/9patch_context_topLeft.png")]		private var patch_context_topLeft:Class;
		[Embed(source="../res/images/9patch_context_top.png")]			private var patch_context_top:Class;
		[Embed(source="../res/images/9patch_context_topRight.png")]	private var patch_context_topRight:Class;
		[Embed(source="../res/images/9patch_context_left.png")]		private var patch_context_left:Class;
		[Embed(source="../res/images/9patch_context_right.png")]		private var patch_context_right:Class;
		[Embed(source="../res/images/9patch_context_bottomLeft.png")]	private var patch_context_bottomLeft:Class;
		[Embed(source="../res/images/9patch_context_bottomRight.png")]	private var patch_context_bottomRight:Class;
		[Embed(source="../res/images/9patch_context_bottom.png")]		private var patch_context_bottom:Class;
		[Embed(source="../res/images/9patch_context_center.png")]		private var patch_context_center:Class;
		
		[Embed(source="../res/images/9patch_transparent_panel_topLeft.png")]		private var patch_transparent_panel_topLeft:Class;
		[Embed(source="../res/images/9patch_transparent_panel_top.png")]			private var patch_transparent_panel_top:Class;
		[Embed(source="../res/images/9patch_transparent_panel_topRight.png")]		private var patch_transparent_panel_topRight:Class;
		[Embed(source="../res/images/9patch_transparent_panel_left.png")]			private var patch_transparent_panel_left:Class;
		[Embed(source="../res/images/9patch_transparent_panel_right.png")]			private var patch_transparent_panel_right:Class;
		[Embed(source="../res/images/9patch_transparent_panel_bottomLeft.png")]	private var patch_transparent_panel_bottomLeft:Class;
		[Embed(source="../res/images/9patch_transparent_panel_bottomRight.png")]	private var patch_transparent_panel_bottomRight:Class;
		[Embed(source="../res/images/9patch_transparent_panel_bottom.png")]		private var patch_transparent_panel_bottom:Class;
		[Embed(source="../res/images/9patch_transparent_panel_center.png")]		private var patch_transparent_panel_center:Class;
		
		[Embed(source="../res/images/9patch_emboss_panel_topLeft.png")]		private var patch_emboss_panel_topLeft:Class;
		[Embed(source="../res/images/9patch_emboss_panel_top.png")]			private var patch_emboss_panel_top:Class;
		[Embed(source="../res/images/9patch_emboss_panel_topRight.png")]		private var patch_emboss_panel_topRight:Class;
		[Embed(source="../res/images/9patch_emboss_panel_left.png")]			private var patch_emboss_panel_left:Class;
		[Embed(source="../res/images/9patch_emboss_panel_right.png")]			private var patch_emboss_panel_right:Class;
		[Embed(source="../res/images/9patch_emboss_panel_bottomLeft.png")]		private var patch_emboss_panel_bottomLeft:Class;
		[Embed(source="../res/images/9patch_emboss_panel_bottomRight.png")]	private var patch_emboss_panel_bottomRight:Class;
		[Embed(source="../res/images/9patch_emboss_panel_bottom.png")]			private var patch_emboss_panel_bottom:Class;
		[Embed(source="../res/images/9patch_emboss_panel_center.png")]			private var patch_emboss_panel_center:Class;
		
		[Embed(source="../res/images/logo_gray.png")]		private var logo_gray:Class;
		
		[Embed(source="../res/images/button_side_hide.png")]		private var button_side_hide:Class;
		[Embed(source="../res/images/button_small_gray_mid.png")]	private var button_small_gray_mid:Class;
		[Embed(source="../res/images/button_small_gray_end.png")]	private var button_small_gray_end:Class;
		[Embed(source="../res/images/button_small_gold_mid.png")]	private var button_small_gold_mid:Class;
		[Embed(source="../res/images/button_small_gold_end.png")]	private var button_small_gold_end:Class;
		[Embed(source="../res/images/button_small_blue_mid.png")]	private var button_small_blue_mid:Class;
		[Embed(source="../res/images/button_small_blue_end.png")]	private var button_small_blue_end:Class;
		
		[Embed(source="../res/images/button_medium_gray_mid.png")]	private var button_medium_gray_mid:Class;
		[Embed(source="../res/images/button_medium_gray_end.png")]	private var button_medium_gray_end:Class;
		[Embed(source="../res/images/button_medium_gold_mid.png")]	private var button_medium_gold_mid:Class;
		[Embed(source="../res/images/button_medium_gold_end.png")]	private var button_medium_gold_end:Class;
		
		[Embed(source="../res/images/button_big_gray_mid.png")]	private var button_big_gray_mid:Class;
		[Embed(source="../res/images/button_big_gray_end.png")]	private var button_big_gray_end:Class;
		[Embed(source="../res/images/button_big_gold_mid.png")]	private var button_big_gold_mid:Class;
		[Embed(source="../res/images/button_big_gold_end.png")]	private var button_big_gold_end:Class;
		
		[Embed(source="../res/images/button_map_report.png")]		private var button_map_report:Class;
		
		[Embed(source="../res/images/bg.png")] 					private var bg:Class;
		
		[Embed(source="../res/images/level_progress_bg.png")] 			private var level_progress_bg:Class;
		[Embed(source="../res/images/level_progress_fill_blue.png")] 	private var level_progress_fill_blue:Class;
		[Embed(source="../res/images/level_progress_fill_yellow.png")]	private var level_progress_fill_yellow:Class;
		
		[Embed(source="../res/images/game_chatBg.png")]			private var game_chatBg:Class;
		[Embed(source="../res/images/game_chatHistory.png")]		private var game_chatHistory:Class;
		[Embed(source="../res/images/game_chatHistoryDown.png")]	private var game_chatHistoryDown:Class;
		[Embed(source="../res/images/game_chatUp.png")]			private var game_chatUp:Class;
		
		[Embed(source="../res/images/gamePanel_player_long_empty.png")]	private var gamePanel_player_long_empty:Class;
		[Embed(source="../res/images/gamePanel_player_long_off.png")]		private var gamePanel_player_long_off:Class;
		[Embed(source="../res/images/gamePanel_player_long_me.png")]		private var gamePanel_player_long_me:Class;
		[Embed(source="../res/images/gamePanel_player_short_off.png")]		private var gamePanel_player_short_off:Class;
		[Embed(source="../res/images/gamePanel_player_short_me.png")]		private var gamePanel_player_short_me:Class;
		[Embed(source="../res/images/gamePanel_player_long_0.png")] 		private var gamePanel_player_long_0:Class;
		[Embed(source="../res/images/gamePanel_player_short_0.png")] 		private var gamePanel_player_short_0:Class;
		[Embed(source="../res/images/gamePanel_player_long_1.png")] 		private var gamePanel_player_long_1:Class;
		[Embed(source="../res/images/gamePanel_player_short_1.png")] 		private var gamePanel_player_short_1:Class;
		[Embed(source="../res/images/gamePanel_player_long_2.png")] 		private var gamePanel_player_long_2:Class;
		[Embed(source="../res/images/gamePanel_player_short_2.png")] 		private var gamePanel_player_short_2:Class;
		[Embed(source="../res/images/gamePanel_player_long_3.png")] 		private var gamePanel_player_long_3:Class;
		[Embed(source="../res/images/gamePanel_player_short_3.png")] 		private var gamePanel_player_short_3:Class;
		[Embed(source="../res/images/gamePanel_player_long_4.png")] 		private var gamePanel_player_long_4:Class;
		[Embed(source="../res/images/gamePanel_player_short_4.png")] 		private var gamePanel_player_short_4:Class;
		[Embed(source="../res/images/gamePanel_player_long_5.png")] 		private var gamePanel_player_long_5:Class;
		[Embed(source="../res/images/gamePanel_player_short_5.png")] 		private var gamePanel_player_short_5:Class;
		[Embed(source="../res/images/gamePanel_player_long_6.png")] 		private var gamePanel_player_long_6:Class;
		[Embed(source="../res/images/gamePanel_player_short_6.png")] 		private var gamePanel_player_short_6:Class;
		[Embed(source="../res/images/gamePanel_player_long_7.png")] 		private var gamePanel_player_long_7:Class;
		[Embed(source="../res/images/gamePanel_player_short_7.png")] 		private var gamePanel_player_short_7:Class;
		
		[Embed(source="../res/images/draw_flag.png")] 		private var draw_flag:Class;
		[Embed(source="../res/images/mute_on.png")] 		private var mute_on:Class;
		[Embed(source="../res/images/mute_off.png")] 		private var mute_off:Class;
		
		[Embed(source="../res/images/boost_attack_icon.png")] 				private var boost_attack_icon:Class;
		[Embed(source="../res/images/boost_defense_icon.png")] 			private var boost_defense_icon:Class;
		[Embed(source="../res/images/boost_attack_button.png")] 			private var boost_attack_button:Class;
		[Embed(source="../res/images/boost_defense_button.png")]	 		private var boost_defense_button:Class;
		[Embed(source="../res/images/boost_attack_button_active.png")] 	private var boost_attack_button_active:Class;
		[Embed(source="../res/images/boost_defense_button_active.png")] 	private var boost_defense_button_active:Class;
		
		[Embed(source="../res/images/fightScreen_bg.png")] 			private var fightScreen_bg:Class;

		[Embed(source="../res/images/turnTimer_bg.png")]				private var turnTimer_bg:Class;
		[Embed(source="../res/images/turnTimer_button_yellow.png")]	private var turnTimer_button_yellow:Class;
		[Embed(source="../res/images/turnTimer_button_red.png")]		private var turnTimer_button_red:Class;
		[Embed(source="../res/images/turnTimer_bar_green.png")]		private var turnTimer_bar_green:Class;
		[Embed(source="../res/images/turnTimer_bar_red.png")]			private var turnTimer_bar_red:Class;
		
		[Embed(source="../res/images/terrain_magma.jpg")] 			private var terrain_magma:Class;
		[Embed(source="../res/images/terrain_dragonSkin.jpg")] 	private var terrain_dragonSkin:Class;
		[Embed(source="../res/images/terrain_grass.jpg")] 			private var terrain_grass:Class;
		[Embed(source="../res/images/terrain_camo.jpg")] 			private var terrain_camo:Class;
		[Embed(source="../res/images/terrain_snow.jpg")] 			private var terrain_snow:Class;
		[Embed(source="../res/images/terrain_woodFloor.jpg")]		private var terrain_woodFloor:Class;
		[Embed(source="../res/images/terrain_bones.jpg")]			private var terrain_bones:Class;
		[Embed(source="../res/images/terrain_aliens.jpg")]			private var terrain_aliens:Class;
		[Embed(source="../res/images/terrain_angels.jpg")]			private var terrain_angels:Class;
		[Embed(source="../res/images/terrain_elementals.jpg")]		private var terrain_elementals:Class;
		[Embed(source="../res/images/terrain_insectoids.jpg")]		private var terrain_insectoids:Class;
		[Embed(source="../res/images/terrain_soldiers.jpg")]		private var terrain_soldiers:Class;
		[Embed(source="../res/images/terrain_ninjas.jpg")]			private var terrain_ninjas:Class;
		[Embed(source="../res/images/terrain_robots.jpg")]			private var terrain_robots:Class;
		[Embed(source="../res/images/terrain_vampires.jpg")]		private var terrain_vampires:Class;
		[Embed(source="../res/images/terrain_pumpkins.jpg")]		private var terrain_pumpkins:Class;
		[Embed(source="../res/images/terrain_dragons.jpg")]		private var terrain_dragons:Class;
		[Embed(source="../res/images/terrain_arachnids.jpg")]		private var terrain_arachnids:Class;
		[Embed(source="../res/images/terrain_reptiles.jpg")]		private var terrain_reptiles:Class;
		[Embed(source="../res/images/terrain_santas.jpg")]			private var terrain_santas:Class;
		[Embed(source="../res/images/terrain_reindeers.jpg")]		private var terrain_reindeers:Class;
		[Embed(source="../res/images/terrain_snowmen.jpg")]		private var terrain_snowmen:Class;
		[Embed(source="../res/images/terrain_natives.jpg")]		private var terrain_natives:Class;
		[Embed(source="../res/images/terrain_undead.jpg")]			private var terrain_undead:Class;
		[Embed(source="../res/images/terrain_terminators.jpg")]	private var terrain_terminators:Class;
		[Embed(source="../res/images/terrain_tannenbaums.jpg")]	private var terrain_tannenbaums:Class;
		[Embed(source="../res/images/terrain_snowflakes.jpg")]		private var terrain_snowflakes:Class;
		[Embed(source="../res/images/terrain_temp.png")]			private var terrain_temp:Class;
		
		[Embed(source="../res/images/selector_arrow_disabled.png")]	private var selector_arrow_disabled:Class;
		[Embed(source="../res/images/selector_arrow_big.png")]			private var selector_arrow_big:Class;
		
		[Embed(source="../res/images/race_profileImage_Elves.jpg")] 			private var race_profileImage_Elves:Class;
		[Embed(source="../res/images/race_profileImage_SnowGiants.jpg")] 		private var race_profileImage_SnowGiants:Class;
		[Embed(source="../res/images/race_profileImage_Legionaires.jpg")] 		private var race_profileImage_Legionaires:Class;
		[Embed(source="../res/images/race_profileImage_Robots.jpg")] 			private var race_profileImage_Robots:Class;
		[Embed(source="../res/images/race_profileImage_Soldiers.jpg")] 		private var race_profileImage_Soldiers:Class;
		[Embed(source="../res/images/race_profileImage_Elementals.jpg")] 		private var race_profileImage_Elementals:Class;
		[Embed(source="../res/images/race_profileImage_Pirates.jpg")] 			private var race_profileImage_Pirates:Class;
		[Embed(source="../res/images/race_profileImage_Ninjas.jpg")] 			private var race_profileImage_Ninjas:Class;
		[Embed(source="../res/images/race_profileImage_Insectoids.jpg")]		private var race_profileImage_Insectoids:Class;
		[Embed(source="../res/images/race_profileImage_Demons.jpg")] 			private var race_profileImage_Demons:Class;
		[Embed(source="../res/images/race_profileImage_Angels.jpg")] 			private var race_profileImage_Angels:Class;
		[Embed(source="../res/images/race_profileImage_Aliens.jpg")] 			private var race_profileImage_Aliens:Class;
		[Embed(source="../res/images/race_profileImage_Vampires.jpg")]			private var race_profileImage_Vampires:Class;
		[Embed(source="../res/images/race_profileImage_Pumpkins.jpg")]			private var race_profileImage_Pumpkins:Class;
		[Embed(source="../res/images/race_profileImage_Dragons.jpg")]			private var race_profileImage_Dragons:Class;
		[Embed(source="../res/images/race_profileImage_Reptiles.jpg")]			private var race_profileImage_Reptiles:Class;
		[Embed(source="../res/images/race_profileImage_Arachnids.jpg")]		private var race_profileImage_Arachnids:Class;
		[Embed(source="../res/images/race_profileImage_Snowmen.jpg")]			private var race_profileImage_Snowmen:Class;
		[Embed(source="../res/images/race_profileImage_Reindeers.jpg")]		private var race_profileImage_Reindeers:Class;
		[Embed(source="../res/images/race_profileImage_Santas.jpg")]			private var race_profileImage_Santas:Class;
		[Embed(source="../res/images/race_profileImage_Natives.jpg")]			private var race_profileImage_Natives:Class;
		[Embed(source="../res/images/race_profileImage_Undead.jpg")]			private var race_profileImage_Undead:Class;
		[Embed(source="../res/images/race_profileImage_Terminators.jpg")]		private var race_profileImage_Terminators:Class;
		[Embed(source="../res/images/race_profileImage_TeddyBears.jpg")]		private var race_profileImage_TeddyBears:Class;
		[Embed(source="../res/images/race_profileImage_DarkKnights.jpg")]		private var race_profileImage_DarkKnights:Class;
		[Embed(source="../res/images/race_profileImage_Cyborgs.jpg")]			private var race_profileImage_Cyborgs:Class;
		[Embed(source="../res/images/race_profileImage_BladeMasters.jpg")]		private var race_profileImage_BladeMasters:Class;
		[Embed(source="../res/images/race_profileImage_Watchmen.jpg")]			private var race_profileImage_Watchmen:Class;
		[Embed(source="../res/images/race_profileImage_Werewolves.jpg")]		private var race_profileImage_Werewolves:Class;
		[Embed(source="../res/images/race_profileImage_Frankensteins.jpg")]	private var race_profileImage_Frankensteins:Class;
		[Embed(source="../res/images/race_profileImage_Tannenbaums.jpg")]		private var race_profileImage_Tannenbaums:Class;
		[Embed(source="../res/images/race_profileImage_Snowflakes.jpg")]		private var race_profileImage_Snowflakes:Class;
		
		[Embed(source="../res/images/army_logoEmpty.png")] 		private var army_logoEmpty:Class;
		[Embed(source="../res/images/army_logoElves.png")] 		private var army_logoElves:Class;
		[Embed(source="../res/images/army_logoRobots.png")] 		private var army_logoRobots:Class;
		[Embed(source="../res/images/army_logoSoldiers.png")] 		private var army_logoSoldiers:Class;
		[Embed(source="../res/images/army_logoLegionaires.png")]	private var army_logoLegionaires:Class;
		[Embed(source="../res/images/army_logoSnowGiants.png")]	private var army_logoSnowGiants:Class;
		[Embed(source="../res/images/army_logoDemons.png")]		private var army_logoDemons:Class;
		[Embed(source="../res/images/army_logoAngels.png")]		private var army_logoAngels:Class;
		[Embed(source="../res/images/army_logoElementals.png")]	private var army_logoElementals:Class;
		[Embed(source="../res/images/army_logoPirates.png")]		private var army_logoPirates:Class;
		[Embed(source="../res/images/army_logoNinjas.png")]		private var army_logoNinjas:Class;
		[Embed(source="../res/images/army_logoInsectoids.png")]	private var army_logoInsectoids:Class;
		[Embed(source="../res/images/army_logoAliens.png")]		private var army_logoAliens:Class;
		[Embed(source="../res/images/army_logoVampires.png")]		private var army_logoVampires:Class;
		[Embed(source="../res/images/army_logoPumpkins.png")]		private var army_logoPumpkins:Class;
		[Embed(source="../res/images/army_logoDragons.png")]		private var army_logoDragons:Class;
		[Embed(source="../res/images/army_logoReptiles.png")]		private var army_logoReptiles:Class;
		[Embed(source="../res/images/army_logoArachnids.png")]		private var army_logoArachnids:Class;
		[Embed(source="../res/images/army_logoSantas.png")]		private var army_logoSantas:Class;
		[Embed(source="../res/images/army_logoReindeers.png")]		private var army_logoReindeers:Class;
		[Embed(source="../res/images/army_logoSnowmen.png")]		private var army_logoSnowmen:Class;
		[Embed(source="../res/images/army_logoNatives.png")]		private var army_logoNatives:Class;
		[Embed(source="../res/images/army_logoUndead.png")]		private var army_logoUndead:Class;
		[Embed(source="../res/images/army_logoTerminators.png")]	private var army_logoTerminators:Class;
		[Embed(source="../res/images/army_logoBladeMasters.png")]	private var army_logoBladeMasters:Class;
		[Embed(source="../res/images/army_logoCyborgs.png")]		private var army_logoCyborgs:Class;
		[Embed(source="../res/images/army_logoDarkKnights.png")]	private var army_logoDarkKnights:Class;
		[Embed(source="../res/images/army_logoTeddyBears.png")]	private var army_logoTeddyBears:Class;
		[Embed(source="../res/images/army_logoWatchmen.png")]		private var army_logoWatchmen:Class;
		[Embed(source="../res/images/army_logoWerewolves.png")]	private var army_logoWerewolves:Class;
		[Embed(source="../res/images/army_logoFrankensteins.png")]	private var army_logoFrankensteins:Class;
		[Embed(source="../res/images/army_logoTannenbaums.png")]	private var army_logoTannenbaums:Class;
		[Embed(source="../res/images/army_logoSnowflakes.png")]	private var army_logoSnowflakes:Class;
		
		[Embed(source="../res/images/army_light0.png")] 			private var army_light0:Class;
		[Embed(source="../res/images/army_light1.png")] 			private var army_light1:Class;
		[Embed(source="../res/images/army_light2.png")] 			private var army_light2:Class;
		[Embed(source="../res/images/army_light3.png")] 			private var army_light3:Class;
		[Embed(source="../res/images/army_light4.png")] 			private var army_light4:Class;
		[Embed(source="../res/images/army_light5.png")] 			private var army_light5:Class;
		[Embed(source="../res/images/army_light6.png")] 			private var army_light6:Class;
		[Embed(source="../res/images/army_light7.png")] 			private var army_light7:Class;
		//[Embed(source="Resources/Images/missingAsset.gif")] 	private var missingAsset:Class;

		
		[Embed(source="../res/images/lobby_gameBg5_active.png")] 			private var lobby_gameBg_active:Class;
		[Embed(source="../res/images/lobby_gameBg5_inactive.png")] 		private var lobby_gameBg_inactive:Class;
		[Embed(source="../res/images/lobby_gameStartType_conquer.png")]	private var lobby_gameStartType_conquer:Class;
		[Embed(source="../res/images/lobby_gameStartType_full.png")]		private var lobby_gameStartType_full:Class;
		[Embed(source="../res/images/lobby_gameDistType_random.png")]		private var lobby_gameDistType_random:Class;
		[Embed(source="../res/images/lobby_gameDistType_manual.png")]		private var lobby_gameDistType_manual:Class;
		[Embed(source="../res/images/lobby_gameDistType_border.png")]		private var lobby_gameDistType_border:Class;
		[Embed(source="../res/images/lobby_gameStartType_conquer.png")]	private var lobby_gameStartType_conquer_g:Class;
		[Embed(source="../res/images/lobby_gameStartType_full_g.png")]		private var lobby_gameStartType_full_g:Class;
		[Embed(source="../res/images/lobby_gameDistType_random_g.png")]		private var lobby_gameDistType_random_g:Class;
		[Embed(source="../res/images/lobby_gameDistType_manual_g.png")]		private var lobby_gameDistType_manual_g:Class;
		[Embed(source="../res/images/lobby_gameDistType_border_g.png")]		private var lobby_gameDistType_border_g:Class;
		
		[Embed(source="../res/images/lobby_chatListSlider_mid.png")]		private var lobby_chatListSlider_mid:Class;
		[Embed(source="../res/images/lobby_chatListSlider_end.png")]		private var lobby_chatListSlider_end:Class;
		[Embed(source="../res/images/lobby_chatListUser_bg.png")]			private var lobby_chatListUser_bg:Class;
		[Embed(source="../res/images/lobby_chatListUserPremium_bg.png")]	private var lobby_chatListUserPremium_bg:Class;
		[Embed(source="../res/images/lobby_chatListUserModerator_bg.png")]	private var lobby_chatListUserModerator_bg:Class;
		[Embed(source="../res/images/lobby_chatListUserFriend_bg.png")]	private var lobby_chatListUserFriend_bg:Class;
		
		[Embed(source="../res/images/slider_bg_mid.png")]					private var slider_bg_mid:Class;
		[Embed(source="../res/images/slider_bg_end.png")]					private var slider_bg_end:Class;
		
		[Embed(source="../res/images/lobby_map_cell_bg.png")]				private var lobby_map_cell_bg:Class;
		[Embed(source="../res/images/lobby_map_cell_bg_selected.png")]		private var lobby_map_cell_bg_selected:Class;
		[Embed(source="../res/images/lobby_map_rating_plus.png")]			private var lobby_map_rating_plus:Class;
		[Embed(source="../res/images/lobby_map_rating_minus.png")]			private var lobby_map_rating_minus:Class;
		[Embed(source="../res/images/lobby_map_rating_plus_empty.png")]	private var lobby_map_rating_plus_empty:Class;
		[Embed(source="../res/images/lobby_map_rating_minus_empty.png")]	private var lobby_map_rating_minus_empty:Class;
		
		[Embed(source="../res/images/menu_shortcutPanel_bg.png")]			private var menu_shortcutPanel_bg:Class;
		[Embed(source="../res/images/menu_divider_horizontal.png")]		private var menu_divider_horizontal:Class;
		
		[Embed(source="../res/images/lb_me.png")]						private var lb_me:Class;
		[Embed(source="../res/images/lb_legend_bg.png")]				private var lb_legend_bg:Class;
		[Embed(source="../res/images/lb_legend_sortArrow.png")]		private var lb_legend_sortArrow:Class;
		
		[Embed(source="../res/images/gameRoom_kick.png")]				private var gameRoom_kick:Class;
		[Embed(source="../res/images/gameRoom_ready.png")]				private var gameRoom_ready:Class;
		[Embed(source="../res/images/gameRoom_ready_disabled.png")]	private var gameRoom_ready_disabled:Class;
		
		[Embed(source="../res/images/soundPanel_bg.png")]			private var soundPanel_bg:Class;
		[Embed(source="../res/images/music_on.png")]				private var music_on:Class;
		[Embed(source="../res/images/music_off.png")]				private var music_off:Class;
		[Embed(source="../res/images/sound_on.png")]				private var sound_on:Class;
		[Embed(source="../res/images/sound_off.png")]				private var sound_off:Class;
		
		[Embed(source="../res/images/music_on_small.png")]			private var music_on_small:Class;
		[Embed(source="../res/images/music_off_small.png")]		private var music_off_small:Class;
		[Embed(source="../res/images/sound_on_small.png")]			private var sound_on_small:Class;
		[Embed(source="../res/images/sound_off_small.png")]		private var sound_off_small:Class;

		[Embed(source="../res/images/map_zoom_in.png")]			private var map_zoom_in:Class;
		[Embed(source="../res/images/map_zoom_out.png")]			private var map_zoom_out:Class;
		
		[Embed(source="../res/images/checkbox.png")]				private var checkbox:Class;
		[Embed(source="../res/images/checkbox_selected.png")]		private var checkbox_selected:Class;
		
		[Embed(source="../res/images/loading_bg.png")]			private var loading_bg:Class;
		[Embed(source="../res/images/loading_light.png")]		private var loading_light:Class;
		
		[Embed(source="../res/images/shop_coin.png")]			private var shop_coin:Class;
		[Embed(source="../res/images/shop_shard.png")]			private var shop_shard:Class;
		[Embed(source="../res/images/shop_fbcredits.png")]		private var shop_fbcredits:Class;
		[Embed(source="../res/images/shop_logo_paypal.png")]	private var shop_logo_paypal:Class;
		[Embed(source="../res/images/shop_logo_gambit.png")]	private var shop_logo_gambit:Class;
		[Embed(source="../res/images/shop_logo_sr.png")]		private var shop_logo_sr:Class;
		
		[Embed(source="../res/images/shop_splash_new.png")]			private var shop_splash_new:Class;
		//[Embed(source="../res/images/menu_shop_deco_halloween.png")]	private var menu_shop_deco:Class;
		[Embed(source="../res/images/menu_deco_snow.png")] 			private var menu_deco_snow:Class;
		[Embed(source="../res/images/menu_shop_deco_xmass.png")]		private var menu_shop_deco:Class;

		[Embed(source="../res/images/achiev_lvl1.png")]		private var achiev_lvl1:Class;
		[Embed(source="../res/images/achiev_lvl2.png")]		private var achiev_lvl2:Class;
		[Embed(source="../res/images/achiev_lvl3.png")]		private var achiev_lvl3:Class;
		[Embed(source="../res/images/achiev_lvl4.png")]		private var achiev_lvl4:Class;
		[Embed(source="../res/images/achiev_lvl5.png")]		private var achiev_lvl5:Class;
		[Embed(source="../res/images/achiev_icon1.png")]		private var achiev_icon1:Class;
		[Embed(source="../res/images/achiev_icon2.png")]		private var achiev_icon2:Class;
		[Embed(source="../res/images/achiev_icon3.png")]		private var achiev_icon3:Class;
		[Embed(source="../res/images/achiev_icon4.png")]		private var achiev_icon4:Class;
		[Embed(source="../res/images/achiev_icon5.png")]		private var achiev_icon5:Class;
		
		[Embed(source="../res/images/howToPlay_0_0.jpg")]		private var howToPlay_0_0:Class;
		[Embed(source="../res/images/howToPlay_0_1.jpg")]		private var howToPlay_0_1:Class;
		[Embed(source="../res/images/howToPlay_0_2.jpg")]		private var howToPlay_0_2:Class;
		[Embed(source="../res/images/howToPlay_0_3.jpg")]		private var howToPlay_0_3:Class;
		[Embed(source="../res/images/howToPlay_0_4.jpg")]		private var howToPlay_0_4:Class;
		[Embed(source="../res/images/howToPlay_3_0.jpg")]		private var howToPlay_3_0:Class;
		[Embed(source="../res/images/howToPlay_3_1.jpg")]		private var howToPlay_3_1:Class;
		
		[Embed(source="../res/images/ranks.png")]		private var ranks:Class;
		
		[Embed(source="../res/images/mapPreview_user.jpg")]	private var mapPreview_user:Class;
		[Embed(source="../res/images/mapPreview_random.png")]	private var mapPreview_random:Class;
		[Embed(source="../res/images/mapPreview_0_0.png")]		private var mapPreview_0_0:Class;
		[Embed(source="../res/images/mapPreview_0_1.png")]		private var mapPreview_0_1:Class;
		[Embed(source="../res/images/mapPreview_0_2.png")]		private var mapPreview_0_2:Class;
		[Embed(source="../res/images/mapPreview_0_3.png")]		private var mapPreview_0_3:Class;
		[Embed(source="../res/images/mapPreview_1_0.png")]		private var mapPreview_1_0:Class;
		[Embed(source="../res/images/mapPreview_1_1.png")]		private var mapPreview_1_1:Class;
		[Embed(source="../res/images/mapPreview_1_2.png")]		private var mapPreview_1_2:Class;
		[Embed(source="../res/images/mapPreview_1_3.png")]		private var mapPreview_1_3:Class;
		[Embed(source="../res/images/mapPreview_2_0.png")]		private var mapPreview_2_0:Class;
		[Embed(source="../res/images/mapPreview_2_1.png")]		private var mapPreview_2_1:Class;
		[Embed(source="../res/images/mapPreview_2_2.png")]		private var mapPreview_2_2:Class;
		[Embed(source="../res/images/mapPreview_2_3.png")]		private var mapPreview_2_3:Class;
		[Embed(source="../res/images/mapPreview_3_0.png")]		private var mapPreview_3_0:Class;
		[Embed(source="../res/images/mapPreview_3_1.png")]		private var mapPreview_3_1:Class;
		[Embed(source="../res/images/mapPreview_3_2.png")]		private var mapPreview_3_2:Class;
		[Embed(source="../res/images/mapPreview_3_3.png")]		private var mapPreview_3_3:Class;
		[Embed(source="../res/images/mapPreview_99_0.png")]	private var mapPreview_99_0:Class;
		[Embed(source="../res/images/mapPreview_99_1.png")]	private var mapPreview_99_1:Class;
		[Embed(source="../res/images/mapPreview_99_2.png")]	private var mapPreview_99_2:Class;
		[Embed(source="../res/images/mapPreview_99_3.png")]	private var mapPreview_99_3:Class;
		[Embed(source="../res/images/mapPreview_99_4.png")]	private var mapPreview_99_4:Class;
		[Embed(source="../res/images/mapPreview_99_5.png")]	private var mapPreview_99_5:Class;
		[Embed(source="../res/images/mapPreview_99_6.png")]	private var mapPreview_99_6:Class;
		[Embed(source="../res/images/mapPreview_99_7.png")]	private var mapPreview_99_7:Class;
		[Embed(source="../res/images/mapPreview_99_8.png")]	private var mapPreview_99_8:Class;
		[Embed(source="../res/images/mapPreview_99_9.png")]	private var mapPreview_99_9:Class;
		
		[Embed(source="../res/images/map_bg_0.png")]	private var map_bg_0:Class;
		[Embed(source="../res/images/map_bg_1.jpg")]	private var map_bg_1:Class;
		[Embed(source="../res/images/map_bg_2.jpg")]	private var map_bg_2:Class;
		[Embed(source="../res/images/map_bg_3.jpg")]	private var map_bg_3:Class;
		[Embed(source="../res/images/map_bg_4.jpg")]	private var map_bg_4:Class;
		[Embed(source="../res/images/map_bg_5.jpg")]	private var map_bg_5:Class;
		[Embed(source="../res/images/map_bg_6.jpg")]	private var map_bg_6:Class;
		[Embed(source="../res/images/map_bg_7.jpg")]	private var map_bg_7:Class;
		[Embed(source="../res/images/map_bg_8.jpg")]	private var map_bg_8:Class;
		[Embed(source="../res/images/map_bg_9.jpg")]	private var map_bg_9:Class;
		[Embed(source="../res/images/map_bg_10.jpg")]	private var map_bg_10:Class;
		[Embed(source="../res/images/map_bg_11.jpg")]	private var map_bg_11:Class;
		[Embed(source="../res/images/map_bg_12.jpg")]	private var map_bg_12:Class;
		[Embed(source="../res/images/map_bg_13.jpg")]	private var map_bg_13:Class;
		[Embed(source="../res/images/map_bg_14.jpg")]	private var map_bg_14:Class;
		[Embed(source="../res/images/map_bg_100.jpg")]	private var map_bg_100:Class;
		
		//[Embed(source="../res/sounds/music.mp3")]				private var music:Class;
		[Embed(source="../res/sounds/btn_click1.mp3")]			private var btn_click1:Class;
		[Embed(source="../res/sounds/dice_rolling.mp3")]		private var dice_rolling:Class;
		[Embed(source="../res/sounds/battle_win.mp3")]			private var battle_win:Class;
		[Embed(source="../res/sounds/battle_lose.mp3")]		private var battle_lose:Class;
		[Embed(source="../res/sounds/error_dialog.mp3")]		private var error_dialog:Class;
		[Embed(source="../res/sounds/game_over_win.mp3")]		private var game_over_win:Class;
		[Embed(source="../res/sounds/game_over_lose.mp3")]		private var game_over_lose:Class;
		[Embed(source="../res/sounds/chat_notif.mp3")]			private var chat_notif:Class;
		[Embed(source="../res/sounds/new_unit_placed.mp3")]	private var new_unit_placed:Class;
		[Embed(source="../res/sounds/start_turn_me.mp3")]		private var start_turn_me:Class;
		[Embed(source="../res/sounds/turn_ending.mp3")]		private var turn_ending:Class;
		[Embed(source="../res/sounds/turn_ending_fast.mp3")]	private var turn_ending_fast:Class;
		
		public function Resources()
		{
			var res:Bitmap;

			res = new patch_editText_topLeft();		ResList.AddArtResource("9patch_editText_topLeft", res);
			res = new patch_editText_topRight();	ResList.AddArtResource("9patch_editText_topRight", res);
			res = new patch_editText_top();			ResList.AddArtResource("9patch_editText_top", res);
			res = new patch_editText_left();		ResList.AddArtResource("9patch_editText_left", res);
			res = new patch_editText_right();		ResList.AddArtResource("9patch_editText_right", res);
			res = new patch_editText_bottomLeft();	ResList.AddArtResource("9patch_editText_bottomLeft", res);
			res = new patch_editText_bottomRight();	ResList.AddArtResource("9patch_editText_bottomRight", res);
			res = new patch_editText_bottom();		ResList.AddArtResource("9patch_editText_bottom", res);
			res = new patch_editText_center();		ResList.AddArtResource("9patch_editText_center", res);
			
			res = new patch_popup_topLeft();		ResList.AddArtResource("9patch_popup_topLeft", res);
			res = new patch_popup_topRight();		ResList.AddArtResource("9patch_popup_topRight", res);
			res = new patch_popup_top();			ResList.AddArtResource("9patch_popup_top", res);
			res = new patch_popup_left();			ResList.AddArtResource("9patch_popup_left", res);
			res = new patch_popup_right();			ResList.AddArtResource("9patch_popup_right", res);
			res = new patch_popup_bottomLeft();		ResList.AddArtResource("9patch_popup_bottomLeft", res);
			res = new patch_popup_bottomRight();	ResList.AddArtResource("9patch_popup_bottomRight", res);
			res = new patch_popup_bottom();			ResList.AddArtResource("9patch_popup_bottom", res);
			res = new patch_popup_center();			ResList.AddArtResource("9patch_popup_center", res);
			
			res = new patch_context_topLeft();		ResList.AddArtResource("9patch_context_topLeft", res);
			res = new patch_context_topRight();		ResList.AddArtResource("9patch_context_topRight", res);
			res = new patch_context_top();			ResList.AddArtResource("9patch_context_top", res);
			res = new patch_context_left();			ResList.AddArtResource("9patch_context_left", res);
			res = new patch_context_right();		ResList.AddArtResource("9patch_context_right", res);
			res = new patch_context_bottomLeft();	ResList.AddArtResource("9patch_context_bottomLeft", res);
			res = new patch_context_bottomRight();	ResList.AddArtResource("9patch_context_bottomRight", res);
			res = new patch_context_bottom();		ResList.AddArtResource("9patch_context_bottom", res);
			res = new patch_context_center();		ResList.AddArtResource("9patch_context_center", res);
			
			res = new patch_transparent_panel_topLeft();		ResList.AddArtResource("9patch_transparent_panel_topLeft", res);
			res = new patch_transparent_panel_topRight();		ResList.AddArtResource("9patch_transparent_panel_topRight", res);
			res = new patch_transparent_panel_top();			ResList.AddArtResource("9patch_transparent_panel_top", res);
			res = new patch_transparent_panel_left();			ResList.AddArtResource("9patch_transparent_panel_left", res);
			res = new patch_transparent_panel_right();			ResList.AddArtResource("9patch_transparent_panel_right", res);
			res = new patch_transparent_panel_bottomLeft();		ResList.AddArtResource("9patch_transparent_panel_bottomLeft", res);
			res = new patch_transparent_panel_bottomRight();	ResList.AddArtResource("9patch_transparent_panel_bottomRight", res);
			res = new patch_transparent_panel_bottom();			ResList.AddArtResource("9patch_transparent_panel_bottom", res);
			res = new patch_transparent_panel_center();			ResList.AddArtResource("9patch_transparent_panel_center", res);
			
			res = new patch_emboss_panel_topLeft();			ResList.AddArtResource("9patch_emboss_panel_topLeft", res);
			res = new patch_emboss_panel_topRight();		ResList.AddArtResource("9patch_emboss_panel_topRight", res);
			res = new patch_emboss_panel_top();				ResList.AddArtResource("9patch_emboss_panel_top", res);
			res = new patch_emboss_panel_left();			ResList.AddArtResource("9patch_emboss_panel_left", res);
			res = new patch_emboss_panel_right();			ResList.AddArtResource("9patch_emboss_panel_right", res);
			res = new patch_emboss_panel_bottomLeft();		ResList.AddArtResource("9patch_emboss_panel_bottomLeft", res);
			res = new patch_emboss_panel_bottomRight();		ResList.AddArtResource("9patch_emboss_panel_bottomRight", res);
			res = new patch_emboss_panel_bottom();			ResList.AddArtResource("9patch_emboss_panel_bottom", res);
			res = new patch_emboss_panel_center();			ResList.AddArtResource("9patch_emboss_panel_center", res);
			
			res = new logo_gray();		ResList.AddArtResource("logo_gray", res);
			
			res = new button_side_hide();		ResList.AddArtResource("button_side_hide", res);
			res = new button_small_gray_mid();	ResList.AddArtResource("button_small_gray_mid", res);
			res = new button_small_gray_end();	ResList.AddArtResource("button_small_gray_end", res);
			res = new button_small_gold_mid();	ResList.AddArtResource("button_small_gold_mid", res);
			res = new button_small_gold_end();	ResList.AddArtResource("button_small_gold_end", res);
			res = new button_small_blue_mid();	ResList.AddArtResource("button_small_blue_mid", res);
			res = new button_small_blue_end();	ResList.AddArtResource("button_small_blue_end", res);
			
			res = new button_medium_gray_mid();	ResList.AddArtResource("button_medium_gray_mid", res);
			res = new button_medium_gray_end();	ResList.AddArtResource("button_medium_gray_end", res);
			res = new button_medium_gold_mid();	ResList.AddArtResource("button_medium_gold_mid", res);
			res = new button_medium_gold_end();	ResList.AddArtResource("button_medium_gold_end", res);
			
			res = new button_big_gray_mid();	ResList.AddArtResource("button_big_gray_mid", res);
			res = new button_big_gray_end();	ResList.AddArtResource("button_big_gray_end", res);
			res = new button_big_gold_mid();	ResList.AddArtResource("button_big_gold_mid", res);
			res = new button_big_gold_end();	ResList.AddArtResource("button_big_gold_end", res);
			
			res = new button_map_report();		ResList.AddArtResource("button_map_report", res);
			
			res = new bg();			 				ResList.AddArtResource("bg", res);
			
			res = new level_progress_bg();			ResList.AddArtResource("level_progress_bg", res);
			res = new level_progress_fill_blue();	ResList.AddArtResource("level_progress_fill_blue", res);
			res = new level_progress_fill_yellow();	ResList.AddArtResource("level_progress_fill_yellow", res);
			
			res = new game_chatBg(); 				ResList.AddArtResource("game_chatBg", res);
			res = new game_chatHistory();			ResList.AddArtResource("game_chatHistory", res);
			res = new game_chatHistoryDown();		ResList.AddArtResource("game_chatHistoryDown", res);
			res = new game_chatUp(); 				ResList.AddArtResource("game_chatUp", res);
			
			res = new gamePanel_player_long_empty();	ResList.AddArtResource("gamePanel_player_long_empty", res);
			res = new gamePanel_player_long_off();		ResList.AddArtResource("gamePanel_player_long_off", res);
			res = new gamePanel_player_long_me();		ResList.AddArtResource("gamePanel_player_long_me", res);
			res = new gamePanel_player_short_off();		ResList.AddArtResource("gamePanel_player_short_off", res);
			res = new gamePanel_player_short_me();		ResList.AddArtResource("gamePanel_player_short_me", res);
			res = new gamePanel_player_long_0();		ResList.AddArtResource("gamePanel_player_long_0", res);
			res = new gamePanel_player_short_0();		ResList.AddArtResource("gamePanel_player_short_0", res);
			res = new gamePanel_player_long_1();		ResList.AddArtResource("gamePanel_player_long_1", res);
			res = new gamePanel_player_short_1();		ResList.AddArtResource("gamePanel_player_short_1", res);
			res = new gamePanel_player_long_2();		ResList.AddArtResource("gamePanel_player_long_2", res);
			res = new gamePanel_player_short_2();		ResList.AddArtResource("gamePanel_player_short_2", res);
			res = new gamePanel_player_long_3();		ResList.AddArtResource("gamePanel_player_long_3", res);
			res = new gamePanel_player_short_3();		ResList.AddArtResource("gamePanel_player_short_3", res);
			res = new gamePanel_player_long_4();		ResList.AddArtResource("gamePanel_player_long_4", res);
			res = new gamePanel_player_short_4();		ResList.AddArtResource("gamePanel_player_short_4", res);
			res = new gamePanel_player_long_5();		ResList.AddArtResource("gamePanel_player_long_5", res);
			res = new gamePanel_player_short_5();		ResList.AddArtResource("gamePanel_player_short_5", res);
			res = new gamePanel_player_long_6();		ResList.AddArtResource("gamePanel_player_long_6", res);
			res = new gamePanel_player_short_6();		ResList.AddArtResource("gamePanel_player_short_6", res);
			res = new gamePanel_player_long_7();		ResList.AddArtResource("gamePanel_player_long_7", res);
			res = new gamePanel_player_short_7();		ResList.AddArtResource("gamePanel_player_short_7", res);
			
			res = new draw_flag(); 		ResList.AddArtResource("draw_flag", res);
			res = new mute_on(); 		ResList.AddArtResource("mute_on", res);
			res = new mute_off(); 		ResList.AddArtResource("mute_off", res);
			
			res = new boost_attack_icon(); 		ResList.AddArtResource("boost_attack_icon", res);
			res = new boost_defense_icon(); 		ResList.AddArtResource("boost_defense_icon", res);
			res = new boost_attack_button(); 		ResList.AddArtResource("boost_attack_button", res);
			res = new boost_defense_button(); 		ResList.AddArtResource("boost_defense_button", res);
			res = new boost_attack_button_active(); 		ResList.AddArtResource("boost_attack_button_active", res);
			res = new boost_defense_button_active(); 		ResList.AddArtResource("boost_defense_button_active", res);
			
			res = new fightScreen_bg();				ResList.AddArtResource("fightScreen_bg", res);

			res = new turnTimer_bg();				ResList.AddArtResource("turnTimer_bg", res);
			res = new turnTimer_button_yellow();	ResList.AddArtResource("turnTimer_button_yellow", res);
			res = new turnTimer_button_red();		ResList.AddArtResource("turnTimer_button_red", res);
			res = new turnTimer_bar_green();		ResList.AddArtResource("turnTimer_bar_green", res);
			res = new turnTimer_bar_red();			ResList.AddArtResource("turnTimer_bar_red", res);
			
			res = new terrain_grass();		ResList.AddArtResource("terrain_grass", res);
			res = new terrain_magma();		ResList.AddArtResource("terrain_magma", res);
			res = new terrain_dragonSkin();	ResList.AddArtResource("terrain_dragonSkin", res);
			res = new terrain_camo();		ResList.AddArtResource("terrain_camo", res);
			res = new terrain_snow();		ResList.AddArtResource("terrain_snow", res);
			res = new terrain_woodFloor();	ResList.AddArtResource("terrain_woodFloor", res);
			res = new terrain_bones();		ResList.AddArtResource("terrain_bones", res);
			res = new terrain_aliens();		ResList.AddArtResource("terrain_aliens", res);
			res = new terrain_angels();		ResList.AddArtResource("terrain_angels", res);
			res = new terrain_elementals();	ResList.AddArtResource("terrain_elementals", res);
			res = new terrain_insectoids();	ResList.AddArtResource("terrain_insectoids", res);
			res = new terrain_soldiers();	ResList.AddArtResource("terrain_soldiers", res);
			res = new terrain_ninjas();		ResList.AddArtResource("terrain_ninjas", res);
			res = new terrain_robots();		ResList.AddArtResource("terrain_robots", res);
			res = new terrain_vampires();	ResList.AddArtResource("terrain_vampires", res);
			res = new terrain_pumpkins();	ResList.AddArtResource("terrain_pumpkins", res);
			res = new terrain_dragons();	ResList.AddArtResource("terrain_dragons", res);
			res = new terrain_reptiles();	ResList.AddArtResource("terrain_reptiles", res);
			res = new terrain_arachnids();	ResList.AddArtResource("terrain_arachnids", res);
			res = new terrain_snowmen();	ResList.AddArtResource("terrain_snowmen", res);
			res = new terrain_reindeers();	ResList.AddArtResource("terrain_reindeers", res);
			res = new terrain_santas();		ResList.AddArtResource("terrain_santas", res);
			res = new terrain_natives();	ResList.AddArtResource("terrain_natives", res);
			res = new terrain_undead();		ResList.AddArtResource("terrain_undead", res);
			res = new terrain_terminators();ResList.AddArtResource("terrain_terminators", res);
			res = new terrain_tannenbaums();ResList.AddArtResource("terrain_tannenbaums", res);
			res = new terrain_snowflakes();	ResList.AddArtResource("terrain_snowflakes", res);
			res = new terrain_temp();		ResList.AddArtResource("terrain_temp", res);
			
			res = new selector_arrow_disabled();	ResList.AddArtResource("selector_arrow_disabled", res);
			res = new selector_arrow_big();			ResList.AddArtResource("selector_arrow_big", res);
			//res = new missingAsset();		ResList.AddArtResource("missingAsset", res);
			
			res = new race_profileImage_Elves();		ResList.AddArtResource("race_profileImage_Elves", res);
			res = new race_profileImage_SnowGiants();	ResList.AddArtResource("race_profileImage_SnowGiants", res);
			res = new race_profileImage_Legionaires();	ResList.AddArtResource("race_profileImage_Legionaires", res);
			res = new race_profileImage_Robots();		ResList.AddArtResource("race_profileImage_Robots", res);
			res = new race_profileImage_Soldiers();		ResList.AddArtResource("race_profileImage_Soldiers", res);
			res = new race_profileImage_Elementals();	ResList.AddArtResource("race_profileImage_Elementals", res);
			res = new race_profileImage_Pirates();		ResList.AddArtResource("race_profileImage_Pirates", res);
			res = new race_profileImage_Ninjas();		ResList.AddArtResource("race_profileImage_Ninjas", res);
			res = new race_profileImage_Insectoids();	ResList.AddArtResource("race_profileImage_Insectoids", res);
			res = new race_profileImage_Demons();		ResList.AddArtResource("race_profileImage_Demons", res);
			res = new race_profileImage_Angels();		ResList.AddArtResource("race_profileImage_Angels", res);
			res = new race_profileImage_Aliens();		ResList.AddArtResource("race_profileImage_Aliens", res);
			res = new race_profileImage_Vampires();		ResList.AddArtResource("race_profileImage_Vampires", res);
			res = new race_profileImage_Pumpkins();		ResList.AddArtResource("race_profileImage_Pumpkins", res);
			res = new race_profileImage_Dragons();		ResList.AddArtResource("race_profileImage_Dragons", res);
			res = new race_profileImage_Reptiles();		ResList.AddArtResource("race_profileImage_Reptiles", res);
			res = new race_profileImage_Arachnids();	ResList.AddArtResource("race_profileImage_Arachnids", res);
			res = new race_profileImage_Snowmen();		ResList.AddArtResource("race_profileImage_Snowmen", res);
			res = new race_profileImage_Reindeers();	ResList.AddArtResource("race_profileImage_Reindeers", res);
			res = new race_profileImage_Santas();		ResList.AddArtResource("race_profileImage_Santas", res);
			res = new race_profileImage_Natives();		ResList.AddArtResource("race_profileImage_Natives", res);
			res = new race_profileImage_Undead();		ResList.AddArtResource("race_profileImage_Undead", res);
			res = new race_profileImage_Terminators();	ResList.AddArtResource("race_profileImage_Terminators", res);
			res = new race_profileImage_BladeMasters();	ResList.AddArtResource("race_profileImage_BladeMasters", res);
			res = new race_profileImage_Cyborgs();		ResList.AddArtResource("race_profileImage_Cyborgs", res);
			res = new race_profileImage_DarkKnights();	ResList.AddArtResource("race_profileImage_DarkKnights", res);
			res = new race_profileImage_TeddyBears();	ResList.AddArtResource("race_profileImage_TeddyBears", res);
			res = new race_profileImage_Watchmen();		ResList.AddArtResource("race_profileImage_Watchmen", res);
			res = new race_profileImage_Werewolves();	ResList.AddArtResource("race_profileImage_Werewolves", res);
			res = new race_profileImage_Frankensteins();ResList.AddArtResource("race_profileImage_Frankensteins", res);
			res = new race_profileImage_Tannenbaums();	ResList.AddArtResource("race_profileImage_Tannenbaums", res);
			res = new race_profileImage_Snowflakes();	ResList.AddArtResource("race_profileImage_Snowflakes", res);
			
			res = new army_logoEmpty();			ResList.AddArtResource("army_logoEmpty", res);
			res = new army_logoElves();			ResList.AddArtResource("army_logoElves", res);
			res = new army_logoRobots();		ResList.AddArtResource("army_logoRobots", res);
			res = new army_logoSoldiers();		ResList.AddArtResource("army_logoSoldiers", res);
			res = new army_logoLegionaires();	ResList.AddArtResource("army_logoLegionaires", res);
			res = new army_logoSnowGiants();	ResList.AddArtResource("army_logoSnowGiants", res);
			res = new army_logoDemons();		ResList.AddArtResource("army_logoDemons", res);
			res = new army_logoAngels();		ResList.AddArtResource("army_logoAngels", res);
			res = new army_logoElementals();	ResList.AddArtResource("army_logoElementals", res);
			res = new army_logoPirates();		ResList.AddArtResource("army_logoPirates", res);
			res = new army_logoNinjas();		ResList.AddArtResource("army_logoNinjas", res);
			res = new army_logoInsectoids();	ResList.AddArtResource("army_logoInsectoids", res);
			res = new army_logoAliens();		ResList.AddArtResource("army_logoAliens", res);
			res = new army_logoVampires();		ResList.AddArtResource("army_logoVampires", res);
			res = new army_logoPumpkins();		ResList.AddArtResource("army_logoPumpkins", res);
			res = new army_logoDragons();		ResList.AddArtResource("army_logoDragons", res);
			res = new army_logoReptiles();		ResList.AddArtResource("army_logoReptiles", res);
			res = new army_logoArachnids();		ResList.AddArtResource("army_logoArachnids", res);
			res = new army_logoSnowmen();		ResList.AddArtResource("army_logoSnowmen", res);
			res = new army_logoReindeers();		ResList.AddArtResource("army_logoReindeers", res);
			res = new army_logoSantas();		ResList.AddArtResource("army_logoSantas", res);
			res = new army_logoNatives();		ResList.AddArtResource("army_logoNatives", res);
			res = new army_logoUndead();		ResList.AddArtResource("army_logoUndead", res);
			res = new army_logoTerminators();	ResList.AddArtResource("army_logoTerminators", res);
			res = new army_logoBladeMasters();	ResList.AddArtResource("army_logoBladeMasters", res);
			res = new army_logoCyborgs();		ResList.AddArtResource("army_logoCyborgs", res);
			res = new army_logoDarkKnights();	ResList.AddArtResource("army_logoDarkKnights", res);
			res = new army_logoTeddyBears();	ResList.AddArtResource("army_logoTeddyBears", res);
			res = new army_logoWatchmen();		ResList.AddArtResource("army_logoWatchmen", res);
			res = new army_logoWerewolves();	ResList.AddArtResource("army_logoWerewolves", res);
			res = new army_logoFrankensteins();	ResList.AddArtResource("army_logoFrankensteins", res);
			res = new army_logoTannenbaums();	ResList.AddArtResource("army_logoTannenbaums", res);
			res = new army_logoSnowflakes();	ResList.AddArtResource("army_logoSnowflakes", res);
			
			res = new army_light0();	ResList.AddArtResource("army_light0", res);
			res = new army_light1();	ResList.AddArtResource("army_light1", res);
			res = new army_light2();	ResList.AddArtResource("army_light2", res);
			res = new army_light3();	ResList.AddArtResource("army_light3", res);
			res = new army_light4();	ResList.AddArtResource("army_light4", res);
			res = new army_light5();	ResList.AddArtResource("army_light5", res);
			res = new army_light6();	ResList.AddArtResource("army_light6", res);
			res = new army_light7();	ResList.AddArtResource("army_light7", res);
			
			res = new lobby_gameBg_active();			ResList.AddArtResource("lobby_gameBg_active", res);
			res = new lobby_gameBg_inactive();			ResList.AddArtResource("lobby_gameBg_inactive", res);
			res = new lobby_gameStartType_conquer();	ResList.AddArtResource("lobby_gameStartType_conquer", res);
			res = new lobby_gameStartType_full();		ResList.AddArtResource("lobby_gameStartType_full", res);
			res = new lobby_gameDistType_random();		ResList.AddArtResource("lobby_gameDistType_random", res);
			res = new lobby_gameDistType_manual();		ResList.AddArtResource("lobby_gameDistType_manual", res);
			res = new lobby_gameDistType_border();		ResList.AddArtResource("lobby_gameDistType_border", res);
			res = new lobby_gameStartType_conquer_g();	ResList.AddArtResource("lobby_gameStartType_conquer_g", res);
			res = new lobby_gameStartType_full_g();		ResList.AddArtResource("lobby_gameStartType_full_g", res);
			res = new lobby_gameDistType_random_g();	ResList.AddArtResource("lobby_gameDistType_random_g", res);
			res = new lobby_gameDistType_manual_g();	ResList.AddArtResource("lobby_gameDistType_manual_g", res);
			res = new lobby_gameDistType_border_g();	ResList.AddArtResource("lobby_gameDistType_border_g", res);
			
			res = new lobby_chatListSlider_mid();		ResList.AddArtResource("lobby_chatListSlider_mid", res);
			res = new lobby_chatListSlider_end();		ResList.AddArtResource("lobby_chatListSlider_end", res);
			res = new lobby_chatListUser_bg();			ResList.AddArtResource("lobby_chatListUser_bg", res);
			res = new lobby_chatListUserPremium_bg();	ResList.AddArtResource("lobby_chatListUserPremium_bg", res);
			res = new lobby_chatListUserModerator_bg();	ResList.AddArtResource("lobby_chatListUserModerator_bg", res);
			res = new lobby_chatListUserFriend_bg();	ResList.AddArtResource("lobby_chatListUserFriend_bg", res);
			
			res = new slider_bg_end();					ResList.AddArtResource("slider_bg_end", res);
			res = new slider_bg_mid();					ResList.AddArtResource("slider_bg_mid", res);
			
			res = new lobby_map_cell_bg();				ResList.AddArtResource("lobby_map_cell_bg", res);
			res = new lobby_map_cell_bg_selected();		ResList.AddArtResource("lobby_map_cell_bg_selected", res);
			res = new lobby_map_rating_plus();			ResList.AddArtResource("lobby_map_rating_plus", res);
			res = new lobby_map_rating_minus();			ResList.AddArtResource("lobby_map_rating_minus", res);
			res = new lobby_map_rating_plus_empty();	ResList.AddArtResource("lobby_map_rating_plus_empty", res);
			res = new lobby_map_rating_minus_empty();	ResList.AddArtResource("lobby_map_rating_minus_empty", res);
			
			res = new menu_shortcutPanel_bg();		ResList.AddArtResource("menu_shortcutPanel_bg", res);
			res = new menu_divider_horizontal();	ResList.AddArtResource("menu_divider_horizontal", res);
			
			res = new lb_legend_bg();			ResList.AddArtResource("lb_legend_bg", res);
			res = new lb_legend_sortArrow();	ResList.AddArtResource("lb_legend_sortArrow", res);
			res = new lb_me();					ResList.AddArtResource("lb_me", res);
			
			res = new gameRoom_ready();				ResList.AddArtResource("gameRoom_ready", res);
			res = new gameRoom_ready_disabled();	ResList.AddArtResource("gameRoom_ready_disabled", res);
			res = new gameRoom_kick();				ResList.AddArtResource("gameRoom_kick", res);
			
			res = new music_on();			ResList.AddArtResource("music_on", res);
			res = new music_off();			ResList.AddArtResource("music_off", res);
			res = new sound_on();			ResList.AddArtResource("sound_on", res);
			res = new sound_off();			ResList.AddArtResource("sound_off", res);
			
			res = new map_zoom_in();			ResList.AddArtResource("map_zoom_in", res);
			res = new map_zoom_out();			ResList.AddArtResource("map_zoom_out", res);
			
			res = new soundPanel_bg();		ResList.AddArtResource("soundPanel_bg", res);
			res = new music_on_small();		ResList.AddArtResource("music_on_small", res);
			res = new music_off_small();	ResList.AddArtResource("music_off_small", res);
			res = new sound_on_small();		ResList.AddArtResource("sound_on_small", res);
			res = new sound_off_small();	ResList.AddArtResource("sound_off_small", res);

			res = new checkbox();			ResList.AddArtResource("checkbox", res);
			res = new checkbox_selected();	ResList.AddArtResource("checkbox_selected", res);
			
			res = new loading_bg();			ResList.AddArtResource("loading_bg", res);
			res = new loading_light();		ResList.AddArtResource("loading_light", res);
			
			res = new shop_coin();			ResList.AddArtResource("shop_coin", res);
			res = new shop_shard();			ResList.AddArtResource("shop_shard", res);
			res = new shop_fbcredits();		ResList.AddArtResource("shop_fbcredits", res);
			res = new shop_logo_paypal();	ResList.AddArtResource("shop_logo_paypal", res);
			res = new shop_logo_gambit();	ResList.AddArtResource("shop_logo_gambit", res);
			res = new shop_logo_sr();		ResList.AddArtResource("shop_logo_sr", res);
			
			res = new shop_splash_new();	ResList.AddArtResource("shop_splash_new", res);
			res = new menu_shop_deco();		ResList.AddArtResource("menu_shop_deco", res);
			res = new menu_deco_snow();		ResList.AddArtResource("menu_deco_snow", res);
			
			res = new achiev_lvl1();		ResList.AddArtResource("achiev_lvl1", res);
			res = new achiev_lvl2();		ResList.AddArtResource("achiev_lvl2", res);
			res = new achiev_lvl3();		ResList.AddArtResource("achiev_lvl3", res);
			res = new achiev_lvl4();		ResList.AddArtResource("achiev_lvl4", res);
			res = new achiev_lvl5();		ResList.AddArtResource("achiev_lvl5", res);
			res = new achiev_icon1();		ResList.AddArtResource("achiev_icon1", res);
			res = new achiev_icon2();		ResList.AddArtResource("achiev_icon2", res);
			res = new achiev_icon3();		ResList.AddArtResource("achiev_icon3", res);
			res = new achiev_icon4();		ResList.AddArtResource("achiev_icon4", res);
			res = new achiev_icon5();		ResList.AddArtResource("achiev_icon5", res);
			
			res = new howToPlay_0_0();		ResList.AddArtResource("howToPlay_0_0", res);
			res = new howToPlay_0_1();		ResList.AddArtResource("howToPlay_0_1", res);
			res = new howToPlay_0_2();		ResList.AddArtResource("howToPlay_0_2", res);
			res = new howToPlay_0_3();		ResList.AddArtResource("howToPlay_0_3", res);
			res = new howToPlay_0_4();		ResList.AddArtResource("howToPlay_0_4", res);
			res = new howToPlay_3_0();		ResList.AddArtResource("howToPlay_3_0", res);
			res = new howToPlay_3_1();		ResList.AddArtResource("howToPlay_3_1", res);
			
			res = new ranks();		ResList.AddArtResource("ranks", res);
			
			res = new mapPreview_user();	ResList.AddArtResource("mapPreview_user", res);
			res = new mapPreview_random();	ResList.AddArtResource("mapPreview_random", res);
			res = new mapPreview_0_0();		ResList.AddArtResource("mapPreview_0_0", res);
			res = new mapPreview_0_1();		ResList.AddArtResource("mapPreview_0_1", res);
			res = new mapPreview_0_2();		ResList.AddArtResource("mapPreview_0_2", res);
			res = new mapPreview_0_3();		ResList.AddArtResource("mapPreview_0_3", res);
			res = new mapPreview_1_0();		ResList.AddArtResource("mapPreview_1_0", res);
			res = new mapPreview_1_1();		ResList.AddArtResource("mapPreview_1_1", res);
			res = new mapPreview_1_2();		ResList.AddArtResource("mapPreview_1_2", res);
			res = new mapPreview_1_3();		ResList.AddArtResource("mapPreview_1_3", res);
			res = new mapPreview_2_0();		ResList.AddArtResource("mapPreview_2_0", res);
			res = new mapPreview_2_1();		ResList.AddArtResource("mapPreview_2_1", res);
			res = new mapPreview_2_2();		ResList.AddArtResource("mapPreview_2_2", res);
			res = new mapPreview_2_3();		ResList.AddArtResource("mapPreview_2_3", res);
			res = new mapPreview_3_0();		ResList.AddArtResource("mapPreview_3_0", res);
			res = new mapPreview_3_1();		ResList.AddArtResource("mapPreview_3_1", res);
			res = new mapPreview_3_2();		ResList.AddArtResource("mapPreview_3_2", res);
			res = new mapPreview_3_3();		ResList.AddArtResource("mapPreview_3_3", res);
			res = new mapPreview_99_0();	ResList.AddArtResource("mapPreview_99_0", res);
			res = new mapPreview_99_1();	ResList.AddArtResource("mapPreview_99_1", res);
			res = new mapPreview_99_2();	ResList.AddArtResource("mapPreview_99_2", res);
			res = new mapPreview_99_3();	ResList.AddArtResource("mapPreview_99_3", res);
			res = new mapPreview_99_4();	ResList.AddArtResource("mapPreview_99_4", res);
			res = new mapPreview_99_5();	ResList.AddArtResource("mapPreview_99_5", res);
			res = new mapPreview_99_6();	ResList.AddArtResource("mapPreview_99_6", res);
			res = new mapPreview_99_7();	ResList.AddArtResource("mapPreview_99_7", res);
			res = new mapPreview_99_8();	ResList.AddArtResource("mapPreview_99_8", res);
			res = new mapPreview_99_9();	ResList.AddArtResource("mapPreview_99_9", res);
			
			res = new map_bg_0();	ResList.AddArtResource("map_bg_0", res);
			res = new map_bg_1();	ResList.AddArtResource("map_bg_1", res);
			res = new map_bg_2();	ResList.AddArtResource("map_bg_2", res);
			res = new map_bg_3();	ResList.AddArtResource("map_bg_3", res);
			res = new map_bg_4();	ResList.AddArtResource("map_bg_4", res);
			res = new map_bg_5();	ResList.AddArtResource("map_bg_5", res);
			res = new map_bg_6();	ResList.AddArtResource("map_bg_6", res);
			res = new map_bg_7();	ResList.AddArtResource("map_bg_7", res);
			res = new map_bg_8();	ResList.AddArtResource("map_bg_8", res);
			res = new map_bg_9();	ResList.AddArtResource("map_bg_9", res);
			res = new map_bg_10();	ResList.AddArtResource("map_bg_10", res);
			res = new map_bg_11();	ResList.AddArtResource("map_bg_11", res);
			res = new map_bg_12();	ResList.AddArtResource("map_bg_12", res);
			res = new map_bg_13();	ResList.AddArtResource("map_bg_13", res);
			res = new map_bg_14();	ResList.AddArtResource("map_bg_14", res);
			res = new map_bg_100();	ResList.AddArtResource("map_bg_100", res);
			
			var sound:Sound;
			//sound = new music();			ResList.AddSoundResource("music", sound);
			sound = new btn_click1();		ResList.AddSoundResource("button_click0", sound);
			sound = new dice_rolling();		ResList.AddSoundResource("dice_rolling", sound);
			sound = new battle_win();		ResList.AddSoundResource("battle_win", sound);
			sound = new battle_lose();		ResList.AddSoundResource("battle_lose", sound);
			sound = new error_dialog();		ResList.AddSoundResource("error_dialog", sound);
			sound = new game_over_win();	ResList.AddSoundResource("game_over_win", sound);
			sound = new game_over_lose();	ResList.AddSoundResource("game_over_lose", sound);
			sound = new chat_notif();		ResList.AddSoundResource("chat_notif", sound);
			sound = new new_unit_placed();	ResList.AddSoundResource("new_unit_placed", sound);
			sound = new start_turn_me();	ResList.AddSoundResource("start_turn_me", sound);
			sound = new turn_ending();		ResList.AddSoundResource("turn_ending", sound);
			sound = new turn_ending_fast();	ResList.AddSoundResource("turn_ending_fast", sound);
		}
	}
}