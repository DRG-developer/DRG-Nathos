// Copyright by Dexter Braunius.

using Toybox.Application;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

// This is the primary entry point of the application.
class NathosWatch extends Application.AppBase
{
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
			Sys.println("a");
			View.getSettings();
			Sys.println("b");
			Ui.requestUpdate();
			return;
	}
    
}
