Class DataDrivenAlerts.UI.CreateAlert Extends %DeepSee.UI.Dialog.standardDialog
{

Parameter APPLYBUTTON = 0;

Property Username As %ZEN.Datatype.string(ZENURL = "USERNAME");

Property Query As %ZEN.Datatype.string(ZENURL = "QUERY");

Property CurrFilterSpec As %ZEN.Datatype.string(ZENURL = "CURRFILTERSPEC");

Property CubeName As %ZEN.Datatype.string(ZENURL = "CUBENAME");

/// Contents of the dialog body.
XData dialogBody [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane xmlns="http://www.intersystems.com/zen" import="" cellStyle="padding-bottom:8px;">
<vgroup>
<text id="user" label="Username" readOnly="true" required="true" onkeydown="return zenPage.ctrlKeyDown(zenEvent);"/>
<text id="cubename" label="Cube Name" hidden="true" required="true" onkeydown="return zenPage.ctrlKeyDown(zenEvent);"/>
<text id="dashboard" hidden="true" label="Dashboard" required="true" onkeydown="return zenPage.ctrlKeyDown(zenEvent);"/>
<radioSet id="frequency" label="Frequency" required="true" displayList="1 Hour,24 Hours" valueList="1,24"/>
<textarea id="query" hidden="true" label="Query" required="true" readOnly="true"/>
<textarea id="currfilterspec" hidden="true" label="Current Filter Spec" required="true" readOnly="true"/>
<select id="measure" required="true" label="Measure"/>
<select id="operator" required="true" label="Operator" displayList="&lt;,&gt;,=" valueList="&lt;,&gt;,="/>
<text id="value" label="Value" required="true" onkeydown="return zenPage.ctrlKeyDown(zenEvent);"/>
</vgroup>
</pane>
}

/// Apply changes to page.
Method %OnAfterCreatePage() As %Status
{
	Set ..%GetComponentById("user").value = ..Username
	Set ..%GetComponentById("query").value = ..Query
	Set ..%GetComponentById("currfilterspec").value = ..CurrFilterSpec
	Set ..%GetComponentById("cubename").value = ..CubeName
	Set ..%GetComponentById("dashboard").value = %request.CgiEnvs("HTTP_REFERER")
	
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
	Quit $$$TextHTML("Create Alert")
}

/// Get the (localized) subtitle string for the dialog.
/// This should be implemented in a subclass.
Method %OnGetSubtitle() As %String
{
	Quit $$$TextHTML("Create a new alert")
}

/// This callback, if defined, is called when the user presses the OK or Apply action buttons.
/// If this returns false, then the action is cancelled.<br>
ClientMethod ondialogFinish(action) As %Boolean [ Language = javascript ]
{
	try {
		this.addAlert();
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
	zen("btnOK").setProperty("caption",$$$Text("Add Alert"));
}

ClientMethod addAlert() [ Language = javascript ]
{
	zen('btnOK').setDisabled(true);
	var cube=zen('cubename').getValue();
	var dashboard=zen('dashboard').getValue();
	var filterspec=zen('currfilterspec').getValue();
	var frequency=zen('frequency').getValue();
	var query=zen('query').getValue();
	var measure=zen('measure').getValue();
	var operator=zen('operator').getValue();
	var user=zen('user').getValue();
	var value=zen('value').getValue();
	this.AddNewAlert(cube,dashboard,filterspec,frequency,measure,operator,query,user,value);
	return;
}

ClassMethod AddNewAlert(pCube As %String, pDashboard As %String, pFilterSpec As %String, pFrequency As %Integer, pMeasure As %String, pOperator As %String, pQuery As %String, pUser As %String, pValue As %Integer) As %Status [ ZenMethod ]
{
	Set tAlert=##class(DataDrivenAlerts.Alert).%New()
	Set tAlert.Cube=pCube
	Set tAlert.Dashboard=pDashboard
	Set tAlert.FilterSpec=pFilterSpec
	Set tAlert.Frequency=+pFrequency
	Set tAlert.Measure=pMeasure
	Set tAlert.Operator=pOperator
	Set tAlert.Query=pQuery
	Set tAlert.User=pUser
	Set tAlert.Value=+pValue
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
