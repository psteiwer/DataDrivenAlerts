Class DataDrivenAlerts.Task Extends %SYS.Task.Definition
{

Parameter TaskName = "DeepSee Alert";

Method OnTask() As %Status
{
	Try {
		Set tSQL="Select ID,Frequency From DeepSeeExtensions_Alerts.Alert WHERE Active=1"
		Set tRS=##class(%SQL.Statement).%ExecDirect(,tSQL)
		While tRS.%Next() {
			If tRS.%Get("Frequency")=24 {
				If ($P($H,",",2)/3600)>1 {
					Continue
				}
			}
			Set tAlert=##class(DeepSeeExtensions.Alerts.Alert).%OpenId(tRS.%Get("ID"))
			Set tMDX=tAlert.Query
			If tAlert.FilterSpec'="" {
				Set tMDX="SELECT "_tAlert.Measure_" on 0 FROM ["_tAlert.Cube_"] "_tAlert.FilterSpec
			}
			Set tRS2=##class(%DeepSee.ResultSet).%ExecuteDirect(tMDX)
			Set tValue = tRS2.%GetOrdinalValue(1,1)
			//Compare the result with the target and call a method
			Set tRes=""
			If tAlert.Operator=">" {
				set tRes=tValue>tAlert.Value
			} elseif tAlert.Operator="<" {
				set tRes=tValue<tAlert.Value
			} elseif tAlert.Operator="=" {
				set tRes=tValue=tAlert.Value
			}
			
			If tRes {
				Do ..SendAlert(.tAlert)
				Set tAlert.Active=0
				Do tAlert.%Save()
			}
		}
		Set status = $$$OK
	} Catch ex {
		Set status = ex.AsStatus()
	} 
	
	Quit status
}

Method SendAlert(pAlert As DeepSeeExtensions.Alerts.Alert) As %Status
{
	Set tSC=$$$OK
	Set tMail=##class(%Net.MailMessage).%New()
	Do tMail.To.Insert("psteiwer@intersystems.com")
 	Set tMail.From="DeepSeeExtensions"
 	Set tSMTP=##class(%Net.SMTP).%New()
 	Set tSMTP.smtpserver=##class(%SYS.Task.Config).GetData("MailServer")
	If tSC {
		Set tMail.IsHTML=1
 		Set tMail.Subject="Alert condition of "_pAlert.Measure_pAlert.Operator_pAlert.Value_" has been met"
 		Do tMail.TextData.WriteLine("<p>Dear "_pAlert.User_",")
 		Do tMail.TextData.WriteLine("<br/><br/>This message is to inform you that the alert condition of "_pAlert.Measure_pAlert.Operator_pAlert.Value_" has been met.")
 		Do tMail.TextData.WriteLine("<br/>Please <a href="""_pAlert.Dashboard_""">click here</a> to view the dashboard this alert was created from")
	}
	
	Set tSC=tSMTP.Send(tMail)
	
	Quit tSC
}

ClassMethod ConfigureTask() As %Status
{
	Set tSQL="Select Frequency From DeepSeeExtensions_Alerts.Alert WHERE Active=1"
	Set tRS=##class(%SQL.Statement).%ExecDirect(,tSQL)
	Set tHasTasks=0
	Set tFrequency=24
	While tRS.%Next() {
		Set tHasTasks=1
		If tFrequency>tRS.%Get("Frequency") {
			Set tFrequency=tRS.%Get("Frequency")
		}
	}
	
	//Does task exist? If so, update. Else, create
	Set tFullName = ..#TaskName _ " - " _ $NAMESPACE
	Set tTaskID = ##class(%SYS.Task).FindId(tFullName)
	If tTaskID = "" {
		// Task is not present, need to create one
		Set tTask = ##class(%SYS.Task).%New()
		Set tTask.Name = tFullName
		Set tTask.NameSpace = $NAMESPACE
	} Else {
		// Task has already been defined, save it with the current schedule
		Set tTask = ##class(%SYS.Task).%OpenId(tTaskID,,.tSC)
	}
	
	Set tTask.TaskClass = "DeepSeeExtensions.Alerts.Task"
	Set tTask.RunAsUser = "_SYSTEM"
	Set tTask.Description = "Executes DeepSeeExtensions Alerts"
	
	// Set schedule according to passed in parameters
	Set tTask.TimePeriod = 0			
	Set tTask.TimePeriodEvery = 1 	
	Set tTask.TimePeriodDay = ""
	
	// Build runs at most once every day
	Set tTask.DailyFrequency = 1
	Set tTask.DailyFrequencyTime = 1
	Set tTask.DailyIncrement = tFrequency
	Set tTask.DailyStartTime = 0
	Set tTask.DailyEndTime = 0
	
	// The task should be operational at the next available build time
	Set tSC = tTask.StartDateSet(+$h)
	If $$$ISERR(tSC) Quit
		
	Set tSC = tTask.%Save()
	Quit tSC
}

}
