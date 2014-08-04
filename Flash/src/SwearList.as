package
{
	public class SwearList
	{
		private static const list:Array = ["fuck", "bitch", "dick", "pussy", "fag", "retard", "wank", "nigger", "negger", "shit", "cunt", "teabag", "slut", "cock", "ball sack", "ballsack", "arse", "faggot", " fag", "fag "];
		
		public function SwearList()
		{
		}
		
		public static function filter(text:String):String {
			for each(var s:String in list) {
				var r:RegExp = new RegExp(s, "gi");
				text = text.replace(r, "****");
			}
			return text;
		}
	}
}