using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Math;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi;
using Toybox.Application;
using Toybox.System as Sys;
using Toybox.Activity;
using Toybox.ActivityMonitor;



class NathosView extends WatchUi.WatchFace
{
		var colBG  		 = 0x000000;
		var colDATE 	 = 0x555555;
		var colHOUR 	 = 0xFFFFFF;
		var colMIN 	 	 = 0x555555;
		var colLINE 	 = 0x555555;
		var colDatafield = 0x555555;
		var info, data;
		var barX, barWidth;
		var iconfont;
		var twlveclock = false;
		var showdate = true;
		var methodTop = method(:DateF);
		var methodLeft = method(:Steps);
		var methodRight = method(:HeartRate);
		var methodLeftBottom = method(:Battery);
		var methodRightBottom = method(:Calories);
		var methodBottomCenter = method(:Battery);
		
		var dayOfWeekArr    = [null, "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
		var monthOfYearArr  = [null, "January", "February", "March", "April", "May", "June", "July",
							         "August", "September", "Octotber", "November", "December"];
		
		
		
		var hourfont;
		var minutefont;
		var regfont = Graphics.FONT_SMALL;
		var scrRadius;
		var scrWidth, scrHeight;
		
		
	
		
		function initialize(){
			WatchFace.initialize();	
		
		}
		
		function getSettings(){
			info = ActivityMonitor.getInfo();
			var app = Application.getApp();
			colLINE = app.getProperty("colLine");
			colHOUR = app.getProperty("colHour");
			colMIN  = app.getProperty("colMin");
			colBG   = app.getProperty("colBg");
			colDATE = app.getProperty("colDate");
			colDatafield = app.getProperty("colDatafield");
			twlveclock = app.getProperty("twelvehclock");
			showdate = app.getProperty("showdate");
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
		
		function getField(value){
			if (value == 0) {
				return method(:HeartRate);
			} else if (value == 1){
				return method(:Steps);
			} else if (value == 2){
				return method(:Calories);
			} else if (value == 3){
				if ( (Toybox has :SensorHistory) && (Toybox.SensorHistory has :getElevationHistory)) {
					return method(:Altitude);
				} else {
					return method(:Invalid);
				} 
			} else if (value == 4){
				return method(:Battery);
			} else if (value == 5){
				if (Toybox.ActivityMonitor has :floorsClimbed) {
					return method(:Stairs);
				} else {
					return method(:Invalid);
				}
			} else if (value == 6){
				return method(:Messages);
			} else {
				return method(:EmptyF);
			}
		}
		
		function onLayout(dc){
			getSettings();
			scrWidth = dc.getWidth();
			scrHeight = dc.getHeight();
			scrRadius = scrWidth / 2;
			
			barWidth = scrWidth * 0.7;
			barX = scrWidth * 0.15;
			
			if (scrHeight < 190) {
					regfont = Graphics.FONT_MEDIUM;
			}
			
			
			
			
			iconfont = WatchUi.loadResource(Rez.Fonts.Icon);
			
			
				hourfont = WatchUi.loadResource(Rez.Fonts.Hour);
				minutefont = WatchUi.loadResource(Rez.Fonts.Minute);

			
	
		}
		
		function onUpdate(dc){
		
			dc.setColor(0, 0);
			dc.clear();
			
			
			
			if(showdate == true){
				drawDate(dc);
			}
			
			info = ActivityMonitor.getInfo();
			drawTime(dc);
			drawLine(dc);
			drawComplication1(dc);
			drawComplication2(dc);
			drawComplication3(dc);
			drawComplication4(dc);
			drawBattery(dc);
			
		}
		
		
		function drawComplication1(dc){
			
		
			 data = methodRight.invoke();
			dc.setColor(colDatafield, -1);
			dc.drawText(scrRadius - 30, scrRadius + 25, regfont, data[0], Graphics.TEXT_JUSTIFY_RIGHT);
			dc.drawText(scrRadius - 5, scrRadius + 32, iconfont, data[1], Graphics.TEXT_JUSTIFY_RIGHT);
					
			
		}
		
		function drawComplication2(dc){
			dc.setColor(colDatafield, -1);
			 data = methodLeft.invoke();
			dc.drawText(scrRadius + 30, scrRadius + 25, regfont, data[0], Graphics.TEXT_JUSTIFY_LEFT);
			dc.drawText(scrRadius + 5, scrRadius + 32, iconfont, data[1], Graphics.TEXT_JUSTIFY_LEFT);
			data = null;	
		}
		
		function drawComplication3(dc){
			dc.setColor(colDatafield, -1);
			 data = methodLeftBottom.invoke();
			dc.drawText(scrRadius - 30, scrRadius + 48, regfont, data[0], Graphics.TEXT_JUSTIFY_RIGHT);
			dc.drawText(scrRadius - 5, scrRadius + 55, iconfont, data[1], Graphics.TEXT_JUSTIFY_RIGHT);
			data = null;	
		}
		
		function drawComplication4(dc){
			dc.setColor(colDatafield, -1);
			 data = methodRightBottom.invoke();
			dc.drawText(scrRadius + 30, scrRadius + 48, regfont, data[0], Graphics.TEXT_JUSTIFY_LEFT);
			dc.drawText(scrRadius + 5, scrRadius + 55, iconfont, data[1], Graphics.TEXT_JUSTIFY_LEFT);
			data = null;	
		}
		
	
		

		function drawLine(dc){
			dc.setColor(colLINE, -1);
			dc.fillRectangle(barX, scrRadius + 20, barWidth, 5);
		}
		
		
		function drawBattery(dc){
				dc.setColor(colDatafield, -1);
				data = methodBottomCenter.invoke();
				dc.drawText(scrRadius, scrWidth - 30, regfont, data[0], Graphics.TEXT_JUSTIFY_CENTER);
		}
		 
		function drawTime(dc){
			var time;
			
			time = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
			dc.setColor(colHOUR, -1);
			dc.drawText(scrRadius -2, scrRadius - 60, hourfont, (twlveclock == false ? time.hour : (time.hour > 11 ? time.hour - 12 : time.hour)), Graphics.TEXT_JUSTIFY_RIGHT);
			dc.setColor(colMIN, -1);
			dc.drawText(scrRadius + 2, scrRadius - 60, minutefont, time.min.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT);
			time = null;
		}
		
		function drawDate(dc){
			dc.setColor(colDATE,-1);
			var datestring,time;
			time = Gregorian.info(Time.now(), Time.FORMAT_SHORT); 
			datestring = dayOfWeekArr[time.day_of_week] + " " + monthOfYearArr[time.month] + " " + time.day;
			dc.drawText(scrRadius, scrRadius - 80, regfont, datestring ,Graphics.TEXT_JUSTIFY_CENTER);
			time = null; datestring = null;
		}
		
		
		
		
	function HeartRate(){
		var hr = Activity.getActivityInfo().currentHeartRate;
		if(hr == null) {
			hr = ActivityMonitor.getHeartRateHistory(1, true).next().heartRate;
		}
		return [hr, "a"];
	}
	
	function Steps(){
		return [info.steps , "b"];
	}
	
	function Calories(){
		return [info.calories, "c" ];
	}
	
	function Altitude(){
		var altitude = Activity.getActivityInfo().altitude;
		if(altitude == null){
			var sample = SensorHistory.getElevationHistory({ :period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST })
						.next();
			if ((sample != null) && (sample.data != null)) {
					altitude = sample.data;
			}
		}
		if (altitude != null) {

			// Metres (no conversion necessary).
			if (Sys.getDeviceSettings().elevationUnits == System.UNIT_METRIC) {
					altitude = (altitude.toString() +  "m");
			} else { // then its feen
				altitude *=  3.28084; // every meter is 3.28 feet		
				altitude = (altitude.toString() + "ft");
			}
			
		} else {
			altitude = "--.--";
		}
		
		return [altitude.toNumber(), "d"];
	}
	
	function Stairs(){
		return [(info.floorsClimbed == null ?  "-.-" :  info.floorsClimbed), "f"];
	}
	
	function Battery(){
		
		return [((Sys.getSystemStats().battery + 0.5).toNumber().toString() + "%"), "g"];
	}
	
	function DateF(){
		return;
	}
	function EmptyF(){return ["", " "];}
	
	function Messages(){		
		return [ Sys.getDeviceSettings().notificationCount, "e"];
	}
	
	function Invalid (){
		return ["-.-", " "];
	}
	
	function alarmCount(){		
		return [ Sys.getDeviceSettings().alarmCount, "e"];
	}
	
	
}
