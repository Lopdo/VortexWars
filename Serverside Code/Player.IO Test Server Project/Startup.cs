using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;

namespace DevelopmentTestServer {
	public static class Startup {
		[STAThread]
		static void Main() {
			// (Uncomment line to start server and make it simulate the user 'bob' connecting for 30 seconds)
			// (this is an easy way to debug serverside code)
			//
			//PlayerIO.DevelopmentServer.Server.StartWithDebugging("wargrounds-pvrpqmt1ee2jwqueof8ig", "public", "Wargrounds", "bob", "", 3000000);

			// Start the server and wait for incomming connection
			PlayerIO.DevelopmentServer.Server.StartWithDebugging();
		}
	}
}
