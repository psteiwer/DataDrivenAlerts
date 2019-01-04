Include %DeepSee

Class DataDrivenAlerts.UI.AlertManager Extends %DeepSee.UI.standardPage [ System = 4 ]
{
Parameter DOMAIN = "DataDrivenAlerts";

Parameter Version = 1;

/// Displayed name of this page.
Parameter PAGENAME = "Data Driven Alerts Manager";

/// If this page has multiple views, this is its initial display mode.
Parameter DEFAULTVIEWMODE;

Parameter DOCBOOKID;

XData contentPane [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane xmlns="http://www.intersystems.com/zen">
<hgroup valign="top" >
<spacer width="20" />
<vgroup valign="top" >
<spacer height="20" />
<tablePane id="table"
    cellSpacing="2"
	fixedHeaders="false"	
	queryClass="DataDrivenAlerts.UI.AlertManager"
	queryName="GetAlertsForDisplay"
	useSnapshot="true"
	showQuery="false"
	showZebra="true"
	showRowNumbers="false"
	maxRows="5000"
	valueColumn="ID"
	>
<column colName="ID" header="Alert ID" />
<column colName="Email" header="Email" />
<column onclick="zenPage.editAlert(#(%query.ID)#)" linkCaption="Edit" link="#"/>
<column onclick="return zenPage.deleteAlert('#(%query.ID)#');" linkCaption="Delete" link="#" />
</tablePane>
</vgroup>
</hgroup>
</pane>
}

/// Get the (localized) title string for the page.
Method %OnGetTitle() As %String [ Internal ]
{
	Quit $$$Text("Data Driven Alerts Manager","DataDrivenAlerts")
}

/// Get the (localized) name of the page.
Method %OnGetPageName() As %String [ Internal ]
{
	Quit $$$Text("Data Driven Alerts Manager","DataDrivenAlerts")
}

/// Get the product name for the page.
Method %OnGetProductName() As %String [ Internal ]
{
	Quit "DeepSee"
}

/// This client event is fired when a popup page launched from this page fires an action.
ClientMethod onPopupAction(popupName, action, value) [ Internal, Language = javascript ]
{
	switch(popupName) {
		case 'switchNamespace':
			var homeurl = zenLink("/csp/sys/%25CSP.Portal.Home.zen");
			var url = zenPage.GetNewURL(value,"DataDrivenAlerts.UI.AlertManager.cls");
			if (url == "" || value == "%SYS") url = homeurl;
			self.document.location = url;
			break;
		case 'DataDrivenAlerts':
			if (action=="okay") {
				try {
					self.document.location = zenLink('DataDrivenAlerts.UI.AlertManager.cls');
				}
				catch(ex) {
				}
			}
			break;
	}
}

/// Creates edit popup.
ClientMethod editAlert(alertId) [ Internal, Language = javascript ]
{
	var parms = {
			MODE:"models",
	};
	
	zenLaunchPopupWindow('DataDrivenAlerts.UI.Dialog.EditAlert.cls?ALERTID='+alertId,'DataDrivenAlerts','status,resizable=yes,width=900,height=700',parms);
}

/// Delete the selected alert.
ClientMethod deleteAlert(pID) [ Language = javascript ]
{
	if (pID!="") {
		if (confirm($$$Text('Do you really wish to delete this alert?'))) {
			this.Delete(pID)
			try {
				self.document.location = zenLink('DataDrivenAlerts.UI.AlertManager.cls');
			}
			catch(ex) {
			}
		}
	}
}

/// Delete an alert.
Method Delete(pID As %Integer) As %String [ ZenMethod ]
{
	Set tMsg = "Alert Deleted."
	
	Set tSC=##class(DataDrivenAlerts.Alert).%DeleteId(pID)
	If $$$ISERR(tSC) {
		Set tMsg = $System.Status.GetErrorText(tSC)
	}
	
	Quit tMsg
}

/// Query to get alerts for Alert Manager display table.
Query GetAlertsForDisplay() As %SQLQuery
{
	SELECT ID,Email FROM DataDrivenAlerts.Alert
}

}
