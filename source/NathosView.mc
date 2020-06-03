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
		
		var barX, barWidth;
		var iconfont;
		var twlveclock = false;
		var showdate = true;
		
		var methodTop = method(:DateF);
		var methodLeft = method(:Steps);
		var methodRight = method(:HeartRate);
		var methodLeftBottom = method(:Altitude);
		var methodRightBottom = method(:Messages);
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
			var app = Application.getApp();
			colLINE = app.getProperty("colLine");
			colHOUR = app.getProperty("colHour");
			colMIN = app.getProperty("colMin");
			colDATE = app.getProperty("colDate");
			colDatafield = app.getProperty("colDatafield");
			twlveclock = app.getProperty("twelvehclock");
			showdate = app.getProperty("showdate");
			app = null;
			
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
			drawTime(dc);
			drawLine(dc);
			drawComplication1(dc);
			drawComplication2(dc);
			drawBattery(dc);
			
		}
		
		
		function drawComplication1(dc){
			
		
			data = methodLeft.invoke();
			dc.setColor(colDatafield, -1);
			dc.drawText(scrRadius - 30, scrRadius + 25, regfont, data[0], Graphics.TEXT_JUSTIFY_RIGHT);
			dc.drawText(scrRadius - 5, scrRadius + 32, iconfont, data[1], Graphics.TEXT_JUSTIFY_RIGHT);
					
			
		}
		
		function drawComplication2(dc){
			dc.setColor(colDatafield, -1);
			var data;
			data = methodRight.invoke();
			dc.drawText(scrRadius + 30, scrRadius + 25, regfont, data[0], Graphics.TEXT_JUSTIFY_LEFT);
			dc.drawText(scrRadius + 5, scrRadius + 32, iconfont, data[1], Graphics.TEXT_JUSTIFY_LEFT);
			data = null;
		
		}
		

		function drawLine(dc){
			dc.setColor(colLINE, -1);
			dc.fillRectangle(barX, scrRadius + 20, barWidth, 5);
		}
		
		
		function drawBattery(dc){
				dc.setColor(colDatafield, -1);
				dc.drawText(scrRadius, scrWidth - 30, regfont, ((Sys.getSystemStats().battery + 0.5).toNumber().toString() + "%"), Graphics.TEXT_JUSTIFY_CENTER);
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
		
	
	
}
