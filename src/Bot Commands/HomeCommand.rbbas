#tag Class
Protected Class HomeCommand
Inherits BotCommand
	#tag Event
		Function Action(client As BNETClient, message As ChatMessage, suggestedResponseType As Integer, args As String) As ChatResponse
		  
		  #pragma Unused message
		  #pragma Unused suggestedResponseType
		  #pragma Unused args
		  
		  Return New ChatResponse(ChatResponse.TYPE_PACKET, Packets.CreateBNET_SID_JOINCHANNEL(&H02, client.config.homeChannel))
		  
		End Function
	#tag EndEvent

	#tag Event
		Function Match(value As String, trigger As String) As Boolean
		  
		  #pragma Unused trigger
		  
		  Return (value = "home")
		  
		End Function
	#tag EndEvent


	#tag Method, Flags = &h1000
		Sub Constructor()
		  
		  Super.Constructor(True)
		  
		End Sub
	#tag EndMethod


	#tag ViewBehavior
		#tag ViewProperty
			Name="aclAdmin"
			Group="Behavior"
			Type="Boolean"
			InheritedFrom="BotCommand"
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
