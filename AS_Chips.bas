B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=11.5
@EndOfDesignText@
#If Documentation
Updates
V1.00
	-Release
V1.01
	-Add some properties
V1.02
	-Add AddChip2 - with one more parameter
		-ChipColor
V1.03
	-Add Clear - removes all chips
	-Add get and set GapBetween
V1.04
	-Add Event CustomDrawChip
	-Add Event EmptyAreaClick
V1.05
	-Add Index to ASChips_Chip Type
#End If

#DesignerProperty: Key: BackgroundColor, DisplayName: Background Color, FieldType: Color, DefaultValue: 0xFF000000
#DesignerProperty: Key: AutoExpand, DisplayName: Auto Expand, FieldType: Boolean, DefaultValue: False, Description: Increases or decreases the size of the view depending on how many chips are added. The HeightChanged event is triggered.
#DesignerProperty: Key: ShowRemoveIcon, DisplayName: Show Remove Icon, FieldType: Boolean, DefaultValue: False, Description: Displays a Remove icon which can be clicked on
#DesignerProperty: Key: Round, DisplayName: Round, FieldType: Boolean, DefaultValue: True, Description: Makes the chips round
#DesignerProperty: Key: CornerRadius, DisplayName: Corner Radius, FieldType: Int, DefaultValue: 5, MinRange: 0, Description: Only affected if Round = False

#Event: ChipClick (Chip As ASChips_Chip)
#Event: ChipLongClick (Chip As ASChips_Chip)
#Event: ChipRemoved (Chip As ASChips_Chip)
#Event: HeightChanged (Height As Float)
#Event: HiddenChipsClicked (ListChips As List)
#Event: CustomDrawChip(Item As ASChips_CustomDraw)
#Event: EmptyAreaClick

Sub Class_Globals
	
	Type ASChips_Chip(Text As String,Icon As B4XBitmap,Tag As Object,Index As Int)
	Type ASChips_ChipProperties(Height As Float,BackgroundColor As Int,TextColor As Int,xFont As B4XFont,CornerRadius As Float,BorderSize As Float,TextGap As Float)
	Type ASChips_RemoveIconProperties(BackgroundColor As Int,TextColor As Int)
	Type ASChips_Views(BackgroundPanel As B4XView,TextLabel As B4XView,IconImageView As B4XView,RemoveIconLabel As B4XView)
	Type ASChips_CustomDraw(Chip As ASChips_Chip,ChipProperties As ASChips_ChipProperties,Views As ASChips_Views)
	
	Private mEventName As String 'ignore
	Private mCallBack As Object 'ignore
	Public mBase As B4XView
	Private xui As XUI 'ignore
	Public Tag As Object
	Private xpnl_ChipBackground As B4XView
	Private xpnl_HiddenChips As B4XView
	
	Private m_GapBetween As Float
	Private m_BackgroundColor As Int
	Private m_ShowRemoveIcon As Boolean
	Private m_AutoExpand As Boolean
	Private m_Round As Boolean
	
	Private g_ChipProperties As ASChips_ChipProperties
	Private g_RemoveIconProperties As ASChips_RemoveIconProperties
	
	Private list_Chips As List
	
End Sub

Public Sub Initialize (Callback As Object, EventName As String)
	mEventName = EventName
	mCallBack = Callback
	list_Chips.Initialize
End Sub

'Base type must be Object
Public Sub DesignerCreateView (Base As Object, Lbl As Label, Props As Map)
	mBase = Base
    Tag = mBase.Tag
    mBase.Tag = Me 
	IniProps(Props)
	mBase.Color = xui.Color_Transparent
	xpnl_ChipBackground = xui.CreatePanel("BaseChipBackground")
	mBase.AddView(xpnl_ChipBackground,0,0,0,0)
	
	xpnl_HiddenChips = xui.CreatePanel("xpnl_HiddenChips")
	mBase.AddView(xpnl_HiddenChips,0,0,0,0)
	
	Dim xlbl_HiddenChips As B4XView = CreateLabel("")
	xpnl_HiddenChips.AddView(xlbl_HiddenChips,0,0,0,0)
	
	#If B4A
	Base_Resize(mBase.Width,mBase.Height)
	#End If
End Sub

