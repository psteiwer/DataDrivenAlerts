Class DataDrivenAlerts.Utils
{

/// Generates the string to be returned in pContext.command
ClassMethod GenerateCommand(ByRef pContext) As %String
{
	Set tCommand = "popup:DataDrivenAlerts.UI.CreateAlert.cls?USERNAME="_$zconvert($username,"O","URL")
	
	If pContext.mdx'=""{
		Set tCommand = tCommand_"&QUERY="_$zconvert(pContext.mdx,"O","URL")
	}
	
	If pContext.currFilterSpec'="" {
		Set tCommand = tCommand_"&CURRFILTERSPEC="_$zconvert(pContext.currFilterSpec,"O","URL")
	}
	
	If pContext.cubeName'="" {
		Set tCommand = tCommand_"&CUBENAME="_$zconvert(pContext.cubeName,"O","URL")
	}
	
	Quit tCommand
}

}