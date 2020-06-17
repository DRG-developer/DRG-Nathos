using Toybox.Background;
using Toybox.Activity;
using Toybox.Application;
using Toybox.Communications as Comms;
using Toybox.System as Sys;

(:background)
class NathosServiceDelegate extends Toybox.System.ServiceDelegate{ 
	var unit = "metric";
	(:background_method)
	function initialize() {
		Sys.ServiceDelegate.initialize();
		if (Sys.getDeviceSettings().temperatureUnits == System.UNIT_STATUTE){
			unit = "imperial";
		}
	}
	(:background_method)
    function onTemporalEvent() {
       
		getWeather();
       
    }
    (:background_method)
    function getWeather(){
		var lat, lon;
	
		lat = Application.getApp().getProperty("lat");
		lon = Application.getApp().getProperty("lon");
	
		Comms.makeWebRequest("https://api.openweathermap.org/data/2.5/weather", 
					/*
					 * URL
					 */ 
					
					{
						"lat"   => lat,
						"lon"   => lon,
						"appid" => "d72271af214d870eb94fe8f9af450db4",
						"units" => unit // Celcius.
					},
					
					/*
					 * PARAMS 
					 */
					
					{
						:method       => Comms.HTTP_REQUEST_METHOD_GET,
						:headers      => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED},
						:responseType => Comms.HTTP_RESPONSE_CONTENT_TYPE_JSON
					},
					/*
					 * OPTIONS
					 */
					
					method(:onReceiveWeatherdata));
		
	}
	
	(:background_method)
	function onReceiveWeatherdata(response, data){
		if(response != 200){
			Sys.println(response);
			Background.exit({"response" => response});
		} else {
			var result = {
				"cod" => data["cod"],
				"lat" => data["coord"]["lat"],
				"lon" => data["coord"]["lon"],
				"dt" => data["dt"],
				"temp" => data["main"]["temp"],
				"humidity" => data["main"]["humidity"],
				"icon" => data["weather"][0]["icon"]
			};
				
			Background.exit({"weatherdata" => result, "response" => response});
		}
	}

}