Private Sub IniProps(Props As Map)
	
	m_BackgroundColor = xui.PaintOrColorToColor(Props.Get("BackgroundColor"))
	m_ShowRemoveIcon = Props.Get("ShowRemoveIcon")
	m_AutoExpand = Props.Get("AutoExpand")
	m_Round = Props.Get("Round")
	
	m_GapBetween = 5dip
	
	g_ChipProperties = CreateASChips_ChipProperties(22dip,xui.Color_Black,xui.Color_White,xui.CreateDefaultFont(14),DipToCurrent(Props.Get("CornerRadius")),0,3dip)
	g_RemoveIconProperties = CreateASChips_RemoveIconProperties(xui.Color_Black,xui.Color_White)
	
End Sub

Private Sub Base_Resize (Width As Double, Height As Double)
	xpnl_ChipBackground.SetLayoutAnimated(0,0,0,Width,IIf(xpnl_ChipBackground.NumberOfViews > 0 And m_AutoExpand = True,xpnl_ChipBackground.GetView(xpnl_ChipBackground.NumberOfViews -1).top + xpnl_ChipBackground.GetView(xpnl_ChipBackground.NumberOfViews -1).Height,Height))
	RefreshChips
End Sub

#If B4J
Private Sub BaseChipBackground_MouseClicked (EventData As MouseEvent)
#Else
Private Sub BaseChipBackground_Click
#End If
	EmptyAreaClick
End Sub

Public Sub AddChip(Text As String,Icon As B4XBitmap,xTag As Object)
	AddChipIntern(Text,Icon,g_ChipProperties.BackgroundColor,xTag)
End Sub

Public Sub AddChip2(Text As String,Icon As B4XBitmap,ChipColor As Int,xTag As Object)
	AddChipIntern(Text,Icon,ChipColor,xTag)
End Sub

Private Sub AddChipIntern(Text As String,Icon As B4XBitmap,ChipColor As Int,xTag As Object)
	Dim ChipProperties As ASChips_ChipProperties = CreateASChips_ChipProperties(g_ChipProperties.Height,ChipColor,g_ChipProperties.TextColor,g_ChipProperties.xFont,g_ChipProperties.CornerRadius,g_ChipProperties.BorderSize,g_ChipProperties.TextGap)
	
	Dim Chip As ASChips_Chip
	Chip.Text = Text
	Chip.Icon = Icon
	Chip.Tag = xTag
	Chip.Index = list_Chips.Size
	
	Dim xpnl_Background As B4XView = xui.CreatePanel("xpnl_ChipBackground")
	
	Dim xlbl_Text As B4XView = CreateLabel("")
	xpnl_Background.AddView(xlbl_Text,0,0,0,0)
	
	Dim xiv_Icon As B4XView = CreateImageView("")
	xpnl_Background.AddView(xiv_Icon,0,0,0,ChipProperties.Height)
	
	Dim xlbl_RemoveIcon As B4XView = CreateLabel("xlbl_RemoveIcon")
	xpnl_Background.AddView(xlbl_RemoveIcon,0,0,0,0)
	
	xpnl_ChipBackground.AddView(xpnl_Background,0,0,0,0)

	list_Chips.Add(CreateMap("Chip":Chip,"ChipProperties":ChipProperties))
End Sub

