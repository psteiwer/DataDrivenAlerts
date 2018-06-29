Class DataDrivenAlerts.Task Extends %SYS.Task.Definition
{

Parameter TaskName = "DeepSee Alert";

/// Method is called when task is run. This task will find all alert conditions that need to be checked and the task will take action if necessary
Method OnTask() As %Status
{
	Set tSC=$$$OK
	Try {
		Set tSQL="Select ID,Frequency From DataDrivenAlerts.Alert WHERE Active=1"
		Set tRS=##class(%SQL.Statement).%ExecDirect(,tSQL)
		While tRS.%Next() {
			If tRS.%Get("Frequency")=24 {
				If ($P($H,",",2)/3600)>1 {
					Continue
				}
			}
			Set tAlert=##class(DataDrivenAlerts.Alert).%OpenId(tRS.%Get("ID"))
			Set tMDX=tAlert.Query
			If tAlert.FilterSpec'="" {
				Set tMDX="SELECT [MEASURES].["_tAlert.Measure_"] on 0 FROM ["_tAlert.Cube_"] "_tAlert.FilterSpec
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
				Set tSC=..SendAlert(.tAlert)
				Set:'tAlert.Repeatable tAlert.Active=0
				Do tAlert.%Save()
			}
			
			Set tSC = ##class(DataDrivenAlerts.TaskLog).LogTask(.tAlert,tValue,tRes,tSC,tMDX)
		}
	} Catch ex {
		Set tSC = ex.AsStatus()
	} 
	
	Quit tSC
}

/// The SendAlert will be triggered when the alert condition has been met. This method handles sending the email alert
Method SendAlert(pAlert As DataDrivenAlerts.Alert) As %Status
{
	Set tSC=$$$OK
	try {
		Set tMail=##class(%Net.MailMessage).%New()
		Do tMail.To.Insert(pAlert.Email)
	 	Set tMail.From="DataDrivenAlerts"
	 	Set tSMTP=##class(%Net.SMTP).%New()
	 	Set tMailServer=##class(%SYS.Task.Config).GetData("MailServer")
		If tMailServer'="" {
			Set tSMTP.smtpserver=tMailServer
			Set tMail.IsHTML=1
	 		Set tMail.Subject="Alert condition of "_pAlert.Measure_pAlert.Operator_pAlert.Value_" has been met"
	 		Do tMail.TextData.WriteLine("<p>Dear "_pAlert.User_",")
	 		Do tMail.TextData.WriteLine("<br/><br/>This message is to inform you that the alert condition of "_pAlert.Measure_pAlert.Operator_pAlert.Value_" has been met.")
	 		Do tMail.TextData.WriteLine("<br/>Please <a href="""_pAlert.Dashboard_""">click here</a> to view the dashboard this alert was created from")
	 		
	 		Set tSC=tSMTP.Send(tMail)
		} Else {
			Set tSC=$$$ERROR($$$GeneralError,"Mail server not configured")
		}
	} catch ex {
		Set tSC=ex.AsStatus()
	}
	
	Quit tSC
}

/// This method is called each time a new alert is created. It will create or update the task as needed
ClassMethod ConfigureTask() As %Status
{
	Set tSQL="Select Frequency From DataDrivenAlerts.Alert WHERE Active=1"
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
	
	Set tTask.TaskClass = "DataDrivenAlerts.Task"
	Set tTask.RunAsUser = "_SYSTEM"
	Set tTask.Description = "Executes DataDrivenAlerts Task"
	
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
