// Copyright by Dexter Braunius.

using Toybox.Application;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

// This is the primary entry point of the application.
class NathosWatch extends Application.AppBase
{
	var counter = 0;
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
		if(data[0] == 200){
			counter = 0;
			Application.getApp().setProperty("weatherdata", data[1]);
		} else if ( counter < 3){
			counter ++;
		} else {
			Application.getApp().setProperty("weatherdata", null);
		}
	}
	
	function getServiceDelegate() {
		return [new NathosServiceDelegate()];
	}
    
}