Public Sub RefreshChips

	xpnl_ChipBackground.Color = m_BackgroundColor
	Dim FontGap As Float = IIf(xui.IsB4J,6dip,0dip)
	Dim LastItemWhatVisible As Int = 0

	Dim CurrentLevel As Int = 0
	Dim BackgroundHeight As Float = xpnl_ChipBackground.Height
	Dim OldBackgroundHeight As Float = BackgroundHeight
	For i = 0 To list_Chips.Size -1
		
		Dim Chip As ASChips_Chip = list_Chips.Get(i).As(Map).Get("Chip")
		Dim ChipProperties As ASChips_ChipProperties = list_Chips.Get(i).As(Map).Get("ChipProperties")
		
		Dim HaveIcon As Boolean = IIf(Chip.Icon <> Null And Chip.Icon.IsInitialized = True,True,False)
		
		Dim LastChip As B4XView
		If i > 0 Then
			LastChip = xpnl_ChipBackground.GetView(i -1)
		End If
		
		'************Sizing********************************
		Dim Left As Float = IIf(LastChip.IsInitialized = True,LastChip.Left + LastChip.Width,0) + m_GapBetween
		Dim Width As Float = MeasureTextWidth(Chip.Text,ChipProperties.xFont) + FontGap + ChipProperties.TextGap*3
		
		If m_ShowRemoveIcon = True Then Width = Width + IIf(xui.IsB4J,ChipProperties.Height/1.5,ChipProperties.Height)
		If HaveIcon = True Then Width = Width + ChipProperties.Height/1.3
		
		If Left + Width + m_GapBetween >= xpnl_ChipBackground.Width Then
			If m_AutoExpand = False And (ChipProperties.Height*(CurrentLevel+1))+5dip*(CurrentLevel+1) + ChipProperties.Height > mBase.Height Then
				CurrentLevel = CurrentLevel
			Else
				CurrentLevel = CurrentLevel +1
			End If
		End If
		Dim Top As Float = (ChipProperties.Height*CurrentLevel)+5dip*CurrentLevel
		If LastChip.IsInitialized = True Then
			Left = IIf(CurrentLevel <> LastChip.Tag,0 + m_GapBetween,Left + m_GapBetween)
		End If
		
		'************Container********************************
		Dim xpnl_Background As B4XView = xpnl_ChipBackground.GetView(i)
		xpnl_Background.Tag = CurrentLevel
		xpnl_Background.SetLayoutAnimated(0,Left,Top,Width,ChipProperties.Height)
		xpnl_Background.SetColorAndBorder(ChipProperties.BackgroundColor,ChipProperties.BorderSize,0,IIf(m_Round = True,ChipProperties.Height/2, ChipProperties.CornerRadius))
		
		If m_AutoExpand = False And Left + Width + MeasureTextWidth("+" & (list_Chips.Size - LastItemWhatVisible),g_ChipProperties.xFont) + FontGap + m_GapBetween + ChipProperties.TextGap*3 > mBase.Width Then
			xpnl_Background.Visible = False
			
			Dim LastVisibleItem As B4XView = xpnl_ChipBackground.GetView(LastItemWhatVisible)
			
			If LastItemWhatVisible = 0 Then
				xpnl_HiddenChips.SetLayoutAnimated(0,m_GapBetween,0,MeasureTextWidth("+" & (list_Chips.Size - LastItemWhatVisible),g_ChipProperties.xFont) + FontGap + ChipProperties.TextGap*3,g_ChipProperties.Height)
				Else
				xpnl_HiddenChips.SetLayoutAnimated(0,LastVisibleItem.Left + LastVisibleItem.Width + m_GapBetween,LastVisibleItem.Top,MeasureTextWidth("+" & (list_Chips.Size - LastItemWhatVisible),g_ChipProperties.xFont) + FontGap + ChipProperties.TextGap*3,g_ChipProperties.Height)
			End If
			
			xpnl_HiddenChips.SetColorAndBorder(g_ChipProperties.BackgroundColor,0,0,xpnl_HiddenChips.Height/2)
			
			Dim xlbl_HiddenChips As B4XView = xpnl_HiddenChips.GetView(0)
			xlbl_HiddenChips.TextColor = g_ChipProperties.TextColor
			xlbl_HiddenChips.SetLayoutAnimated(0,0,0,xpnl_HiddenChips.Width,xpnl_HiddenChips.Height)
			xlbl_HiddenChips.SetTextAlignment("CENTER","CENTER")
			xlbl_HiddenChips.Text = "+" & (list_Chips.Size - LastItemWhatVisible)
			xpnl_HiddenChips.Visible = True
		Else
			xpnl_HiddenChips.Visible = False
			xpnl_Background.Visible = True
			LastItemWhatVisible = i
		End If
		xpnl_HiddenChips.Tag = LastItemWhatVisible
		
		'************Text********************************
		Dim xlbl_Text As B4XView = xpnl_Background.GetView(0)
		xlbl_Text.TextColor = ChipProperties.TextColor
		xlbl_Text.SetTextAlignment("CENTER","CENTER")
		xlbl_Text.Font = ChipProperties.xFont
		xlbl_Text.SetLayoutAnimated(0,ChipProperties.TextGap + IIf(HaveIcon = True,ChipProperties.Height/1.3,0),0,MeasureTextWidth(Chip.Text,ChipProperties.xFont) + FontGap + ChipProperties.TextGap,ChipProperties.Height)
		
		xlbl_Text.Text = Chip.Text
		
		'************Icon********************************
		Dim xiv_Icon As B4XView = xpnl_Background.GetView(1)
		If HaveIcon Then
			
			Dim HeightWidth As Float = ChipProperties.Height/1.3
			xiv_Icon.SetLayoutAnimated(0,ChipProperties.Height/2 - HeightWidth/2,xpnl_Background.Height/2 - HeightWidth/2,HeightWidth,HeightWidth)
			xiv_Icon.SetBitmap(Chip.Icon.Resize(xiv_Icon.Width,xiv_Icon.Height,True))
			
		End If
		xiv_Icon.Visible = HaveIcon
		'************RemoveIcon********************************
		Dim xlbl_RemoveIcon As B4XView = xpnl_Background.GetView(2)
		xlbl_RemoveIcon.Tag = i
		If m_ShowRemoveIcon = True Then
			
			Dim HeightWidth As Float = ChipProperties.Height/1.5
			
			xlbl_RemoveIcon.Font = xui.CreateMaterialIcons(9)
			xlbl_RemoveIcon.Text = Chr(0xE5CD)
			xlbl_RemoveIcon.SetTextAlignment("CENTER","CENTER")
			xlbl_RemoveIcon.SetColorAndBorder(g_RemoveIconProperties.BackgroundColor,0,0,HeightWidth/2)
			xlbl_RemoveIcon.TextColor = g_RemoveIconProperties.TextColor
			
			
			xlbl_RemoveIcon.SetLayoutAnimated(0,xpnl_Background.Width - ChipProperties.Height/2 - HeightWidth/2,xpnl_Background.Height/2 - HeightWidth/2,HeightWidth,HeightWidth)
			xlbl_RemoveIcon.Visible = True
		Else
			xlbl_RemoveIcon.Visible = False
		End If
		
		BackgroundHeight = xpnl_Background.Top + xpnl_Background.Height
		
		CustomDrawChip(CreateASChips_CustomDraw(Chip,ChipProperties,CreateASChips_Views(xpnl_Background,xlbl_Text,xiv_Icon,xlbl_RemoveIcon)))
		
	Next
	
	If m_AutoExpand = True Then
		If OldBackgroundHeight <> BackgroundHeight And BackgroundHeight <> mBase.Height Then HeightChanged(BackgroundHeight)
		xpnl_ChipBackground.Height = BackgroundHeight
		mBase.Height = xpnl_ChipBackground.Height
	Else
		xpnl_ChipBackground.Height = mBase.Height
		
	End If
	
