#tag MobileScreen
Begin MobileScreen Screen1
   BackButtonCaption=   ""
   Compatibility   =   ""
   ControlCount    =   0
   Device = 1
   HasNavigationBar=   True
   LargeTitleDisplayMode=   2
   Left            =   0
   Orientation = 0
   TabBarVisible   =   True
   TabIcon         =   0
   TintColor       =   &c00000000
   Title           =   "Untitled"
   Top             =   0
   Begin MobileButton ShowButton
      AccessibilityHint=   ""
      AccessibilityLabel=   ""
      AutoLayout      =   ShowButton, 8, , 0, False, +1.00, 4, 1, 30, , True
      AutoLayout      =   ShowButton, 2, WriteButton, 1, False, +1.00, 4, 1, -*kStdControlGapH, , True
      AutoLayout      =   ShowButton, 3, TopLayoutGuide, 4, False, +1.00, 4, 1, *kStdControlGapV, , True
      AutoLayout      =   ShowButton, 7, WriteButton, 7, False, +1.00, 4, 1, 0, , True
      Caption         =   "Show"
      CaptionColor    =   &c007AFF00
      ControlCount    =   0
      Enabled         =   True
      Height          =   30
      Left            =   30
      LockedInPosition=   False
      Scope           =   2
      TextFont        =   ""
      TextSize        =   0
      TintColor       =   &c000000
      Top             =   73
      Visible         =   True
      Width           =   81
   End
   Begin MobileButton WriteButton
      AccessibilityHint=   ""
      AccessibilityLabel=   ""
      AutoLayout      =   WriteButton, 10, ShowButton, 10, False, +1.00, 4, 1, 0, , True
      AutoLayout      =   WriteButton, 9, <Parent>, 9, False, +1.00, 4, 1, 0, , True
      AutoLayout      =   WriteButton, 8, , 0, False, +1.00, 4, 1, 30, , True
      AutoLayout      =   WriteButton, 7, , 0, False, +1.00, 4, 1, 81, , True
      Caption         =   "Write"
      CaptionColor    =   &c007AFF00
      ControlCount    =   0
      Enabled         =   True
      Height          =   30
      Left            =   119
      LockedInPosition=   False
      Scope           =   2
      TextFont        =   ""
      TextSize        =   0
      TintColor       =   &c000000
      Top             =   73
      Visible         =   True
      Width           =   81
   End
   Begin MobileButton EvictButton
      AccessibilityHint=   ""
      AccessibilityLabel=   ""
      AutoLayout      =   EvictButton, 10, ShowButton, 10, False, +1.00, 4, 1, 0, , True
      AutoLayout      =   EvictButton, 8, , 0, False, +1.00, 4, 1, 30, , True
      AutoLayout      =   EvictButton, 1, WriteButton, 2, False, +1.00, 4, 1, *kStdControlGapH, , True
      AutoLayout      =   EvictButton, 7, , 0, False, +1.00, 4, 1, 81, , True
      Caption         =   "Evict"
      CaptionColor    =   &c007AFF00
      ControlCount    =   0
      Enabled         =   True
      Height          =   30
      Left            =   208
      LockedInPosition=   False
      Scope           =   2
      TextFont        =   ""
      TextSize        =   0
      TintColor       =   &c000000
      Top             =   73
      Visible         =   True
      Width           =   81
   End
   Begin MobileButton DownloadButton
      AccessibilityHint=   ""
      AccessibilityLabel=   ""
      AutoLayout      =   DownloadButton, 8, , 0, False, +1.00, 4, 1, 30, , True
      AutoLayout      =   DownloadButton, 1, EvictButton, 1, False, +1.00, 4, 1, 0, , True
      AutoLayout      =   DownloadButton, 3, WriteButton, 4, False, +1.00, 4, 1, *kStdControlGapV, , True
      AutoLayout      =   DownloadButton, 7, , 0, False, +1.00, 4, 1, 81, , True
      Caption         =   "Download"
      CaptionColor    =   &c007AFF00
      ControlCount    =   0
      Enabled         =   True
      Height          =   30
      Left            =   208
      LockedInPosition=   False
      Scope           =   2
      TextFont        =   ""
      TextSize        =   0
      TintColor       =   &c000000
      Top             =   111
      Visible         =   True
      Width           =   81
   End
   Begin iOSMobileTable Table1
      AccessibilityHint=   ""
      AccessibilityLabel=   ""
      AllowRefresh    =   False
      AllowSearch     =   False
      AutoLayout      =   Table1, 1, <Parent>, 1, False, +1.00, 4, 1, 0, , True
      AutoLayout      =   Table1, 2, <Parent>, 2, False, +1.00, 4, 1, -0, , True
      AutoLayout      =   Table1, 4, BottomLayoutGuide, 4, False, +1.00, 4, 1, 0, , True
      AutoLayout      =   Table1, 3, <Parent>, 3, False, +1.00, 4, 1, 149, , True
      ControlCount    =   0
      EditingEnabled  =   False
      EditingEnabled  =   False
      Enabled         =   True
      EstimatedRowHeight=   -1
      Format          =   0
      Height          =   419
      Left            =   0
      LockedInPosition=   False
      Scope           =   2
      SectionCount    =   0
      TintColor       =   &c000000
      Top             =   149
      Visible         =   True
      Width           =   320
   End
