using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Math;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Background;
using Toybox.Position;
using Toybox.System as Sys;
using Toybox.Activity;
using Toybox.ActivityMonitor;



class NathosView extends WatchUi.WatchFace
{
		var venuOffset = [0, 0, 1];
		var sleeping, venuAlwaysOn;
		var colBG  		 = 0x000000;
		var colDATE 	 = 0x555555;
		var colHOUR 	 = 0xFFFFFF;
		var colMIN 	 	 = 0x555555;
		var colLINE 	 = 0x555555;
		var colDatafield = 0x555555;
		var info, data, settings, value, BtInd, zeroformat, bgData, weatherlookuptable;
		var barX, barWidth;
		var iconfont;
		var twlveclock = false;
		var showdate = true;
		
		/* ICONS MAPPER*/
		
		
		/*
		 * HEARTRATE:      A
		 * CALORIES:       B
		 * STEPS:          C
		 * ALTITUDE:       D
		 * MESSAGES:       E
		 * STAIRS:         F
		 * ALARM COUNT:    G
		 * BLUETOOTH:      H
		 * ACTIVE MINUTES: I
		 * BATTERY:        J
		 * DISTANCE WEEK:  K
		 * */
		
		
		var methodLeft = method(:Steps);
		var methodRight = method(:HeartRate);
		var methodLeftBottom = method(:Battery);
		var methodRightBottom = method(:Calories);
		var methodBottomCenter = method(:Battery);
		
		var dayOfWeekArr    = [null, "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
		var monthOfYearArr  = [null, "January", "February", "March", "April", "May", "June", "July",
							         "August", "September", "Octotber", "November", "December"];
		
		
		
		var hourfont, minutefont, weatherfont = WatchUi.loadResource(Rez.Fonts.inheritWeather);
		var regfont = Graphics.FONT_SMALL;
		var scrRadius;
		var scrWidth, scrHeight;
		
		
	
		
		function initialize(){
			WatchFace.initialize();	
		
		}
		
		function getSettings(){
		
			weatherlookuptable = null;
			info = ActivityMonitor.getInfo();
			var app = Application.getApp();
			venuAlwaysOn = app.getProperty("venuAlwaysOn");
			colLINE = app.getProperty("colLine");
			colHOUR = app.getProperty("colHour");
			colMIN  = app.getProperty("colMin");
			colBG   = app.getProperty("colBg");
			colDATE = app.getProperty("colDate");
			colDatafield = app.getProperty("colDatafield");
			twlveclock   = app.getProperty("twelvehclock");
			showdate     = app.getProperty("showdate");
			BtInd        = app.getProperty("BtIndicator");
			zeroformat   = app.getProperty("zeroformat");
		    methodLeft         = getField(app.getProperty("Field1"));
			methodLeftBottom   = getField(app.getProperty("Field2"));
			methodRight        = getField(app.getProperty("Field3"));
			methodRightBottom  = getField(app.getProperty("Field4"));
			methodBottomCenter = getField(app.getProperty("Field5"));
			if (app.getProperty("shortdate") == true) {
			    dayOfWeekArr    = [null, "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
				monthOfYearArr  = [null, "Jan", "Feb", "March", "April", "May", "June", "July",
							         "Aug", "Sep", "Oct", "Nov", "Dec"];
			}
			
			app = null;
			
		}
		
		function getField(values){
			
			if (values == -1) {
				return method(:EmptyF);
			}
			if (values == 0) {
				if (info has :getHeartRateHistory) {
					return method(:HeartRate);
				} else {
					return method(:Invalid);
				}
			} else if (values == 1){
				return method(:Calories);
				
			} else if (values == 2){
				return method(:Steps);
				
			} else if (values == 3){
				if ( (Toybox has :SensorHistory) && (Toybox.SensorHistory has :getElevationHistory)) {
					return method(:Altitude);
				} else {
					return method(:Invalid);
				} 
				
			} else if (values == 4){
				return method(:Battery);
				
			} else if (values == 5){
				if (info has :floorsClimbed) {
					return method(:Stairs);
				} else {
					return method(:Invalid);
				}
				
			} else if (values == 6){
				return method(:Messages);
				
			} else if (values == 7){
				return method(:Alarmcount);
			} else if (values == 8){
				return method(:PhoneConn);
			} else if (values == 9){
				if (info has :activeMinutesDay){
					return method(:ActiveMinutesDay);
				} else {
					return method(:Invalid);
				}
			} else if (values == 10){
				if (info has :activeMinutesWeek){
					return method(:ActiveMinutesWeek);
				} else {
					return method(:Invalid);
				}
			} else if (values == 11){
				return method(:DistanceDay);
			} else if (values == 12) {
				if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getTemperatureHistory)) {
					return method(:DeviceTemp);
				} else{
					 return method(:Invalid);
				}
			} else if (values == 13) {
				if ((Toybox.System has :ServiceDelegate)) {
					if (Authorize() == true){
						weatherlookuptable = {// Day icon               Night icon                Description
											"01d" => "h" /* 61453 */, "01n" => "f" /* 61486 */, // clear sky
											"02d" => "d" /* 61452 */, "02n" => "g" /* 61569 */, // few clouds
											"03d" => "f" /* 61442 */, "03n" => "h" /* 61574 */, // scattered clouds
											"04d" => "f" /* 61459 */, "04n" => "I" /* 61459 */, // broken clouds: day and night use same icon
											"09d" => "c" /* 61449 */, "09n" => "d" /* 61481 */, // shower rain
											"10d" => "g" /* 61448 */, "10n" => "c" /* 61480 */, // rain
											"11d" => "a" /* 61445 */, "11n" => "b" /* 61477 */, // thunderstorm
											"13d" => "b" /* 61450 */, "13n" => "e" /* 61482 */, // snow
											"50d" => "e" /* 61441 */, "50n" => "a" /* 61475 */, // mist
						};
						weatherfont = WatchUi.loadResource(Rez.Fonts.VWeather);
						Background.registerForTemporalEvent(new Time.Duration(Application.getApp().getProperty("updateFreq") * 60));
						return method(:Weather);
						
					} else {
						return method(:Premium);
					}
				} else {return method(:Invalid);}
			}
		}
		
