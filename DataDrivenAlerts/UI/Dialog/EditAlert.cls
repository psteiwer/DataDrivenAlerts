Class DataDrivenAlerts.UI.Dialog.EditAlert Extends %DeepSee.UI.Dialog.standardDialog
{

Parameter APPLYBUTTON = 0;

Property AlertId As %ZEN.Datatype.integer(ZENURL = "ALERTID");

Property Username As %ZEN.Datatype.string(ZENURL = "USERNAME");

Property Query As %ZEN.Datatype.string(ZENURL = "QUERY");

Property CurrFilterSpec As %ZEN.Datatype.string(ZENURL = "CURRFILTERSPEC");

Property CubeName As %ZEN.Datatype.string(ZENURL = "CUBENAME");

/// Contents of the dialog body.
XData dialogBody [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane xmlns="http://www.intersystems.com/zen" import="" cellStyle="padding-bottom:8px;">
<vgroup>
<text id="alertid" hidden="true" value="0"/>
<text id="user" label="Username" readOnly="true" required="true" onkeydown="return zenPage.ctrlKeyDown(zenEvent);"/>
<text id="email" label="Email" required="true" onkeydown="return zenPage.ctrlKeyDown(zenEvent);"/>
<text id="cubename" label="Cube Name" hidden="true" required="true" onkeydown="return zenPage.ctrlKeyDown(zenEvent);"/>
<text id="dashboard" hidden="true" label="Dashboard" required="true" onkeydown="return zenPage.ctrlKeyDown(zenEvent);"/>
<radioSet id="frequency" label="Frequency" required="true" displayList="Hourly,Daily" valueList="1,24"/>
<radioSet id="repeatable" label="Repeatable" required="true" displayList="Yes,No" valueList="1,0"/>
<textarea id="query" hidden="true" label="Query" required="true" readOnly="true"/>
<textarea id="currfilterspec" hidden="true" label="Current Filter Spec" required="true" readOnly="true"/>
<label id="label" value="Alert when:"/>
<hgroup>
<label id="cell" value="Selected Cell"/>
<select id="measure" hidden="true" required="false" label="Measure"/>
<spacer width="5px"/>
<select id="operator" required="true" displayList="&lt;,&gt;,=" valueList="&lt;,&gt;,="/>
<spacer width="5px"/>
<text id="value" required="true" onkeydown="return zenPage.ctrlKeyDown(zenEvent);"/>
</hgroup>
<label id="customemail" value="Customize Email"/>
<text id="customsubject" label="Custom Subject"/>
<textarea id="custommessage" label="Custom Message"/>
</vgroup>
</pane>
}

/// Apply changes to page.
Method %OnAfterCreatePage() As %Status
{
	If ..AlertId {
		Set tAlert = ##class(DataDrivenAlerts.Alert).%OpenId(..AlertId)
		Set ..%GetComponentById("alertid").value = ..AlertId
		Set ..%GetComponentById("user").value = tAlert.User
		Set ..%GetComponentById("email").value = tAlert.Email
		Set ..%GetComponentById("cubename").value = tAlert.Cube
		Set ..%GetComponentById("dashboard").value = tAlert.Dashboard
		Set ..%GetComponentById("frequency").value = tAlert.Frequency
		Set ..%GetComponentById("repeatable").value = tAlert.Repeatable
		Set ..%GetComponentById("query").value = tAlert.Query
		Set ..%GetComponentById("currfilterspec").value = tAlert.FilterSpec
		Set ..%GetComponentById("measure").value = tAlert.Measure
		Set ..%GetComponentById("operator").value = tAlert.Operator
		Set ..%GetComponentById("value").value = tAlert.Value
		Set ..%GetComponentById("customsubject").value = tAlert.CustomSubject
		Set ..%GetComponentById("custommessage").value = tAlert.CustomMessage
	} Else {
		Set ..%GetComponentById("user").value = ..Username
		Set ..%GetComponentById("query").value = ..Query
		Set ..%GetComponentById("currfilterspec").value = ..CurrFilterSpec
		Set ..%GetComponentById("cubename").value = ..CubeName
		Set ..%GetComponentById("dashboard").value = %request.CgiEnvs("HTTP_REFERER")
	}
	
	// Load Measures
	set tDisplayList=""
	set tValueList=""
	set tSC = ##class(%DeepSee.Utils).%GetCubeMeasures(..CubeName,.measures)
	set m=$o(measures(""))
	while m'="" {
		Set tDisplayList=tDisplayList_$lb($LG(measures(m),2))
		Set tValueList=tValueList_$lb($LG(measures(m),1))
		set m=$o(measures(m))
	}
	set measureSelect=..%GetComponentById("measure")
	set measureSelect.displayList=$lts(tDisplayList)
	set measureSelect.valueList=$lts(tValueList)
	
	Quit $$$OK
}

