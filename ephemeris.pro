PRO ephemeris

;***********************************************************************************************
;   ASTRONOMICAL EVENTS
;
;     Note that;
;
;   - Control Panel / International Settings / Regional Settings --> Select "English (US)"
;   - Requires ASTRON library.
;   - Tested with Norhern Hemisphere and East Longitudes.
;	- No high precision for the times of events.
;   - It can be used as stand-alone or with EPHEMERIS.VBP Visual Basic application.
;   - EPHEMERIS.INI file must be set according to location where ephemeris needed.
;
;	  													    April 24, 2010
;						                                     Tuncay OZISIK
;													  TUBITAK NATIONAL OBSERVATORY
;                                                               (TUG)
;
;   - Added "Useful astronomical hours"    Jan 24, 2016
;   - Added "Transit of the Sun"           Jan 26, 2016

;**********************************************************************************
;                       Variables and Dimensions
;**********************************************************************************


    BlankLine=''
      SiteTag=''
         Site=''
  LatitudeTag=''
     Latitude=''
 LongitudeTag=''
    Longitude=''
 ElevationTag=''
    Elevation=''
  TimezoneTag=''
     Timezone=''
    DayofYear=''
    TimeofObs=''
    Observers=''
     Temp_str=''
 Humidity_str=''
Barometer_str=''
     Wind_str=''

;******************************************************************
;  PLEASE ADJUST THE WORKING DIRECTORY IF YOU RUN THIS CODE ALONE
;******************************************************************

;Work_Dir="c:\rsi\idl54\work\my_pros\ephemeris"
;cd,Work_Dir

Pi=!dpi
Deg2Rad=360.0/(2*Pi)

; *************************
;  Read EPHEMERIS.INI File
; *************************
on_error,2

list=findfile('ephemeris.ini')
if N_ELEMENTS(list) EQ 0 then message, "No 'ephemeris.ini' file."
if N_ELEMENTS('ephemeris.ini') EQ 0 then message, "Empty 'ephemeris.ini' file."

close,1
OpenR,1,'ephemeris.ini'

WHILE NOT EOF(1) DO BEGIN

READF,1,SiteTag
READF,1,Site
READF,1,BlankLine

READF,1,LatitudeTag
READF,1,Latitude
READF,1,BlankLine

READF,1,LongitudeTag
READF,1,Longitude
READF,1,BlankLine

READF,1,ElevationTag
READF,1,Elevation
READF,1,BlankLine

READF,1,TimeZoneTag
READF,1,Timezone

ENDWHILE
CLOSE,1

     LATITUDE = DOUBLE(Latitude)     ; DD.dddd
    LONGITUDE = DOUBLE(Longitude)    ; DD.dddd  +:E, -:W
    ELEVATION = DOUBLE(Elevation)    ; m
     TIMEZONE = DOUBLE(Timezone)     ; hours
 Night_Lenght = 0.0


; ********************
; Start Calculations
; ********************
Result = BIN_DATE(SYSTIME())
DofY = ymd2dn(Result[0],Result[1],Result[2])

Year=STRMID(SYSTIME(/UTC), 20, 4)
Month=STRMID(SYSTIME(/UTC), 4, 3)
Day=STRMID(SYSTIME(/UTC), 8, 2)
Hour=STRMID(SYSTIME(/UTC), 11, 2)
Minute=STRMID(SYSTIME(/UTC), 14, 2)
Second=STRMID(SYSTIME(/UTC), 17, 2)
Local_Hours = Hour + Minute/60.0 + Second/3600.0

;**************************
;    DATE and TIME (UTC)
;**************************
Date=Year+" "+Month+" "+Day
Time=Hour+":"+Minute+":"+Second


;**************************
;       JULIAN DATE
;**************************
JD=SYSTIME(/JULIAN, /UTC)

;print,FORMAT='("JD efemeris -->",f15.7)',JD

;**************************
;   LOCAL SIDEREAL TIME
;**************************
CT2LST,LST,LONGITUDE,dummy,JD


