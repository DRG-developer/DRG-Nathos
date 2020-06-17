// Copyright by Dexter Braunius.

using Toybox.Application;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

// This is the primary entry point of the application.
class NathosWatch extends Application.AppBase
{
	var counter, cache;
	var View;
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }
    // This method runs each time the main application starts.
    function getInitialView() {
            View = new NathosView();
            Ui.requestUpdate();
            return [View];
        
    }
    
  function onSettingsChanged(){	
			View.getSettings();
			Ui.requestUpdate();
			return;
	}
	
	function onBackgroundData(data){
		Sys.println(data);
		if(data["response"] == 200){
			counter = 0;
			cache = data["weatherdata"];
			View.bgData = data["weatherdata"];
		} else if ( counter < 3){
			View.bgData = cache;
			counter ++;
		} 
	}
	
	function getServiceDelegate() {
		return [new NathosServiceDelegate()];
	}
    
}
