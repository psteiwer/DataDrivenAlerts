# DataDrivenAlerts
Custom Action in InterSystems IRIS Business Intelligence for Data Driven Alerts

After importing and compleating a couple configuration steps, a custom action can be defined for a Widget on a Dashboard that will allow users to define alert conditions for the specific widget. These conditions will be checked on a defined interval and an email will be sent to the specified user when the condition is met.

# Configuration setps
## Define the custom action
Since a custom action is being used to present this feature to users, the custom action must be defined. For more information, please see the <a href src="http://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=D2IMP_ch_action">documentation</a> for defining custom actions. Define the action name as "DataDrivenAlert" (or any name you prefer). The condition in %OnDashboardAction should be:
```
If (pAction="DataDrivenAlert") {
	Set pContext.command = "popup:DataDrivenAlerts.UI.CreateAlert.cls?USERNAME="_$zconvert($username,"O","URL")_"&QUERY="_$zconvert(pContext.mdx,"O","URL")_"&CURRFILTERSPEC="_$zconvert(pContext.currFilterSpec,"O","URL")_"&CUBENAME="_$zconvert(pContext.cubeName,"O","URL")
}
```
If you did not define the action name as"DataDrivenAlert", please use your action name in the If statement.

## Define a User-defined Icon
This icon will serve as the clickable icon that will trigger the action from a widget. This step is optional and can be replaced with your own icon, or simply a text label.

Take /Assets/DataDrivenAlerts.png and copy it into <install dir>/CSP/broker/images/. Next, navigate to the User-defined Icons tab in the Analytics Settings (Managment Portal -> Analytics -> Admin -> Settings -> User-defined Icons). Create a new Icon definition and name it "DataDrivenAlerts" with a path of "images/DataDrivenAlert.png".
*Note: This can also be a remote image path.*
	
Additional <a href src="http://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=D2IMP_ch_settings#D2IMP_settings_icons">documnetation</a> is available for User-Defined Icons.