LST_hour=floor(LST)
LST_min=(LST-LST_hour)*60
LST_sec=(LST_min-floor(LST_min))*60
LST_min=floor(LST_min)
LST_sec=floor(LST_sec)       ;Yýldýz zamani saniye hanesi duyarsiz
;LST_sec=(LST_sec*1000)/1000 ;Yýldýz zamani saniye hanesi duyarli


;**************************************
;         SUN: RA and DEC
;**************************************
; Note that the RAsun is calculated in DEG

SUNPOS,JD,RAsun,DECsun


;**************************************
;         SUN: HA and ALT
;**************************************
HAsun=LST-(RAsun/15.0)
sin_ALTsun= SIN(LATITUDE/Deg2Rad)*SIN(DECsun/Deg2Rad)+COS(LATITUDE/Deg2Rad)*COS(DECsun/Deg2Rad)*COS((HAsun*15)/Deg2Rad)
ALTsun=ASIN(sin_ALTsun)*Deg2Rad

if ALTsun GT 0.0 then begin
SUNpos="(Up)"
endif Else Begin
SUNpos="(Down)"
endelse


;******************************************
;  SUN: Rising, Setting and Twilight Times
;******************************************
; if sunrise time is desired:
t_rise = DofY + ((6 - LONGITUDE/15.0) / 24)

; if sunset time is desired:
t_set = DofY + ((18 - LONGITUDE/15.0) / 24)

; Source --> http://www.stjarnhimlen.se/comp/riset.html
;h = -0.833 degrees: Sun's upper limb touches the horizon; atmospheric refraction considered
;h = 0 degrees: Center of Sun's disk touches a mathematical horizon
;h = -0.25 degrees: Sun's upper limb touches a mathematical horizon
;h = -0.583 degrees: Center of Sun's disk touches the horizon; atmospheric refraction accounted for
;h = -0.833 degrees: Sun's upper limb touches the horizon; atmospheric refraction accounted for
;h = -6 degrees: Civil twilight (one can no longer read outside without artificial illumination)
;h = -12 degrees: Nautical twilight (navigation using a sea horizon no longer possible)
;h = -15 degrees: Amateur astronomical twilight (the sky is dark enough for most astronomical observations)
;h = -18 degrees: Astronomical twilight (the sky is completely dark)

h=(90+0.0)     ; Zenith distance of the Sun according to selected "h" above. The spherical triangle solution is below:
               ; cos(90+h)=cos(90-DECsun)*cos(90-Latitude)+sin(90-DECsun)*sin(90-Latitude)*cos(HAsun)

; HA of the sun for the given DEC of the Sun.
cos_HAsun=(COS(h/Deg2Rad)-(SIN(LATITUDE/Deg2Rad)*SIN(DECsun/Deg2Rad))) / (COS(LATITUDE/Deg2Rad)*COS(DECsun/Deg2Rad))

; SUNRISE
;--------------------------------------------------------------------------
HAsun_sunrise=ACOS(cos_HAsun)*Deg2Rad
HAsun_sunrise=360.0-HAsun_sunrise
Local_sunrise = HAsun_sunrise/15.0 + RAsun/15.0 - (0.06571 * t_rise) - 6.622

if Local_sunrise LT 0.0 then begin
Sunrise_UT=(Local_sunrise-LONGITUDE/15.0)+24
endif

if Local_sunrise GT 24.0 then begin
Sunrise_UT=(Local_sunrise-LONGITUDE/15.0)-24
endif

if Local_sunrise LT 24.0 and Local_sunrise GT 0.0 then begin
Sunrise_UT=Local_sunrise-LONGITUDE/15.0
endif

; Convert it to sexigesimal format (HH:MM:SS)
Sunrise_hms=SIXTY(Sunrise_UT)
Sunrise_h=Sunrise_hms[0]
Sunrise_m=Sunrise_hms[1]
Sunrise_s=Sunrise_hms[2]
;--------------------------------------------------------------------------


; SUNSET
;--------------------------------------------------------------------------
HAsun_sunset=ACOS(cos_HAsun)*Deg2Rad
Local_sunset = HAsun_sunset/15.0 + RAsun/15.0 - (0.06571 * t_set) - 6.622

if Local_sunset LT 0.0 then begin
Sunset_UT=(Local_sunset-LONGITUDE/15.0)+24
endif