/// Get the (localized) title string for the dialog.
/// This should be implemented in a subclass.
Method %OnGetTitle() As %String
{
	Quit $$$TextHTML("Alert Editor")
}

/// Get the (localized) subtitle string for the dialog.
/// This should be implemented in a subclass.
Method %OnGetSubtitle() As %String
{
	Quit $$$TextHTML("Edit alert details")
}

/// This callback, if defined, is called when the user presses the OK or Apply action buttons.
/// If this returns false, then the action is cancelled.<br>
ClientMethod ondialogFinish(action) As %Boolean [ Language = javascript ]
{
	try {
		this.saveAlert();
		return true;
	}
	catch(ex) {
		zenExceptionHandler(ex,arguments);
	}
	return false;
}

/// This callback, if defined, is called when the dialog page is loaded.
ClientMethod ondialogStart() [ Language = javascript ]
{
	zen("btnOK").focus();
	zen("btnOK").setProperty("caption",$$$Text("Save Alert"));
}

/// Pulls info from the page and calls a server method to create the alert
ClientMethod saveAlert() [ Language = javascript ]
{
	zen('btnOK').setDisabled(true);
	var alertid=zen('alertid').getValue();
	var cube=zen('cubename').getValue();
	var dashboard=zen('dashboard').getValue();
	var filterspec=zen('currfilterspec').getValue();
	var frequency=zen('frequency').getValue();
	var repeatable=zen('repeatable').getValue();
	var query=zen('query').getValue();
	var measure=zen('measure').getValue();
	var operator=zen('operator').getValue();
	var user=zen('user').getValue();
	var email=zen('email').getValue();
	var value=zen('value').getValue();
	var customsubject=zen('customsubject').getValue();
	var custommessage=zen('custommessage').getValue();
	this.AlertSave(alertid,cube,dashboard,filterspec,frequency,repeatable,measure,operator,query,user,email,value,customsubject,custommessage);
	return;
}

/// Creates a new alert with provided information
ClassMethod AlertSave(pAlertId As %Integer, pCube As %String, pDashboard As %String, pFilterSpec As %String, pFrequency As %Integer, pRepeatable, pMeasure As %String, pOperator As %String, pQuery As %String, pUser As %String, pEmail As %String, pValue As %Integer, pCustomSubject As %String, pCustomMessage As %String) As %Status [ ZenMethod ]
{
	If pAlertId'=0 {
		Set tAlert=##class(DataDrivenAlerts.Alert).%OpenId(pAlertId)
	} Else {
		Set tAlert=##class(DataDrivenAlerts.Alert).%New()
	}
	Set tAlert.Cube=pCube
	Set tAlert.Dashboard=pDashboard
	Set tAlert.FilterSpec=pFilterSpec
	Set tAlert.Frequency=+pFrequency
	Set tAlert.Repeatable=pRepeatable
	Set tAlert.Measure=pMeasure
	Set tAlert.Operator=pOperator
	Set tAlert.Query=pQuery
	Set tAlert.User=pUser
	Set tAlert.Email=pEmail
	Set tAlert.Value=+pValue
	Set tAlert.CustomSubject=pCustomSubject
	Set tAlert.CustomMessage=pCustomMessage
	Set tSC=tAlert.%Save()
	If $$$ISERR(tSC) Quit tSC
	
	Set tSC=##class(DataDrivenAlerts.Task).ConfigureTask()
	
	Quit tSC
}

/// Get the value that will be applied when the user presses the OK button.
/// This is implemented by subclasses.
ClientMethod getDialogValue() [ Language = javascript ]
{
	return '';
}

}
