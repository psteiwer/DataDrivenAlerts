# DataDrivenAlerts
Custom Action in InterSystems IRIS Business Intelligence for configuring and receiving Data Driven Alerts

After installation and completing a couple configuration steps (about 5 minutes), a custom action can be defined for a Widget on a Dashboard that will allow users to define alert conditions for the specific widget. These conditions will be checked on a defined interval and an email will be sent to the specified user when the condition is met.

# Instllation
1. Use the Download ZIP option for this project
2. Extract the files and copy path
	* This is the path to the directory that contains README.md and LICENSE
3. Open terminal and ZN to desired namespace
4. Run the following commands:
```
	set path="<PATH FROM STEP 2>"
	do $system.OBJ.LoadDir(path_"/DataDrivenAlerts/","ck",,1)
```
5. Follow the Configuration steps

# Configuration steps
## Define the custom action
Since a custom action is being used to present this feature to users, the custom action must be defined. For more information, please see the <a href="http://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=D2IMP_ch_action">documentation</a> for defining custom actions. In your Action KPI, define the new action as:
```
<action name="DataDrivenAlert" displayName="DataDrivenAlert"/>
```
Additionally in your Action KPI, define the new condition in %OnDashboardAction as:
```
If (pAction="DataDrivenAlert") {
	Set pContext.command = ##class(DataDrivenAlerts.Utils).GenerateCommand(pContext)
}
```

## Define a User-defined Icon
This icon will serve as the clickable icon that will trigger the action from a widget. This step is optional and can be replaced with your own icon, or simply a text label.

Take /Assets/DataDrivenAlerts.png and copy it into <install dir>/CSP/broker/images/. Next, navigate to the User-defined Icons tab in the Analytics Settings (Managment Portal -> Analytics -> Admin -> Settings -> User-defined Icons). Create a new Icon definition and name it "DataDrivenAlerts" with a path of "images/DataDrivenAlert.png".
*Note: This can also be a remote image path.*
	
Additional <a href="http://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=D2IMP_ch_settings#D2IMP_settings_icons">documentation</a> is available for User-Defined Icons.

## Configure Task Manager Email Settings
Alerts are delivered by Email. The Task Manager Email must be configured to allow alerts to be delivered by Email. At a minimum, the SMTP Server must be assigned in the Task Manager Email Settings (Management Portal -> System Administration -> Configuration -> Additional Settings -> Task Manager Email). For more information, please see the <a href="http://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=RACS_Category_TaskManagerEmail">documentation</a>.


# Adding the Custom Action to a Widget
Now that the Custom Action has been configured, a new control can be added to use DataDrivenAlerts.

In the Control Wizard, the new custom action can be selected in the "Action" dropdown. It will be called "DataDrivenAlert" (or your custom name). If a User-defined Icon was defined, it will be available in the "Control Label or Icon" dropdown. After selecting OK, the custom action will be added to your Widget.