		function onLayout(dc){
			if ((Toybox.System has :ServiceDelegate)) {
				Background.deleteTemporalEvent();
			}
			getSettings();
			scrWidth = dc.getWidth();
			scrHeight = dc.getHeight();
			scrRadius = scrWidth / 2;
			
			
			barWidth = scrWidth * 0.7;
			barX = scrWidth * 0.15;
			
			if (scrHeight < 209) {
					regfont = Graphics.FONT_MEDIUM;
			}
			
			iconfont = WatchUi.loadResource(Rez.Fonts.VIcon);
			hourfont = 17;//WatchUi.loadResource(Rez.Fonts.Hour);
			minutefont = 17;//WatchUi.loadResource(Rez.Fonts.Minute);
		}
		
		function venuAlwaysOnUpdate(dc){
			dc.setColor(colHOUR, -1);			
			dc.drawText(scrRadius + venuOffset[0], scrRadius - 40 + venuOffset[1], 15, (zeroformat == true ? Sys.getClockTime().hour.format("%02d") : Sys.getClockTime().hour), 0);
			dc.setColor(colMIN, -1);
			dc.drawText(scrRadius + venuOffset[0], scrRadius - 40 + venuOffset[1], 15, Sys.getClockTime().min.format("%02d"), 2);
			if(venuOffset[2] < 3){
				venuOffset[0] -= 8;
				venuOffset[1] -= 35;
				venuOffset[2] ++;
			} else if (venuOffset[2] < 7){
				venuOffset[0] += 8;
				venuOffset[1] += 35;
				venuOffset[2] ++;
			} else {
				venuOffset[0] -= 8;
				venuOffset[1] -= 35;
				venuOffset[2] = 0;	
			}			
		}
		
		function onEnterSleep() {
				sleeping = true;
		}
		
		function onExitSleep() {
				sleeping = false;
		}
		