if Local_sunset GT 24.0 then begin
Sunset_UT=(Local_sunset-LONGITUDE/15.0)-24
endif

if Local_sunset LT 24.0 and Local_sunset GT 0.0 then begin
Sunset_UT=Local_sunset-LONGITUDE/15.0
endif

; Convert it to sexigesimal format (HH:MM:SS)
Sunset_hms=SIXTY(Sunset_UT)
Sunset_h=Sunset_hms[0]
Sunset_m=Sunset_hms[1]
Sunset_s=Sunset_hms[2]
;----------------------------------------------------------------------------


; ASTRONOMICAL TWILIGHT (Ending Time)
;----------------------------------------------------------------------------
h=-18

; HA of the sun for the given DEC of the Sun.
cos_HAsun_twiend=(SIN(h/Deg2Rad)-(SIN(LATITUDE/Deg2Rad)*SIN(DECsun/Deg2Rad))) / (COS(LATITUDE/Deg2Rad)*COS(DECsun/Deg2Rad))

HAsun_twiend=ACOS(cos_HAsun_twiend)*Deg2Rad
Local_twiend= HAsun_twiend/15.0 + RAsun/15.0 - (0.06571 * t_set) - 6.622

if Local_twiend LT 0.0 then begin
EndTwi_UT=(Local_twiend-LONGITUDE/15.0)+24
endif

if Local_twiend GT 24.0 then begin
EndTwi_UT=(Local_twiend-LONGITUDE/15.0)-24
endif

if Local_twiend LT 24.0 and Local_twiend GT 0.0 then begin
EndTwi_UT=Local_twiend-LONGITUDE/15.0
endif

; Convert it to sexigesimal format (HH:MM:SS)
EndTwi_hms=SIXTY(EndTwi_UT)
EndTwi_h=EndTwi_hms[0]
EndTwi_m=EndTwi_hms[1]
EndTwi_s=EndTwi_hms[2]
;----------------------------------------------------------------------------


; ASTRONOMICAL TWILIGHT (Starting Time)
;----------------------------------------------------------------------------
h=-18

; HA of the sun for the given DEC of the Sun.
cos_HAsun_TwiSta=(SIN(h/Deg2Rad)-(SIN(LATITUDE/Deg2Rad)*SIN(DECsun/Deg2Rad))) / (COS(LATITUDE/Deg2Rad)*COS(DECsun/Deg2Rad))

HAsun_TwiSta=ACOS(cos_HAsun_TwiSta)*Deg2Rad
HAsun_TwiSta=360.0-HAsun_TwiSta
Local_TwiSta= HAsun_TwiSta/15.0 + RAsun/15.0 - (0.06571 * t_rise) - 6.622

if Local_TwiSta LT 0.0 then begin
StaTwi_UT=(Local_TwiSta-LONGITUDE/15.0)+24
endif

if Local_TwiSta GT 24.0 then begin
StaTwi_UT=(Local_TwiSta-LONGITUDE/15.0)-24
endif

if Local_TwiSta LT 24.0 and Local_TwiSta GT 0.0 then begin
StaTwi_UT=Local_TwiSta-LONGITUDE/15.0
endif

; Convert it to sexigesimal format (HH:MM:SS)
StaTwi_hms=SIXTY(StaTwi_UT)
StaTwi_h=StaTwi_hms[0]
StaTwi_m=StaTwi_hms[1]
StaTwi_s=StaTwi_hms[2]
;----------------------------------------------------------------------------


;*************************************
;            Equation of Time
;*************************************

; Asagidaki kod dakika hassasiyetinde
;B=(360.0/365.0)*(DofY-81)
;Dt=9.87*SIN((2*B)/Deg2Rad)-7.53*COS(B/Deg2Rad)-1.5*SIN(B/Deg2Rad)
;DT_hms=SIXTY(Dt)
;print, format='(10X,"Equation of Time = ",i3.2,":",i2.2,":",i2.2)',DT_hms(0),DT_hms(1),DT_hms(2)