End Sub

#Region Properties

Public Sub getGapBetween As Float
	Return m_GapBetween
End Sub

Public Sub setGapBetween(Gap As Float)
	m_GapBetween = Gap
End Sub

Public Sub Clear
	list_Chips.Clear
	xpnl_ChipBackground.RemoveAllViews
End Sub

Public Sub getSize As Int
	Return list_Chips.Size
End Sub
'Call RefreshChips if you change something
Public Sub getRemoveIconProperties As ASChips_RemoveIconProperties
	Return g_RemoveIconProperties
End Sub
'Can only influence the appearance before the respective chip has been added
Public Sub getChipPropertiesGlobal As ASChips_ChipProperties
	Return g_ChipProperties
End Sub

Public Sub RemoveChip(Index As Int)
	If Index >= 0 And Index < list_Chips.Size Then
		RemoveChip2(mBase.GetView(0).GetView(Index).GetView(2))
	Else
		Log("RemoveChip index out of range")
	End If
End Sub
'Call RefreshChips if you change something
Public Sub SetChipProperties(Index As Int,Properties As ASChips_ChipProperties)
	Dim mProps As Map = list_Chips.Get(Index)
	mProps.Put("ChipProperties",Properties)
	mProps.Put("Chip",mProps.Get("Chip"))
	list_Chips.Set(Index,mProps)
End Sub

Public Sub GetChipProperties(Index As Int) As ASChips_ChipProperties
	Return list_Chips.Get(Index).As(Map).Get("ChipProperties")
End Sub

Public Sub GetChip(Index As Int) As ASChips_Chip
	Return list_Chips.Get(Index).As(Map).Get("Chip")
End Sub

Public Sub getShowRemoveIcon As Boolean
	Return m_ShowRemoveIcon
End Sub

Public Sub setShowRemoveIcon(Show As Boolean)
	m_ShowRemoveIcon = Show
End Sub

Public Sub getAutoExpand As Boolean
	Return m_AutoExpand
End Sub

Public Sub setAutoExpand(Expand As Boolean)
	m_AutoExpand= Expand
End Sub
'Call RefreshChips if you change something
Public Sub getBackgroundColor As Int
	Return m_BackgroundColor
End Sub

Public Sub setBackgroundColor(Color As Int)
	m_BackgroundColor = Color
End Sub
'Call RefreshChips if you change something
Public Sub setRound(isRound As Boolean)
	m_Round = isRound
End Sub

Public Sub getRound As Boolean
	Return m_Round
End Sub

#End Region

#Region Events

Private Sub EmptyAreaClick
	If xui.SubExists(mCallBack, mEventName & "_EmptyAreaClick",0) Then
		CallSub(mCallBack, mEventName & "_EmptyAreaClick")
	End If
End Sub

Private Sub CustomDrawChip(Item As ASChips_CustomDraw)
	If xui.SubExists(mCallBack, mEventName & "_CustomDrawChip",1) Then
		CallSub2(mCallBack, mEventName & "_CustomDrawChip",Item)
	End If
End Sub

Private Sub HeightChanged(Height As Float)
	If xui.SubExists(mCallBack, mEventName & "_HeightChanged",1) Then
		CallSub2(mCallBack, mEventName & "_HeightChanged",Height)
	End If
End Sub

Private Sub ChipRemoved(Chip As ASChips_Chip)
	If xui.SubExists(mCallBack, mEventName & "_ChipRemoved",1) Then
		CallSub2(mCallBack, mEventName & "_ChipRemoved",Chip)
	End If
End Sub

Private Sub ChipClicked(Chip As ASChips_Chip)
	If xui.SubExists(mCallBack, mEventName & "_ChipClick",1) Then
		CallSub2(mCallBack, mEventName & "_ChipClick",Chip)
	End If
End Sub

Private Sub ChipLongClick(Chip As ASChips_Chip)
	If xui.SubExists(mCallBack, mEventName & "_ChipLongClick",1) Then
		CallSub2(mCallBack, mEventName & "_ChipLongClick",Chip)
	End If
End Sub

Private Sub HiddenChipsClicked
	If xui.SubExists(mCallBack, mEventName & "_HiddenChipsClicked",1) Then
		
		Dim NewList As List
		NewList.Initialize
		For i = (xpnl_HiddenChips.Tag +1) To list_Chips.Size -1
			NewList.Add(list_Chips.Get(i).As(Map).Get("Chip"))
		Next
		
		CallSub2(mCallBack, mEventName & "_HiddenChipsClicked",NewList)
	End If
End Sub

'********************

#If B4J
Private Sub xlbl_RemoveIcon_MouseClicked (EventData As MouseEvent)
	EventData.Consume
	RemoveChip2(Sender)
End Sub
#Else
Private Sub xlbl_RemoveIcon_Click
	RemoveChip2(Sender)
End Sub
#End If

#If B4J
Private Sub xpnl_ChipBackground_MouseClicked (EventData As MouseEvent)
	EventData.Consume
	If EventData.PrimaryButtonPressed Then
		ClickedChip(Sender)
	else If EventData.SecondaryButtonPressed Then
		LongClickedChip(Sender)
	End If
End Sub
#Else
Private Sub xpnl_ChipBackground_Click
	ClickedChip(Sender)
End Sub
Private Sub xpnl_ChipBackground_LongClick
	LongClickedChip(Sender)
End Sub
#End If

#if B4J
Private Sub xpnl_HiddenChips_MouseClicked (EventData As MouseEvent)
	HiddenChipsClicked
End Sub
#Else
Private Sub xpnl_HiddenChips_Click
	HiddenChipsClicked
End Sub
#End If

Private Sub RemoveChip2(xlbl_RemoveIcon As B4XView)
	ChipRemoved(list_Chips.Get(xlbl_RemoveIcon.Tag).As(Map).Get("Chip"))
	list_Chips.RemoveAt(xlbl_RemoveIcon.Tag)
	xlbl_RemoveIcon.Parent.RemoveViewFromParent
	RefreshChips
End Sub

Private Sub ClickedChip(xpnl_Background As B4XView)
	ChipClicked(list_Chips.Get(xpnl_Background.GetView(2).Tag).As(Map).Get("Chip"))
End Sub

Private Sub LongClickedChip(xpnl_Background As B4XView)
	ChipLongClick(list_Chips.Get(xpnl_Background.GetView(2).Tag).As(Map).Get("Chip"))
End Sub

#End Region

#Region Functions

Private Sub CreateLabel(EventName As String) As B4XView
	Dim lbl As Label 
	lbl.Initialize(EventName)
	Return lbl