		function onUpdate(dc){
			if (sleeping && venuAlwaysOn){
					dc.setColor(0, 0);
					dc.clear();
					venuAlwaysOnUpdate(dc);
					return;
			} else {
				venuOffset = [0, 0, 1];
				dc.setColor(0, colBG);
				dc.clear();		
				info     = ActivityMonitor.getInfo();
				settings = Sys.getDeviceSettings();
				
				
				if(showdate == true){
					drawDate(dc);
				}

				
				drawTime(dc);
				drawLine(dc);
				dc.setColor(colDatafield, -1);
				if(BtInd == true && settings.phoneConnected){
					dc.drawText(scrRadius, 20, iconfont, "h", Graphics.TEXT_JUSTIFY_CENTER);
				}
				
				drawComplication1(dc);
				drawComplication2(dc);
				drawComplication3(dc);
				drawComplication4(dc);
				drawBattery(dc);
			}
		}
		
		
		function drawComplication1(dc){	
			data = methodRight.invoke();
			dc.drawText(scrRadius - 50, scrRadius + 25, regfont, data[0], Graphics.TEXT_JUSTIFY_RIGHT);
			dc.drawText(scrRadius - 10, scrRadius + 32, iconfont, data[1], Graphics.TEXT_JUSTIFY_RIGHT);	
			dc.drawText(scrRadius - 10, scrRadius + 32, weatherfont, data[2], Graphics.TEXT_JUSTIFY_RIGHT);	
		}
		
		
		function drawComplication2(dc){
			data = methodLeft.invoke();
			dc.drawText(scrRadius + 50, scrRadius + 25, regfont, data[0], Graphics.TEXT_JUSTIFY_LEFT);
			dc.drawText(scrRadius + 10, scrRadius + 32, iconfont, data[1], Graphics.TEXT_JUSTIFY_LEFT);
			dc.drawText(scrRadius + 8, scrRadius + 32, weatherfont, data[2], Graphics.TEXT_JUSTIFY_LEFT);
		}
		
		
		function drawComplication3(dc){
			data = methodLeftBottom.invoke();
			dc.drawText(scrRadius - 50, scrRadius + 63, regfont, data[0], Graphics.TEXT_JUSTIFY_RIGHT);
			dc.drawText(scrRadius - 10, scrRadius + 70, iconfont, data[1], Graphics.TEXT_JUSTIFY_RIGHT);
			dc.drawText(scrRadius - 10, scrRadius + 70, weatherfont, data[2], Graphics.TEXT_JUSTIFY_RIGHT);
		}
		
		
		function drawComplication4(dc){
			data = methodRightBottom.invoke();
			dc.drawText(scrRadius + 50, scrRadius + 63, regfont, data[0], Graphics.TEXT_JUSTIFY_LEFT);
			dc.drawText(scrRadius + 10, scrRadius + 70, iconfont, data[1], Graphics.TEXT_JUSTIFY_LEFT);			
			dc.drawText(scrRadius + 8, scrRadius + 70, weatherfont, data[2], Graphics.TEXT_JUSTIFY_LEFT);			
		}
		
	
		function drawLine(dc){
			dc.setColor(colLINE, -1);
			dc.fillRectangle(barX, scrRadius + 20, barWidth, 5);
		}
		
		
		function drawBattery(dc){
				data = methodBottomCenter.invoke();
				dc.drawText(scrRadius, scrWidth - 40, regfont, data[0], Graphics.TEXT_JUSTIFY_CENTER);
				data = null;
		}
		 
		function drawTime(dc){
			var time;
			
			time = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
			dc.setColor(colHOUR, -1);
			var tmp = (twlveclock == false ? time.hour : (time.hour > 12 ? time.hour - 12 : time.hour));
			if (zeroformat == true){
				tmp = tmp.format("%02d");
			}
			dc.drawText(scrRadius -2, scrRadius - 110, hourfont, tmp, Graphics.TEXT_JUSTIFY_RIGHT);
			dc.setColor(colMIN, -1);
			dc.drawText(scrRadius + 2, scrRadius - 110, minutefont, time.min.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT);
			time = null; tmp = null;
		}
		
		function drawDate(dc){
			dc.setColor(colDATE,-1);
			var datestring,time;
			time = Gregorian.info(Time.now(), Time.FORMAT_SHORT); 
			datestring = dayOfWeekArr[time.day_of_week] + " " + monthOfYearArr[time.month] + " " + time.day;
			dc.drawText(scrRadius, scrRadius -140, regfont, datestring ,Graphics.TEXT_JUSTIFY_CENTER);
			time = null; datestring = null;
		}
		
		function Authorize() {
		//yes, in theory you could modify this code to always return true, and get the premium features. 
		// if you're going to do that, just realize that i provide everything except weather free of charge,
		// even the source code. a small donation would be appreciated...
		
			var tmpString = Application.getApp().getProperty("keys");
			if (tmpString == null) {return false;}
			if (tmpString.hashCode() == null) {return false;}
			

			 
			
			if (tmpString.hashCode()  == -1258539636) {
	
				return true;
			} else if (tmpString.hashCode() == -55185590){
				
				return true;
			} else {
				
				return false;
			}	
		
		}
		
	
	
