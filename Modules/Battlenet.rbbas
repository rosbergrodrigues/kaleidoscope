#tag Module
Protected Module Battlenet
	#tag Method, Flags = &h1
		Protected Function getClientToken() As UInt32
		  
		  Dim mem As New MemoryBlock(4)
		  
		  mem.UInt8Value(0) = Floor(Rnd() * 255)
		  mem.UInt8Value(1) = Floor(Rnd() * 255)
		  mem.UInt8Value(2) = Floor(Rnd() * 255)
		  mem.UInt8Value(3) = Floor(Rnd() * 255)
		  
		  Return mem.UInt32Value(0)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub getDefaultChannel(product As UInt32, ByRef flags As Uint32, ByRef channel As String)
		  
		  Const FLAG_NOCREATE = &H00
		  Const FLAG_FIRST    = &H01
		  Const FLAG_FORCE    = &H02
		  Const FLAG_DIABLO2  = &H04
		  
		  flags = FLAG_FIRST
		  
		  If Battlenet.isDiablo2(product) Then
		    flags = BitOr(flags, FLAG_DIABLO2)
		  End If
		  
		  Select Case product
		  Case Battlenet.Product_STAR
		    channel = "StarCraft"
		  Case Battlenet.Product_SEXP
		    channel = "Brood War"
		  Case Battlenet.Product_W2BN
		    channel = "WarCraft II"
		  Case Battlenet.Product_D2DV
		    channel = "Diablo II"
		  Case Battlenet.Product_D2XP
		    channel = "Lord of Destruction"
		  Case Battlenet.Product_JSTR
		    channel = "StarCraft"
		  Case Battlenet.Product_WAR3
		    channel = "WarCraft III"
		  Case Battlenet.Product_W3XP
		    channel = "Frozen Throne"
		  Case Battlenet.Product_DRTL
		    channel = "Diablo"
		  Case Battlenet.Product_DSHR
		    channel = "Diablo"
		  Case Battlenet.Product_SSHR
		    channel = "StarCraft"
		  Case Battlenet.Product_W3DM
		    channel = "WarCraft III"
		  Case Else
		    Raise New BattlenetException("Unable to translate value '" + Format(product, "-#") + "' to default channel")
		  End Select
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function getKeyData(strKey As String, clientToken As UInt32, serverToken As UInt32) As String
		  
		  // For use with 0x51 SID_AUTH_CHECK
		  
		  Soft Declare Function kd_quick Lib Battlenet.libBNCSUtil (_
		  key As Ptr, clientToken As UInt32, serverToken As UInt32, _
		  publicVal As Ptr, productVal As Ptr, privateVal As Ptr, privateValLen As UInt32) _
		  As Boolean
		  
		  Dim mKey As New MemoryBlock(LenB(strKey) + 1)
		  mKey.CString(0) = strKey
		  
		  Dim mPublicVal As New MemoryBlock(4)
		  Dim mProductVal As New MemoryBlock(4)
		  Dim mPrivateVal As New MemoryBlock(20)
		  
		  Dim returnVal As Boolean = kd_quick(_
		  mKey, clientToken, serverToken, _
		  mPublicVal, mProductVal, mPrivateVal, mPrivateVal.Size)
		  
		  If returnVal = False Then Return ""
		  
		  Dim mReturnVal As New MemoryBlock(16 + mPrivateVal.Size)
		  
		  mReturnVal.UInt32Value(0) = LenB(strKey)
		  mReturnVal.UInt32Value(4) = mProductVal.UInt32Value(0)
		  mReturnVal.UInt32Value(8) = mPublicVal.UInt32Value(0)
		  mReturnVal.UInt32Value(12) = 0
		  mReturnVal.StringValue(16, mPrivateVal.Size) = mPrivateVal.StringValue(0, mPrivateVal.Size)
		  
		  Return mReturnVal
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function getLocalIP() As UInt32
		  
		  Dim soc As New TCPSocket()
		  Dim mem As New MemoryBlock(4)
		  
		  mem.UInt8Value(0) = Val(NthField(soc.LocalAddress, ".", 4))
		  mem.UInt8Value(1) = Val(NthField(soc.LocalAddress, ".", 3))
		  mem.UInt8Value(2) = Val(NthField(soc.LocalAddress, ".", 2))
		  mem.UInt8Value(3) = Val(NthField(soc.LocalAddress, ".", 1))
		  
		  Return mem.UInt32Value(0)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function getTimezoneBias() As UInt32
		  
		  Dim o As New Date()
		  
		  Return (0 - o.GMTOffset) * 60
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function isDiablo2(product As UInt32) As Boolean
		  
		  Select Case product
		  Case Battlenet.Product_D2DV
		  Case Battlenet.Product_D2XP
		  Case Else
		    Return False
		  End Select
		  Return True
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function isWarcraft3(product As UInt32) As Boolean
		  
		  Select Case product
		  Case Battlenet.Product_W3DM
		  Case Battlenet.Product_W3XP
		  Case Battlenet.Product_WAR3
		  Case Else
		    Return False
		  End Select
		  Return True
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub login(client As BNETClient)
		  
		  Const TYPE_OLS      = &H00
		  Const TYPE_NLS_BETA = &H01
		  Const TYPE_NLS      = &H02
		  
		  Select Case client.state.logonType
		  Case TYPE_OLS
		    
		    client.socBNET.Write(Packets.CreateBNET_SID_LOGONRESPONSE2(_
		    client.state.clientToken, client.state.serverToken, _
		    Battlenet.passwordDataOLS(client.state.password, _
		    client.state.clientToken, client.state.serverToken), _
		    client.state.username))
		    
		  Case TYPE_NLS_BETA, TYPE_NLS
		    
		    stderr.WriteLine("DEBUG: NLS")
		    
		  Case Else
		    
		    Raise New BattlenetException("Undefined logon type '" + Format(client.state.logonType, "-#") + "'")
		    
		  End Select
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function needsGameKey1(product As UInt32) As Boolean
		  
		  Select Case product
		  Case Battlenet.Product_D2DV
		  Case Battlenet.Product_D2XP
		  Case Battlenet.Product_JSTR
		  Case Battlenet.Product_SEXP
		  Case Battlenet.Product_STAR
		  Case Battlenet.Product_W2BN
		  Case Battlenet.Product_W3XP
		  Case Battlenet.Product_WAR3
		  Case Else
		    Return False
		  End Select
		  Return True
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function needsGameKey2(product As UInt32) As Boolean
		  
		  Select Case product
		  Case Battlenet.Product_D2XP
		  Case Battlenet.Product_W3XP
		  Case Else
		    Return False
		  End Select
		  Return True
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function onlineNameToAccountName(onlineName As String, ourProduct As UInt32, ignoreRealm As Boolean) As String
		  
		  Dim accountName As String = onlineName
		  
		  If Battlenet.isDiablo2(ourProduct) Then
		    accountName = Mid(accountName, InStr(accountName, "*") + 1)
		  End If
		  
		  If ignoreRealm = False Then
		    
		    Dim realms() As String
		    Dim cursor As Integer
		    
		    If Battlenet.isWarcraft3(ourProduct) Then
		      realms.Append("@USWest")
		      realms.Append("@USEast")
		      realms.Append("@Asia")
		      realms.Append("@Europe")
		    Else
		      realms.Append("@Lordaeron")
		      realms.Append("@Azeroth")
		      realms.Append("@Kalimdor")
		      realms.Append("@Northrend")
		    End If
		    
		    Do Until UBound(realms) < 0
		      
		      cursor = InStr(accountName, realms.Pop())
		      If cursor > 0 Then
		        accountName = Left(accountName, cursor - 1)
		        Exit Do
		      End If
		      
		    Loop
		    
		  End If
		  
		  Return accountName
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function passwordDataOLS(password As String, clientToken As UInt32, serverToken As UInt32) As String
		  
		  Soft Declare Sub doubleHashPassword Lib Battlenet.libBNCSUtil (_
		  password As Ptr,clientToken As UInt32, serverToken As UInt32, _
		  passwordHash As Ptr)
		  
		  Dim mPassword As New MemoryBlock(LenB(password) + 1)
		  mPassword.CString(0) = password
		  
		  Dim mPasswordHash As New MemoryBlock(20)
		  
		  doubleHashPassword(mPassword, clientToken, serverToken, mPasswordHash)
		  
		  Return mPasswordHash
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function productToBNET(value As UInt32) As UInt32
		  
		  Select Case value
		  Case 1
		    Return Battlenet.Product_STAR
		  Case 2
		    Return Battlenet.Product_SEXP
		  Case 3
		    Return Battlenet.Product_W2BN
		  Case 4
		    Return Battlenet.Product_D2DV
		  Case 5
		    Return Battlenet.Product_D2XP
		  Case 6
		    Return Battlenet.Product_JSTR
		  Case 7
		    Return Battlenet.Product_WAR3
		  Case 8
		    Return Battlenet.Product_W3XP
		  Case 9
		    Return Battlenet.Product_DRTL
		  Case 10
		    Return Battlenet.Product_DSHR
		  Case 11
		    Return Battlenet.Product_SSHR
		  Case 12
		    Return Battlenet.Product_W3DM
		  Case Else
		    Raise New BattlenetException("Unable to translate value '" + Format(value, "-#") + "' to BNET product id")
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function productToBNLS(value As UInt32) As UInt32
		  
		  Select Case value
		  Case Battlenet.Product_STAR
		    Return 1
		  Case Battlenet.Product_SEXP
		    Return 2
		  Case Battlenet.Product_W2BN
		    Return 3
		  Case Battlenet.Product_D2DV
		    Return 4
		  Case Battlenet.Product_D2XP
		    Return 5
		  Case Battlenet.Product_JSTR
		    Return 6
		  Case Battlenet.Product_WAR3
		    Return 7
		  Case Battlenet.Product_W3XP
		    Return 8
		  Case Battlenet.Product_DRTL
		    Return 9
		  Case Battlenet.Product_DSHR
		    Return 10
		  Case Battlenet.Product_SSHR
		    Return 11
		  Case Battlenet.Product_W3DM
		    Return 12
		  Case Else
		    Raise New BattlenetException("Unable to translate value '" + Format(value, "-#") + "' to BNLS product id")
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function strToBool(value As String) As Boolean
		  
		  Select Case value
		  Case "1"
		  Case "On"
		  Case "True"
		  Case "Y"
		  Case "Yes"
		  Case Else
		    Return False
		  End Select
		  Return True
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function strToGameKey(value As String) As String
		  
		  // Filter 'value' through A-Za-z0-9 pattern forming 'key'.
		  // This removes spaces, dashes, and other anomalies.
		  
		  Dim key As String = ""
		  Dim i As Integer
		  Dim j As Integer = Len(value)
		  Dim k As Integer
		  
		  For i = 1 To j
		    k = Asc(Mid(value, i, 1))
		    If (k >= &H41 And k <= &H5A) Or (k >= &H61 And k <= &H7A) Or (k >= &H30 And k <= &H39) Then
		      key = key + Chr(k)
		    End If
		  Next
		  
		  Return Uppercase(key) // The final 'key' should be uppercase.
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function strToPlatform(value As String) As UInt32
		  
		  Select Case ReplaceAll(value, " ", "")
		  Case "IX86", "68XI", "windows", "win32", "win64", "win", "linux", "unix"
		    Return Battlenet.Platform_IX86
		  Case "PMAC", "CAMP", "powerpc", "classicmac", "macclassic"
		    Return Battlenet.Platform_PMAC
		  Case "XMAC", "CAMX", "macintosh", "mac", "osx", "macosx", "macos"
		    Return Battlenet.Platform_XMAC
		  Case Else
		    Raise New BattlenetException("Unable to translate value '" + value + "' to platform id")
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function strToProduct(value As String) As UInt32
		  
		  Select Case ReplaceAll(value, " ", "")
		  Case "CHAT", "TAHC", "Telnet", "Plaintext", "Text"
		    Return Battlenet.Product_CHAT
		  Case "D2DV", "VD2D", "D2", "Diablo2", "DiabloII"
		    Return Battlenet.Product_D2DV
		  Case "D2XP", "PX2D", "LOD", "LordOfDestruction", "Diablo2LOD", "DiabloIILOD", "D2EXP"
		    Return Battlenet.Product_D2XP
		  Case "DRTL", "LTRD", "D1", "Diablo", "Diablo1", "DiabloI"
		    Return Battlenet.Product_DRTL
		  Case "DSHR", "RHSD", "DS", "DiabloShareware", "Diablo1Shareware", "DiabloIShareware", "DSHW", "DSW"
		    Return Battlenet.Product_DSHR
		  Case "JSTR", "RTSJ", "SCJ", "StarcraftJapan", "StarcraftJapanese", "SCJapan", "SCJapanese"
		    Return Battlenet.Product_JSTR
		  Case "SEXP", "PXES", "BW", "StarcraftBroodwar", "SCBroodwar", "SCBW", "SCEXP"
		    Return Battlenet.Product_SEXP
		  Case "SSHR", "RHSS", "SS", "StarcraftShareware", "SCShareware", "SCSW", "SCSH"
		    Return Battlenet.Product_SSHR
		  Case "STAR", "RATS", "SC", "Starcraft", "StarcraftOriginal", "StarcraftOrig"
		    Return Battlenet.Product_STAR
		  Case "W2BN", "NB2W", "W2", "WarcraftII", "Warcraft2", "WarcraftIIBNE", "Warcraft2BNE", "WC2"
		    Return Battlenet.Product_W2BN
		  Case "W3DM", "MD3W", "W3D", "WarcraftIIIDemo", "Warcraft3Demo", "WC3Demo"
		    Return Battlenet.Product_W3DM
		  Case "W3XP", "PX3W", "TFT", "WarcraftIIITFT", "Warcraft3TFT", "W3EXP", "WC3EXP", "WC3TFT", "W3TFT"
		    Return Battlenet.Product_W3XP
		  Case "WAR3", "3RAW", "W3", "WarcraftIII", "WarcraftIIIROC", "WC3"
		    Return Battlenet.Product_WAR3
		  Case Else
		    Raise New BattlenetException("Unable to translate value '" + value + "' to product id")
		  End Select
		  
		End Function
	#tag EndMethod


	#tag Constant, Name = EID_BROADCAST, Type = Double, Dynamic = False, Default = \"&H06", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = EID_CHANNEL, Type = Double, Dynamic = False, Default = \"&H07", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = EID_CHANNEL_EMPTY, Type = Double, Dynamic = False, Default = \"&H0E", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = EID_CHANNEL_FULL, Type = Double, Dynamic = False, Default = \"&H0D", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = EID_CHANNEL_RESTRICTED, Type = Double, Dynamic = False, Default = \"&H0F", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = EID_EMOTE, Type = Double, Dynamic = False, Default = \"&H17", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = EID_ERROR, Type = Double, Dynamic = False, Default = \"&H13", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = EID_INFO, Type = Double, Dynamic = False, Default = \"&H12", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = EID_TALK, Type = Double, Dynamic = False, Default = \"&H05", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = EID_USERJOIN, Type = Double, Dynamic = False, Default = \"&H02", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = EID_USERLEAVE, Type = Double, Dynamic = False, Default = \"&H03", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = EID_USERSHOW, Type = Double, Dynamic = False, Default = \"&H01", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = EID_USERUPDATE, Type = Double, Dynamic = False, Default = \"&H09", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = EID_WHISPER, Type = Double, Dynamic = False, Default = \"&H04", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = EID_WHISPERSENT, Type = Double, Dynamic = False, Default = \"&H0A", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = libBNCSUtil, Type = String, Dynamic = False, Default = \"", Scope = Protected
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"/usr/lib/libbncsutil.so"
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"C:\\Windows\\bncsutil.dll"
	#tag EndConstant

	#tag Constant, Name = Platform_IX86, Type = Double, Dynamic = False, Default = \"&H49583836", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = Platform_PMAC, Type = Double, Dynamic = False, Default = \"&H504D4143", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = Platform_XMAC, Type = Double, Dynamic = False, Default = \"&H584D4143", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = Product_CHAT, Type = Double, Dynamic = False, Default = \"&H43484154", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = Product_D2DV, Type = Double, Dynamic = False, Default = \"&H44324456", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = Product_D2XP, Type = Double, Dynamic = False, Default = \"&H44325850", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = Product_DRTL, Type = Double, Dynamic = False, Default = \"&H4452544C", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = Product_DSHR, Type = Double, Dynamic = False, Default = \"&H44534852", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = Product_JSTR, Type = Double, Dynamic = False, Default = \"&H4A535452", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = Product_SEXP, Type = Double, Dynamic = False, Default = \"&H53455850", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = Product_SSHR, Type = Double, Dynamic = False, Default = \"&H53534852", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = Product_STAR, Type = Double, Dynamic = False, Default = \"&H53544152", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = Product_W2BN, Type = Double, Dynamic = False, Default = \"&H5732424E", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = Product_W3DM, Type = Double, Dynamic = False, Default = \"&H5733444D", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = Product_W3XP, Type = Double, Dynamic = False, Default = \"&H57335850", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = Product_WAR3, Type = Double, Dynamic = False, Default = \"&H57415233", Scope = Protected
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule