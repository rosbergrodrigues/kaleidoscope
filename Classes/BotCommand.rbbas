#tag Class
Protected Class BotCommand
	#tag Method, Flags = &h0
		Sub Constructor(aclAdmin As Boolean)
		  
		  Me.aclAdmin = aclAdmin
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function execute(client As BNETClient, message As ChatMessage, suggestedResponseType As Integer, args As String) As ChatResponse
		  
		  Return Action(client, message, suggestedResponseType, args)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function handleCommand(client As BNETClient, acl As UserAccess, message As ChatMessage) As ChatResponse
		  
		  If acl = Nil Then Return Nil
		  
		  Dim suggestedResponseType As Integer
		  Dim cmd, args As String
		  Dim response As ChatResponse
		  
		  Select Case message.eventId
		  Case Battlenet.EID_TALK
		    suggestedResponseType = ChatResponse.TYPE_TALK
		  Case Battlenet.EID_EMOTE
		    suggestedResponseType = ChatResponse.TYPE_EMOTE
		  Case Battlenet.EID_WHISPER
		    suggestedResponseType = ChatResponse.TYPE_WHISPER
		  Case Else
		    Raise New KaleidoscopeException("Unable to handle command based on chat event id '" + Format(message.eventId, "-#") + "'")
		  End Select
		  
		  cmd  = NthField(message.text, " ", 1)
		  args = Mid(message.text, Len(cmd) + 2)
		  
		  For Each oCmd As BotCommand In BotCommand.registered
		    If oCmd.matchCheck(cmd) Then
		      If oCmd.aclAdmin And Not acl.aclAdmin Then Continue For
		      response = oCmd.execute(client, message, suggestedResponseType, args)
		      Exit For
		    End If
		  Next
		  
		  Return response
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function matchCheck(value As String) As Boolean
		  
		  Return Match(value)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Sub registerAll()
		  
		  BotCommand.registered.Append(New JoinCommand())
		  BotCommand.registered.Append(New OSCommand())
		  BotCommand.registered.Append(New TimeCommand())
		  BotCommand.registered.Append(New VersionCommand())
		  
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Action(client As BNETClient, message As ChatMessage, suggestedResponseType As Integer, args As String) As ChatResponse
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Match(value As String) As Boolean
	#tag EndHook


	#tag Property, Flags = &h0
		aclAdmin As Boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Shared registered() As BotCommand
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="aclAdmin"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
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
End Class
#tag EndClass