End Sub

Private Sub CreateImageView(EventName As String) As B4XView
	Dim iv As ImageView 
	iv.Initialize(EventName)
	Return iv
End Sub

Private Sub MeasureTextWidth(Text As String, Font1 As B4XFont) As Int
	
'	Dim cv As B4XCanvas
'	Dim xpnl As B4XView = xui.CreatePanel("")
'	xpnl.SetLayoutAnimated(0,0,0,1dip,1dip)
'	cv.Initialize(xpnl)
'	Return cv.MeasureText(Text,Font1).Width
	
#If B4A
	Private bmp As Bitmap
	bmp.InitializeMutable(2dip, 2dip)
	Private cvs As Canvas
	cvs.Initialize2(bmp)
	Return cvs.MeasureStringWidth(Text, Font1.ToNativeFont, Font1.Size)
#Else If B4i
    Return Text.MeasureWidth(Font1.ToNativeFont)
#Else If B4J
    Dim jo As JavaObject
    jo.InitializeNewInstance("javafx.scene.text.Text", Array(Text))
    jo.RunMethod("setFont",Array(Font1.ToNativeFont))
    jo.RunMethod("setLineSpacing",Array(0.0))
    jo.RunMethod("setWrappingWidth",Array(0.0))
    Dim Bounds As JavaObject = jo.RunMethod("getLayoutBounds",Null)
    Return Bounds.RunMethod("getWidth",Null)
#End If
End Sub

'https://www.b4x.com/android/forum/threads/fontawesome-to-bitmap.95155/post-603250
Public Sub FontToBitmap (text As String, IsMaterialIcons As Boolean, FontSize As Float, color As Int) As B4XBitmap
	Dim xui As XUI
	Dim p As B4XView = xui.CreatePanel("")
	p.SetLayoutAnimated(0, 0, 0, 32dip, 32dip)
	Dim cvs1 As B4XCanvas
	cvs1.Initialize(p)
	Dim fnt As B4XFont
	If IsMaterialIcons Then fnt = xui.CreateMaterialIcons(FontSize) Else fnt = xui.CreateFontAwesome(FontSize)
	Dim r As B4XRect = cvs1.MeasureText(text, fnt)
	Dim BaseLine As Int = cvs1.TargetRect.CenterY - r.Height / 2 - r.Top
	cvs1.DrawText(text, cvs1.TargetRect.CenterX, BaseLine, fnt, color, "CENTER")
	Dim b As B4XBitmap = cvs1.CreateBitmap
	cvs1.Release
	Return b
End Sub

#End Region

#Region Types

Public Sub CreateASChips_ChipProperties (Height As Float, BackgroundColor As Int, TextColor As Int, xFont As B4XFont, CornerRadius As Float, BorderSize As Float, TextGap As Float) As ASChips_ChipProperties
	Dim t1 As ASChips_ChipProperties
	t1.Initialize
	t1.Height = Height
	t1.BackgroundColor = BackgroundColor
	t1.TextColor = TextColor
	t1.xFont = xFont
	t1.CornerRadius = CornerRadius
	t1.BorderSize = BorderSize
	t1.TextGap = TextGap
	Return t1
End Sub

Public Sub CreateASChips_RemoveIconProperties (BackgroundColor As Int, TextColor As Int) As ASChips_RemoveIconProperties
	Dim t1 As ASChips_RemoveIconProperties
	t1.Initialize
	t1.BackgroundColor = BackgroundColor
	t1.TextColor = TextColor
	Return t1
End Sub

Public Sub CreateASChips_CustomDraw (Chip As ASChips_Chip, ChipProperties As ASChips_ChipProperties, Views As ASChips_Views) As ASChips_CustomDraw
	Dim t1 As ASChips_CustomDraw
	t1.Initialize
	t1.Chip = Chip
	t1.ChipProperties = ChipProperties
	t1.Views = Views
	Return t1
End Sub

Public Sub CreateASChips_Views (BackgroundPanel As B4XView, TextLabel As B4XView, IconImageView As B4XView, RemoveIconLabel As B4XView) As ASChips_Views
	Dim t1 As ASChips_Views
	t1.Initialize
	t1.BackgroundPanel = BackgroundPanel
	t1.TextLabel = TextLabel
	t1.IconImageView = IconImageView
	t1.RemoveIconLabel = RemoveIconLabel
	Return t1
End Sub

#End Region