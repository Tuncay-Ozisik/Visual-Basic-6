VERSION 5.00
Object = "{322B0848-B0B6-11D2-82F6-00105A14652C}#2.1#0"; "idldrawx2.ocx"
Begin VB.Form Ephemeris 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Astronomical Events"
   ClientHeight    =   6330
   ClientLeft      =   1785
   ClientTop       =   1905
   ClientWidth     =   5850
   BeginProperty Font 
      Name            =   "Arial"
      Size            =   8.25
      Charset         =   162
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   6330
   ScaleWidth      =   5850
   Begin IDLDRAWX2Lib.IDLDrawWidget IDLDrawWidget1 
      Height          =   495
      Left            =   2160
      TabIndex        =   5
      Top             =   5520
      Visible         =   0   'False
      Width           =   375
      _Version        =   131073
      _ExtentX        =   661
      _ExtentY        =   873
      _StockProps     =   97
      DrawWidgetName  =   "IDLDrawWidget2"
      BaseName        =   "IDLDrawWidget2Base"
      OnButtonPress   =   ""
      OnButtonRelease =   ""
      OnMotion        =   ""
      OnExpose        =   ""
      OnDblClick      =   ""
      OnInit          =   ""
      IdlPath         =   ""
      Xsize           =   25
      Ysize           =   33
      Xoffset         =   144
      Yoffset         =   368
      Xviewport       =   25
      Yviewport       =   33
      GraphicsLevel   =   1
      Retain          =   1
      Renderer        =   0
   End
   Begin VB.CommandButton Stop_Ephemeris_Button 
      BackColor       =   &H000000FF&
      Caption         =   "STOP Ephemeris"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   525
      Left            =   4590
      MaskColor       =   &H80000000&
      Style           =   1  'Graphical
      TabIndex        =   3
      Top             =   1290
      Width           =   1065
   End
   Begin VB.Timer Timer1 
      Enabled         =   0   'False
      Interval        =   1000
      Left            =   2640
      Top             =   5595
   End
   Begin VB.TextBox IDL_Output_Box 
      BackColor       =   &H00000000&
      BeginProperty Font 
         Name            =   "Tahoma"
         Size            =   8.25
         Charset         =   162
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H0000FF00&
      Height          =   5145
      Left            =   360
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      TabIndex        =   2
      Top             =   300
      Width           =   4095
   End
   Begin VB.CommandButton Start_Ephemeris_Button 
      BackColor       =   &H0000FF00&
      Caption         =   "START Ephemeris"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   4590
      Style           =   1  'Graphical
      TabIndex        =   1
      Top             =   600
      Width           =   1065
   End
   Begin VB.CommandButton Exit_button 
      BackColor       =   &H8000000B&
      Caption         =   "EXIT"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   5025
      Style           =   1  'Graphical
      TabIndex        =   0
      Top             =   5895
      Width           =   735
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      Caption         =   "Powered by IDL"
      BeginProperty Font 
         Name            =   "Microsoft Sans Serif"
         Size            =   12
         Charset         =   162
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   15
      TabIndex        =   4
      Top             =   5985
      Width           =   2055
   End
End
Attribute VB_Name = "Ephemeris"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
' This code calculates and displays Astronomical Events using IDL (Interactive Data Language)
' IDL (ver 4.0 and upper) must be installed with "astron" library.
'
Option Explicit

Public WorkingDirectory, NewDirectory, Directory_for_IDL, FileName, File As String
Dim n As Integer

Private Sub Form_Load()
    
    'Set the Palette of the VB form, to reduce the affect of color flashing with 256 colors
    Me.PaletteMode = vbPaletteModeCustom
        
    'To avoid the IDL path dialog box, enter your path to IDL here.
    IDLDrawWidget1.IdlPath = "c:\rsi\idl54\bin\bin.x86\idl32.dll"
    
    'Initialize IDL, Returns 1 on Success, 0 on Failure
    If IDLDrawWidget1.InitIDL(Me.hWnd) <> 1 Then
        MsgBox "Error initializing IDL."
        End
    End If
    
    'Create the draw widget
    IDLDrawWidget1.CreateDrawWidget
        
    'For displays > 256 colors, run this command
    'IDLDrawWidget1.ExecuteStr "Device, Decompose=0"

WorkingDirectory = "cd, '" + App.Path + "'"

IDLDrawWidget1.ExecuteStr (WorkingDirectory)
    
IDLDrawWidget1.SetOutputWnd (IDL_Output_Box.hWnd)

End Sub

Private Sub Events()

IDL_Output_Box.SetFocus: IDL_Output_Box = ""
 
n = IDLDrawWidget1.ExecuteStr(".COMPILE ephemeris.pro")

If n < 0 Then
        MsgBox "ephemeris.pro not found"
       End
        End If

IDLDrawWidget1.ExecuteStr ("ephemeris")

End Sub

Private Sub Timer1_Timer()

Events

End Sub

Private Sub Start_Ephemeris_Button_Click()

Timer1.Enabled = True

End Sub

Private Sub Stop_Ephemeris_Button_Click()

Timer1.Enabled = False

End Sub

Private Sub Exit_button_Click()

Timer1.Enabled = False
IDLDrawWidget1.DoExit
Unload Me

End Sub



