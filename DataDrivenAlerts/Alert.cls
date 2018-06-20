Class DataDrivenAlerts.Alert Extends %Persistent
{

Property Active As %Boolean [ InitialExpression = 1 ];

Property Cube As %String;

Property Dashboard As %String(MAXLEN = 32000);

Property FilterSpec As %String(MAXLEN = 32000);

Property Frequency As %Integer;

Property Measure As %String;

Property Operator As %String;

Property Query As %String(MAXLEN = 32000);

Property Repeatable As %Boolean;

Property User As %String;

Property Value As %Integer;

Storage Default
{
<Data name="AlertDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Active</Value>
</Value>
<Value name="3">
<Value>Cube</Value>
</Value>
<Value name="4">
<Value>Dashboard</Value>
</Value>
<Value name="5">
<Value>FilterSpec</Value>
</Value>
<Value name="6">
<Value>Frequency</Value>
</Value>
<Value name="7">
<Value>Measure</Value>
</Value>
<Value name="8">
<Value>Operator</Value>
</Value>
<Value name="9">
<Value>Query</Value>
</Value>
<Value name="10">
<Value>User</Value>
</Value>
<Value name="11">
<Value>Value</Value>
</Value>
<Value name="12">
<Value>Repeatable</Value>
</Value>
</Data>
<DataLocation>^DataDrivenAlerts.AlertD</DataLocation>
<DefaultData>AlertDefaultData</DefaultData>
<IdLocation>^DataDrivenAlerts.AlertD</IdLocation>
<IndexLocation>^DataDrivenAlerts.AlertI</IndexLocation>
<StreamLocation>^DataDrivenAlerts.AlertS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
