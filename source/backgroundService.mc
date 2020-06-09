/*
(:background)
class BgbgServiceDelegate extends Toybox.System.ServiceDelegate {
	
	function initialize() {
		Sys.ServiceDelegate.initialize();
		inBackground=true;				//trick for onExit()
	}
	
    function onTemporalEvent() {
    	var now=Sys.getClockTime();
    	var ts=now.hour+":"+now.min.format("%02d");
        Sys.println("bg exit: "+ts);
        //just return the timestamp
        Background.exit(ts);
    }
    

}
*/