	////////////////////////////
	/////     DATAFIELDS   /////
	/////     ONLY         /////
	/////     DATAFIELDS   /////
	/////     UNDER        /////
	/////     THIS         /////
	/////     PART         /////
	////////////////////////////
	
		
	function HeartRate(){
		value = Activity.getActivityInfo().currentHeartRate;
		if(value == null) {
			value = ActivityMonitor.getHeartRateHistory(1, true).next().heartRate;
		}
		return [value, "a", " "];
	}
	
	
	function Calories(){
		return [info.calories, "b", " " ];
	}
	
	
	function Steps(){
		return [info.steps , "c", " "];
	}
	

	function Altitude(){
		var value = Activity.getActivityInfo().altitude;
		if(value == null){
			 value = SensorHistory.getElevationHistory({ :period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST })
						.next();
			if ((value != null) && (value.data != null)) {
					value = value.data;
			}
		}
		if (value != null) {

			// Metres (no conversion necessary).
			if (settings.elevationUnits == System.UNIT_METRIC) {
				//value = value;
			} else { // then its feen
				value *=  3.28084; // every meter is 3.28 feet		
				//value = value.toNumber();	
				
			}
			
		} else {
			value = "-.-";
		}
		
		return [value.toNumber(), "d", " "];
	}
	
	
	function Messages(){		
		return [ settings.notificationCount, "e", " "];
	}
	
	
	function Stairs(){
		return [(info.floorsClimbed == null ?  "-.-" :  info.floorsClimbed), "f", " "];
	}
	
	
	function Alarmcount(){
		return [settings.alarmCount, "g", " "];
		
	}
	
	
	function PhoneConn(){
		
		if (settings.phoneConnected) {
			return ["conn", "h", " " ];
		} else {
			return ["dis", "h", " "];
		}
	}
	
	
	function ActiveMinutesDay(){
			return [info.activeMinutesDay.total.toNumber(), "i", " "];
	}
	
	
	function ActiveMinutesWeek(){
			return [info.activeMinutesWeek.total.toNumber(), "i", " "];
	}
	
	
	function Battery(){
		return [((Sys.getSystemStats().battery + 0.5).toNumber().toString() + "%"), "j", " "];
	}
	
	function DistanceWeek(){
		
	}
	
	function DistanceDay(){
			var unit;
			value = info.distance.toFloat();
			if(value == null){
				value = 0;
			} else {
				value *= 0.001;
			}
			
			if (settings.distanceUnits == System.UNIT_METRIC) {
				unit = "k";					
			} else {
				value *=  0.621371;  //mile per K;
				unit = "Mi";
			}
			
			return [value.format("%.1f").toString() + unit, "k", " "];
	}
	
	function DeviceTemp() {
		value = SensorHistory.getTemperatureHistory(null).next();
		if ((value != null) && (value.data != null)) {
			if (settings.temperatureUnits == System.UNIT_STATUTE) {
					value = (value.data * (1.8)) + 32; // Convert to Farenheit: ensure floating point division.
			} else {
					value = value.data;
			}
		
			return [value.toNumber().toString() + "°", "m", " "];
		}
		return ["-.-", ""];
	}
	
	function Weather(){
		var location = Activity.getActivityInfo().currentLocation; 

		
		if (location != null) {
				location = location.toDegrees(); // Array of Doubles.
				Application.getApp().setProperty("lat", (location[0].toFloat()) );
				Application.getApp().setProperty("lon", (location[1].toFloat()) );
		} else {
				location = Position.getInfo().position;
				if (location != null) {
						location = location.toDegrees();
						Application.getApp().setProperty("lat", (location[0].toFloat()) );
						Application.getApp().setProperty("lon", (location[1].toFloat()) );
				}
		}
		if(bgData == null ){
			return ["noData", " ", "i"];
		}

		
		return [bgData["temp"].toNumber() + "°", " ", weatherlookuptable[bgData["icon"]] ];
	}

	function EmptyF(){
		return ["", " ", " "];
	}
	

	function Invalid (){
		return ["-.-", " ", " "];
	}
	
	function Premium (){
		return ["activate!", " ", " "];
	}
	

	
	
}