; Almanak 2016 dan +- 3sn hassas formul ama ozellikle 2016 icin
;L=279.105+0.985647*DofY
;L=L/Deg2Rad
;EoT=(-109.5*SIN(L)+596.0*SIN(2*L)+4.5*SIN(3*L)-12.7*SIN(4*L)-427.9*COS(L)-2.1*COS(2*L)+19.2*COS(3*L))/60.0
;EoT_hms=SIXTY(EoT)
;print, format='(10X,"Equation of Time = ",i3.2,":",i2.2,":",i2.2)',EoT_hms(0),EoT_hms(1),EoT_hms(2)


; /lib/astron/pro altinda internetten bulunan "sunrise.pro" dan
;print,sunrise(DofY,Year,lat=LATITUDE,lon=LONGITUDE)
sun=sunrise(DofY,Year,lat=LATITUDE,lon=LONGITUDE)

EoT=Sun[2]  ; 0:Sunrise (UT), 1:Sunset (UT), 2:Transit (UT), 3:Lenght of Day (hr)
EoT_hms=SIXTY(EoT)
;print, format='(10X,"Equation of Time = ",i3.2,":",i2.2,":",i2.2)',EoT_hms(0),EoT_hms(1),EoT_hms(2)

;sr_hms=SIXTY(sun(0)+TIMEZONE)
;print, format='(10X,"sunrise = ",i3.2,":",i2.2,":",i2.2)',sr_hms(0),sr_hms(1),sr_hms(2)
;----------------------------------------------------------------------------


;*************************************
;    Useful Astronomical Dark Time
;*************************************
Night_Lenght = (24.0-EndTwi_UT) + StaTwi_UT


;**************************************
;         MOON: RA and DEC
;**************************************
; Note that the RAmoon is calculated in DEG
MOONPOS,JD,RAmoon,DECmoon


;**************************************
;         MOON: HA and ALT
;**************************************
HAmoon=LST-(RAmoon/15.0)
sin_ALTmoon= SIN(LATITUDE/Deg2Rad)*SIN(DECmoon/Deg2Rad)+COS(LATITUDE/Deg2Rad)*COS(DECmoon/Deg2Rad)*COS((HAmoon*15)/Deg2Rad)
ALTmoon=ASIN(sin_ALTmoon)*Deg2Rad

if ALTmoon GT 0.0 then begin
MOONpos="(Up)"
endif Else Begin
MOONpos="(Down)"
endelse


;**************************************
;         MOON: Phase
;**************************************
MPHASE, JD, MoonPhase


;******************
;   PRINT SCREEN
;******************
Print
Print, '----------| ASTRONOMICAL STATUS |----------'
print, ""
print, 'UT Date : ',Date
print, JD,FORMAT='(8X,"JD :",f13.4)'
print, '     UTC : ',Time
print, format='("      LST : ",i2.2,":",i2.2,":",i2.2)',LST_hour,LST_min,LST_sec
print
print, "[SUN]"
print, "           RA DEC =", ADSTRING(RAsun,DECsun)
print, ALTsun, format='(11X,"Altitude = ",F6.2,$)'
print, "    ",SUNpos
print, format='(16X,"Rise = ",i2.2,":",i2.2,":",i2.2,"  UT")',Sunrise_h,Sunrise_m,Sunrise_s
print, format='(12X,"Transit = ",i3.2,":",i2.2,":",i2.2," UT")',EoT_hms[0],EoT_hms[1],EoT_hms[2]
print, format='(17X,"Set = ",i2.2,":",i2.2,":",i2.2, "  UT")',Sunset_h,Sunset_m,Sunset_s
print, format='(3X,"Twilight Ends = ",i2.2,":",i2.2,":",i2.2, "  UT")',EndTwi_h,EndTwi_m,EndTwi_s
print, format='(1X,"Twilight Starts = ",i2.2,":",i2.2,":",i2.2, "  UT")',StaTwi_h,StaTwi_m,StaTwi_s
print, format='(4X,"Useful Night = ",d4.1, " hours")',Night_Lenght
print
print, "[MOON]"
print, "          RA DEC =", ADSTRING(RAmoon,DECmoon)
print, ALTmoon, format='(10X,"Altitude =",F6.2,$)'
print, "   ",MOONpos
print,MoonPhase,format='(12X,"Phase =",F6.3)'
print, "----------------------------------------------------

end