End
#tag EndMobileScreen

#tag WindowCode
	#tag Event
		Sub Opening()
		  If icloud.iCloudAvailable = False Then
		    MessageBox "iCloud is not enabled on this device"
		    Return
		  End If
		  
		  Try
		    f = iCloud.ICloudFolder.Child("iOS test File.mff")
		  Catch ex As NilObjectException
		    MessageBox "The iCloud folder could not be accessed. Make sure you are testing this on a real device."
		  End Try
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Sub writefile()
		  Dim r As New Random
		  WriteTextToCloudDocs("Hello World" + r.InRange(1,100000).ToString, "test2.mff")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WriteTextToCloudDocs(data as string, filename as string)
		  #If TargetiOS Or TargetMacOS
		    dim f as folderitem = WriteTextToCloudDocs(data, filename)
		  #EndIf
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function WriteTextToCloudDocs(data as string, filename as string) As FolderItem
		  #If TargetiOS Or TargetMacOS
		    If iCloud.iCloudAvailable = False Then
		      Break
		      // user doesn't have icloud turned on?
		      Return Nil
		    End If
		    
		    Dim iCloudFolder As FolderItem = iCloud.ICloudFolder
		    If iCloudFolder = Nil Then
		      Break
		      // user doesn't have icloud turned on?
		      Return Nil
		    End If
		    
		    Dim docsFolder As FolderItem = iCloudFolder.Child("Documents")
		    If Not docsFolder.Exists Then
		      docsFolder.CreateFolder
		    End If
		    
		    Dim docFile As FolderItem = docsFolder.Child(filename)
		    
		    // write the data to the file
		    Dim tos As TextOutputStream = TextOutputStream.Create(docFile)
		    tos.WriteLine data
		    tos.Close
		    
		    return docFile
		  #EndIf
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private f As FolderItem
	#tag EndProperty


#tag EndWindowCode

#tag Events ShowButton
	#tag Event
		Sub Pressed()
		  MessageBox f.NativePath
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events WriteButton
	#tag Event
		Sub Pressed()
		  writefile
		  
		  
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events EvictButton
	#tag Event
		Sub Pressed()
		  // Remove the file from the local drive
		  
		  If f<>Nil Then
		    If iCloud.FileIsDownloaded(f) <> iCloud.DownloadStatus.NotDownloaded Then
		      Dim tf As Boolean = iCloud.EvictItem(f)
		    End If
		  End If
		  
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events DownloadButton
	#tag Event
		Sub Pressed()
		  If f<>Nil Then
		    If iCloud.FileIsDownloaded(f) <> iCloud.DownloadStatus.Downloaded_Current Then
		      Dim tf As Boolean = iCloud.StartDownloading(f)
		    End If
		  End If
		End Sub
	#tag EndEvent
#tag EndEvents
#tag ViewBehavior
	#tag ViewProperty
		Name="Index"
		Visible=true
		Group="ID"
		InitialValue="-2147483648"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Name"
		Visible=true
		Group="ID"
		InitialValue=""
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Super"
		Visible=true
		Group="ID"
		InitialValue=""
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Left"
		Visible=true
		Group="Position"
		InitialValue="0"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Top"
		Visible=true
		Group="Position"
		InitialValue="0"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="BackButtonCaption"
		Visible=true
		Group="Behavior"
		InitialValue=""
		Type="String"
		EditorType="MultiLineEditor"
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasNavigationBar"
		Visible=true
		Group="Behavior"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="TabIcon"
		Visible=true
		Group="Behavior"
		InitialValue=""
		Type="Picture"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Title"
		Visible=true
		Group="Behavior"
		InitialValue="Untitled"
		Type="String"
		EditorType="MultiLineEditor"
	#tag EndViewProperty
	#tag ViewProperty
		Name="LargeTitleDisplayMode"
		Visible=true
		Group="Behavior"
		InitialValue="2"
		Type="MobileScreen.LargeTitleDisplayModes"
		EditorType="Enum"
		#tag EnumValues
			"0 - Automatic"
			"1 - Always"
			"2 - Never"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="TabBarVisible"
		Visible=true
		Group="Behavior"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="TintColor"
		Visible=false
		Group="Behavior"
		InitialValue=""
		Type="ColorGroup"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="ControlCount"
		Visible=false
		Group="Behavior"
		InitialValue=""
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
#tag EndViewBehavior
