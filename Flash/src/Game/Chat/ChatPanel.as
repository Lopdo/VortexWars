package Game.Chat
{
	import Game.Game;
	
	import IreUtils.Input;
	import IreUtils.ResList;
	
	import Menu.Button;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import mx.utils.StringUtil;
	
	public class ChatPanel extends Sprite
	{
		private var chatBottom:TextField;
		private var chatBottomTextFormat:TextFormat;
		private var game:Game;
		
		private var chatLines:Array = new Array();
		private var visibleLines:Array = new Array();
		
		private var historyToggleButton:Button;
		private var historyUpButton:Button;
		private var historyDownButton:Button;
		
		private var historyMode:Boolean = false;
		private var historyFirstLineIndex:int;
		
		public function ChatPanel(g:Game)
		{
			super();
			
			game = g;
			
			x = 241;
			y = 0;
			
			var chatBottomBG:Sprite = new Sprite();
			chatBottomBG.addChild(ResList.GetArtResource("game_chatBg"));
			chatBottomBG.y = 566;
			addChild(chatBottomBG);
			
			chatBottomTextFormat = new TextFormat();
			chatBottomTextFormat.font = "Arial";
			chatBottomTextFormat.bold = true;
			chatBottomTextFormat.size = 14;
			chatBottomTextFormat.color = -1;
			
			chatBottom = new TextField();
			chatBottom.type = TextFieldType.INPUT;
			chatBottom.text = "Press enter to start typing";
			chatBottom.setTextFormat(chatBottomTextFormat);
			chatBottom.width = chatBottomBG.width - 40;
			chatBottom.height = 20;
			chatBottom.x = 10;
			chatBottom.y = chatBottomBG.y + chatBottomBG.height / 2 - chatBottom.height / 2;
			chatBottom.defaultTextFormat = chatBottomTextFormat;
			chatBottom.maxChars = 140;
			chatBottom.addEventListener(FocusEvent.FOCUS_IN, onGetFocus, false, 0, true);
			addChild(chatBottom);
			
			historyToggleButton = new Button(null, toggleHistory, ResList.GetArtResource("game_chatHistory"));
			historyToggleButton.x = 265;
			historyToggleButton.y = 569;
			addChild(historyToggleButton);
			
			historyUpButton = new Button(null, historyUp, ResList.GetArtResource("game_chatUp"));
			historyUpButton.x = 284;
			historyUpButton.y = 510;
			addChild(historyUpButton);
			
			historyDownButton = new Button(null, historyDown, ResList.GetArtResource("game_chatUp"));
			historyDownButton.x = 284;
			historyDownButton.scaleY = -1;
			historyDownButton.y = 540 + 18;
			addChild(historyDownButton);				
			
			historyUpButton.visible = false;
			historyDownButton.visible = false;
		}
		
		private function toggleHistory(button:Button):void {
			historyMode = !historyMode;
			
			historyToggleButton.removeChildAt(0);
			historyToggleButton.addChild(ResList.GetArtResource(historyMode ? "game_chatHistoryDown" : "game_chatHistory"));
			
			visibleLines.length = 0;
			
			historyUpButton.visible = historyMode;
			historyDownButton.visible = historyMode;
			
			var i:int;
			var line:ChatLine;
			
			for(i = 0; i < chatLines.length; ++i) {
				line = chatLines[i]; 
				line.setHistoryMode(historyMode);
				if(!line.fading)
					line.alpha = 0;
				
				if(contains(line))
					removeChild(line);
			}
			
			if(historyMode) {
				for(i = chatLines.length - 1; i >= 0 && i > chatLines.length - 5; --i) {
					historyFirstLineIndex = i;
					line = chatLines[i];
					addChild(line);
					visibleLines.splice(0, 0, line);
				} 
				
				setupVisibleLinesHeight();
			}
			else {
				for(i = chatLines.length - 1; i >= 0; --i) {
					line = chatLines[i];
					if(line.alpha == 0) {
						break;
					}
					
					addChild(line);
					visibleLines.splice(0, 0, line);
				} 
				
				setupVisibleLinesHeight();
			}
		}
		
		private function setupVisibleLinesHeight():void {
			var currHeight:int = 570;
			var line:ChatLine;
			
			for(var i:int = visibleLines.length - 1; i >= 0; --i) {
				line = visibleLines[i];
				
				if(historyMode) {
					if((visibleLines.length - 1) - i < 3) {
						line.alpha = 1;
					}
					else {
						line.alpha = 0.5; 
					}
				}

				currHeight -= line.height;
				line.y = currHeight;
			}
		}
		
		private function historyUp(button:Button):void {
			if(historyFirstLineIndex == 0) return;
			
			historyFirstLineIndex--;
			
			var line:ChatLine = visibleLines.pop();
			removeChild(line);
			
			line = chatLines[historyFirstLineIndex];
			addChild(line);
			visibleLines.splice(0, 0, line);
			
			setupVisibleLinesHeight();
		}
		
		private function historyDown(button:Button):void {
			//if there isn't full history and we received message while history was displayer we allow buttonDown to work
			if(chatLines.length < 4 && visibleLines.length < chatLines.length) {
				line = chatLines[visibleLines.length];
				addChild(line);
				visibleLines.push(line);
			}
			else {
				if(historyFirstLineIndex >= chatLines.length - 4) return;
				
				historyFirstLineIndex++;
				
				var line:ChatLine = visibleLines[0];
				visibleLines.splice(0, 1);
				removeChild(line);
				
				line = chatLines[historyFirstLineIndex + 3];
				addChild(line);
				visibleLines.push(line);
			}
			
			
			setupVisibleLinesHeight();
		}
		
		public function addMessage(colorID:int, name:String, message:String, isModerator:Boolean):void {
			if(G.user.isPlayerMuted(name)) return;
			
			var line:ChatLine = new ChatLine(name, colorID, message, isModerator);
			chatLines.push(line);

			if(!historyMode) {
				for each(var l:ChatLine in visibleLines) {
					l.y -= line.height;
				}
				
				line.y = 570 - line.height;
				visibleLines.push(line);
				addChild(line);
			}
		}
		
		public function update(timeDelta:Number):void {
			if(Input.IsKeyJustPressed(Input.KEY_ENTER)) {
				if(stage.focus == chatBottom) {
					if(StringUtil.trim(chatBottom.text).length > 0) {
						game.sendMessage(chatBottom.text);
					}
					chatBottom.text = "Press enter to start typing";
					stage.focus = null;
				}
				else {
					stage.focus = chatBottom;
				}
			}
			
			for each(var line:ChatLine in chatLines) {
				line.update(timeDelta);
				if(line.alpha == 0) {
					var idx:int = visibleLines.indexOf(line);
					if(idx != -1) {
						visibleLines.splice(idx, 1);
					}
				}
			}
		}
		
		private function onGetFocus(event:FocusEvent):void {
			if(chatBottom.text == "Press enter to start typing") {
				chatBottom.setSelection(0, 0);
				chatBottom.text = "";
			}
			else {
				chatBottom.setSelection(chatBottom.text.length, chatBottom.text.length);
			}
		}
	}
}