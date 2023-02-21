#tag Module
Protected Module iCloud
	#tag Method, Flags = &h1
		Protected Function EvictItem(f as FolderItem) As Boolean
		  // Call this method to ask the OS to evict the specified item from the user's local Cloud Drive folder
		  // Raises a runtime error if the operation failed or the file was not local
		  
		  #If TargetiOS Or TargetMacOS
		    Declare Function NSClassFromString Lib "Foundation" (name As cfstringref) As ptr
		    
		    // @property(class, readonly, strong) NSFileManager *defaultManager;
		    Declare Function getDefaultManager Lib "Foundation" Selector "defaultManager" (cls As ptr) As Ptr
		    
		    Dim mgr As ptr = getDefaultManager(NSClassFromString("NSFileManager"))
		    
		    Dim NSURL As ptr = NSClassFromString("NSURL")
		    // + (instancetype)URLWithString:(NSString *)URLString;
		    Declare Function URLWithString_ Lib "Foundation" Selector "URLWithString:" (cls As ptr, URLString As CFStringRef) As Ptr
		    
		    Dim url As ptr = URLWithString_(NSURL, f.URLPath)
		    
		    // - (BOOL)evictUbiquitousItemAtURL:(NSURL *)url error:(NSError * _Nullable *)error;
		    Declare Function evictUbiquitousItemAtURL_error_ Lib "Foundation" Selector "evictUbiquitousItemAtURL:error:" ( obj As ptr , url As Ptr , error As Ptr ) As Boolean
		    
		    Dim err As ptr
		    If Not evictUbiquitousItemAtURL_error_(mgr, url, err) Then
		      // @property(readonly) NSInteger code;
		      Declare Function getCode Lib "Foundation" Selector "code" (obj As ptr) As Integer
		      // @property(readonly, copy) NSString *localizedDescription;
		      Declare Function getLocalizedDescription Lib "Foundation" Selector "localizedDescription" (obj As ptr) As CFStringRef
		      
		      If err<>Nil Then
		        Dim msg As String = getLocalizedDescription(err)
		        Dim code As Integer = getCode(err)
		        Raise New RuntimeException(msg, code)
		      End If
		    End If
		    
		    Return True
		    
		  #EndIf
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function FileIsDownloaded(f as FolderItem) As iCloud.DownloadStatus
		  // checks the file download status
		  // Downloaded_Current = Downloaded and the latest version
		  // Downloaded_Stale = Downloaded but there's a newer version on iCloud
		  // NotDownloaded = The file doesn't exist locally but does exist on iCloud
		  
		  #If TargetIOS Or TargetMacOS
		    
		    Declare Function NSClassFromString Lib "Foundation" (name As cfstringref) As ptr
		    Declare Sub Release Lib "Foundation" Selector "release" (obj As Ptr)
		    Declare Function Retain Lib "Foundation" Selector "retain" (obj As Ptr) As Ptr
		    
		    // + (instancetype)URLWithString:(NSString *)URLString;
		    Declare Function URLWithString_ Lib "Foundation" Selector "URLWithString:" (cls As ptr, URLString As CFStringRef) As Ptr
		    
		    Dim url As ptr = URLWithString_(NSClassFromString("NSURL"), f.URLPath)
		    url = retain(url)
		    
		    // - (BOOL)getResourceValue:(out id _Nullable *)value forKey:(NSURLResourceKey)key error:(out NSError * _Nullable *)error;
		    Declare Function getResourceValue_forKey_error_ Lib "Foundation" Selector "getResourceValue:forKey:error:" (obj As ptr, ByRef value As CFStringRef, key As CFStringRef, ByRef error As Ptr) As Boolean
		    
		    Dim value As CFStringRef
		    Dim err As ptr
		    Dim b As Boolean = getResourceValue_forKey_error_(url, value, "NSURLUbiquitousItemDownloadingStatusKey", err)
		    
		    Select Case value
		    Case "NSURLUbiquitousItemDownloadingStatusCurrent"
		      Return DownloadStatus.Downloaded_Current
		    Case "NSURLUbiquitousItemDownloadingStatusDownloaded"
		      Return DownloadStatus.Downloaded_Stale
		    Case "NSURLUbiquitousItemDownloadingStatusNotDownloaded"
		      Return DownloadStatus.NotDownloaded
		    End Select
		  #EndIf
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function iCloudAvailable() As Boolean
		  // Returns True if the user has iCloud enabled in their account
		  
		  #If TargetiOS Or TargetMacOS
		    Declare Function NSClassFromString Lib "Foundation" (name As cfstringref) As ptr
		    
		    // @property(class, readonly, strong) NSFileManager *defaultManager;
		    Declare Function getDefaultManager Lib "Foundation" Selector "defaultManager" (cls As ptr) As Ptr
		    
		    Dim mgr As ptr = getDefaultManager(NSClassFromString("NSFileManager"))
		    
		    // @property(nullable, readonly, copy) id<NSObject, NSCopying, NSCoding> ubiquityIdentityToken;
		    Declare Function getUbiquityIdentityToken Lib "Foundation" Selector "ubiquityIdentityToken" (obj As ptr) As Ptr
		    
		    Dim token As ptr = getUbiquityIdentityToken(mgr)
		    
		    // If iCloud is unavailable or there is no logged-in user, the value of this property is nil
		    Return token<>Nil
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ICloudFolder(ID as string = "") As FolderItem
		  // Returns a folderitem pointing to the local cloud folder for the app
		  // If specifying an ID, it must be declared in the entitlements file under
		  // com.apple.developer.ubiquity-container-identifiers. 
		  // For more info, see Parameters: https://developer.apple.com/documentation/foundation/nsfilemanager/1411653-urlforubiquitycontaineridentifie 
		  
		  #If TargetiOS Or TargetMacOS
		    If Not iCloudAvailable Then
		      Return Nil
		    End If
		    
		    Declare Function NSClassFromString Lib "Foundation" (name As cfstringref) As ptr
		    
		    // @property(class, readonly, strong) NSFileManager *defaultManager;
		    Declare Function getDefaultManager Lib "Foundation" Selector "defaultManager" (cls As ptr) As Ptr
		    
		    Dim mgr As ptr = getDefaultManager(NSClassFromString("NSFileManager"))
		    
		    // create the path to the file within the iCloud folder
		    
		    // - (NSURL *)URLForUbiquityContainerIdentifier:(NSString *)containerIdentifier;
		    Declare Function URLForUbiquityContainerIdentifier_ Lib "Foundation" Selector "URLForUbiquityContainerIdentifier:" (obj As ptr, containerIdentifier As CFStringRef) As Ptr
		    
		    Dim iCloudFolder As ptr
		    
		    If ID = "" Then
		      iCloudFolder = URLForUbiquityContainerIdentifier_(mgr, Nil) // Nil uses the first one defined in the entitlements
		    Else
		      iCloudFolder = URLForUbiquityContainerIdentifier_(mgr, ID)
		    End If
		    
		    If iCloudFolder=Nil Then
		      // iCloud Drive is not turned on for this device?
		      Break
		      Return Nil
		    End If
		    
		    Declare Function getPath Lib "Foundation" Selector "path" (obj As ptr) As CFStringRef
		    
		    Dim filepath As String = getPath(iCloudFolder)
		    
		    Return New FolderItem(filepath, FolderItem.PathModes.Native)
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function IsICloudFile(f as FolderItem) As Boolean
		  #If TargetMacOS
		    // - (BOOL)isUbiquitousItemAtURL:(NSURL *)url;
		    Declare Function isUbiquitousItemAtURL_ Lib "Foundation" Selector "isUbiquitousItemAtURL:" ( obj As ptr , url As Ptr ) As Boolean
		    
		    Declare Function NSClassFromString Lib "Foundation" (name As cfstringref) As ptr
		    
		    // @property(class, readonly, strong) NSFileManager *defaultManager;
		    Declare Function getDefaultManager Lib "Foundation" Selector "defaultManager" (cls As ptr) As Ptr
		    
		    Dim mgr As ptr = getDefaultManager(NSClassFromString("NSFileManager"))
		    
		    Dim NSURL As ptr = NSClassFromString("NSURL")
		    // + (instancetype)URLWithString:(NSString *)URLString;
		    Declare Function URLWithString_ Lib "Foundation" Selector "URLWithString:" (cls As ptr, URLString As CFStringRef) As Ptr
		    
		    Dim url As ptr = URLWithString_(NSURL, f.URLPath)
		    
		    return isUbiquitousItemAtURL_(mgr, url)
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function StartDownloading(f as FolderItem) As Boolean
		  // Call this method to ask the OS to download the specified item from the user's Cloud Drive
		  // Raises a runtime error if the operation failed
		  #If TargetiOS Or TargetMacOS
		    Declare Function NSClassFromString Lib "Foundation" (name As cfstringref) As ptr
		    
		    // @property(class, readonly, strong) NSFileManager *defaultManager;
		    Declare Function getDefaultManager Lib "Foundation" Selector "defaultManager" (cls As ptr) As Ptr
		    
		    Dim mgr As ptr = getDefaultManager(NSClassFromString("NSFileManager"))
		    
		    Dim NSURL As ptr = NSClassFromString("NSURL")
		    // + (instancetype)URLWithString:(NSString *)URLString;
		    Declare Function URLWithString_ Lib "Foundation" Selector "URLWithString:" (cls As ptr, URLString As CFStringRef) As Ptr
		    
		    Dim url As ptr = URLWithString_(NSURL, f.URLPath)
		    
		    // - (BOOL)startDownloadingUbiquitousItemAtURL:(NSURL *)url error:(NSError * _Nullable *)error;
		    Declare Function startDownloadingUbiquitousItemAtURL_error_ Lib "Foundation" Selector "startDownloadingUbiquitousItemAtURL:error:" (obj As ptr, url As Ptr, error As Ptr) As Boolean
		    
		    Dim err As ptr
		    If Not startDownloadingUbiquitousItemAtURL_error_(mgr, url, err) Then
		      // @property(readonly) NSInteger code;
		      Declare Function getCode Lib "Foundation" Selector "code" (obj As ptr) As Integer
		      // @property(readonly, copy) NSString *localizedDescription;
		      Declare Function getLocalizedDescription Lib "Foundation" Selector "localizedDescription" (obj As ptr) As CFStringRef
		      
		      Raise New RuntimeException(getLocalizedDescription(err), getCode(err))
		    End If
		    
		    Return True
		    
		  #EndIf
		  
		End Function
	#tag EndMethod


	#tag Enum, Name = DownloadStatus, Type = Integer, Flags = &h1
		Downloaded_Current
		  Downloaded_Stale
		NotDownloaded
	#tag EndEnum


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
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
	#tag EndViewBehavior
End Module
#tag EndModule
