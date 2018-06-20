/// Logs task events
Class DataDrivenAlerts.TaskLog Extends %Persistent
{

Property Alert As DataDrivenAlerts.Alert;

Property AlertTriggered As %Boolean;

Property CurrentAlertActive As %Boolean;

Property Value As %Integer; 

ClassMethod LogTask(ByRef pAlert, pValue, pRes) As %Status
{
	Set tSC = $$$OK
	
	Set tTaskLog = ##class(DataDrivenAlerts.TaskLog).%New()
	Set tTaskLog.Alert = pAlert
	Set tTaskLog.AlertTriggered = pRes
	Set tTaskLog.CurrentAlertActive = pAlert.Active
	Set tTaskLog.Value = pValue
	
	Set tSC = tTaskLog.%Save()
	
	Quit tSC
}
Storage Default
{
<Data name="TaskLogDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Alert</Value>
</Value>
<Value name="3">
<Value>AlertTriggered</Value>
</Value>
<Value name="4">
<Value>CurrentAlertActive</Value>
</Value>
<Value name="5">
<Value>Value</Value>
</Value>
</Data>
<DataLocation>^DataDrivenAlerts.TaskLogD</DataLocation>
<DefaultData>TaskLogDefaultData</DefaultData>
<IdLocation>^DataDrivenAlerts.TaskLogD</IdLocation>
<IndexLocation>^DataDrivenAlerts.TaskLogI</IndexLocation>
<StreamLocation>^DataDrivenAlerts.TaskLogS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}