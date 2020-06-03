
class DataFactory {
	function HeartRate(){
		var hr = Activity.getActivityInfo().currentHeartRate;
		if(hr == null) {
			hr = ActivityMonitor.getHeartRateHistory(1, true).next().heartRate;
		}
		return [hr, "a"];
	}
	
	function Steps(){
		return [ActivityMonitor.getInfo().steps , "b"];
	}
	
	function Calories(){
		return;
	}
	
	function Altitude(){
		return;
	}
	
	function Stairs(){
		return;
	}
	
	function Battery(){
		return;
	}
	
	function DateF(){
		return;
	}


}
