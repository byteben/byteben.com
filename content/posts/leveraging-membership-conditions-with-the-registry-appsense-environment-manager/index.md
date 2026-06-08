---
title: "Leveraging OU Membership Conditions with the Registry in AppSense Environment Manager"
date: 2013-03-04
categories:
  - "AppSense"
  - "AppSense - Environment Manager - Scripts"
  - "AppSense Environment Manager"
  - "AppSense Environment Manager Configurations"
---

So I have quickly learned that I can satisfy a lot of my "membership" conditional triggers by referencing a registry key rather than looking up the Active Directory. This is especially useful on "Computer-Start-up" triggers. In my experience, when the computer boots, the network is not always ready by the time we kick off a conditional trigger for Computer Group Membership. If the network is not ready and we try to look-up our AD on "Computer Start-up" then that condition will fail. So how can we get around this? <!--more-->Simple! We wait until "User Logon" before we do our AD Group membership look-up and then set a HKLM registry value to be used as a reference for future location based conditional triggers. A HKLM registry key can always be referenced by our EM agents on "Computer-Startup" even if the network is not ready.

So am I going to give an example below? Sure :)

The example below will interrogate a Computer's Organisational Unit in Active Directory (Yes, I have a corporate OU structure for all my computer objects and yes it is a pain when IT staff move a computer and forget to update it's OU membership in Active Directory..You can lead a horse to water etc). We hang a lot of queries off our OU structure, not only in AppSense but also LANDesk and some custom vb scrips. Anyway, to the point..Once we have interrogated the OU we will stamp this value in the HKLM Registry so we can look it up at next Computer Startup.

1\. So as suggested, let us interrogate our Active Directory at User Logon. Create a new node under "User Logon", I called it "OU Membership" in my example.

[![Leveraging Location Based Conditions with the Registry in AppSense Environment Manager](/images/2013/03/Leveraging-Location-Based-Conditions-with-the-Registry-in-AppSense-Environment-Manager.jpg)](http://byteben.com/bb/images/2013/03/Leveraging-Location-Based-Conditions-with-the-Registry-in-AppSense-Environment-Manager.jpg)

2\. Lets go ahead and create a condition. Right click in the right pane and choose "Conditions - Directory Membership - Computer OU Membership"

[![Leveraging Location Based Conditions with the Registry in AppSense Environment Manager](/images/2013/03/Leveraging-Location-Based-Conditions-with-the-Registry-in-AppSense-Environment-Manager-2.jpg)](http://byteben.com/bb/images/2013/03/Leveraging-Location-Based-Conditions-with-the-Registry-in-AppSense-Environment-Manager-2.jpg)

3\. You will be presented with a Computer OU Membership browse window. Simply click the highlighted browse button and choose whic Computer OU you want to match. All Sub OUs are automatically selected unless you un-tick the "Include Sub-OUs in match" box. Note# Some clever people may like to type the full LDAP string in the "Match" box at this point, feel free but if your spelling and grammar is as bad as mine stick to the browse button (highlighted with the red circle).

[![Leveraging Location Based Conditions with the Registry in AppSense Environment Manager](/images/2013/03/Leveraging-Location-Based-Conditions-with-the-Registry-in-AppSense-Environment-Manager-3.jpg)](http://byteben.com/bb/images/2013/03/Leveraging-Location-Based-Conditions-with-the-Registry-in-AppSense-Environment-Manager-3.jpg)

4\. Click "Ok" once you have selected the OU you want to match.

5\. Ok, there is our condition. Now lets set an action to create a registry key if the condition is met with a success. Right click your newly created condition and choose "Actions - Registry - Set Value".

[![Leveraging Location Based Conditions with the Registry in AppSense Environment Manager](/images/2013/03/Leveraging-Location-Based-Conditions-with-the-Registry-in-AppSense-Environment-Manager-4.jpg)](http://byteben.com/bb/images/2013/03/Leveraging-Location-Based-Conditions-with-the-Registry-in-AppSense-Environment-Manager-4.jpg)

6\. Now you are presented with a "Set Value" window. Click the "Add" button and choose what registry value you want to set. This value will be used to identify your Computers OU for any "Computer Start-up" conditions that you refer to this key with. For example.. above, my condition is looking for a Computer OU that matches "Computers - Windows 7 Test" so i will give my registry value a name of "Computer OU" and set the value to something similar to my condition e.g "Computers - Windows 7 Test".

Ok, I skipped a bit too far ahead. Where in the registry should you set this value? I put all my conditional reg flags under the same key for ease of use. In this example I am setting the registry value under "HKLM\\SOFTWARE\\AppSense\\Custom Actions".

[![Leveraging Location Based Conditions with the Registry in AppSense Environment Manager](/images/2013/03/Leveraging-Location-Based-Conditions-with-the-Registry-in-AppSense-Environment-Manager-5.jpg)](http://byteben.com/bb/images/2013/03/Leveraging-Location-Based-Conditions-with-the-Registry-in-AppSense-Environment-Manager-5.jpg)

7\. Now your config should look a little like this.

[![Leveraging Location Based Conditions with the Registry in AppSense Environment Manager](/images/2013/03/Leveraging-Location-Based-Conditions-with-the-Registry-in-AppSense-Environment-Manager-6.jpg)](http://byteben.com/bb/images/2013/03/Leveraging-Location-Based-Conditions-with-the-Registry-in-AppSense-Environment-Manager-6.jpg)

That is it really. Once the computer gets this config it will interrogate the Computer OU at user logon and set a registry value in the HKLM registry. You can now use this registry value for any "Computer OU" conditional queries in your "Computer Start-up" config without worrying about network timeout issues.

The same principal can be applied to User OU conditional queries too in some circumstances..its quicker to look up a registry value than interrogate AD and quick boot times are a users favorite thing after their first cup of coffee.

Happy Days :)

## Leveraging Membership Conditions with the Registry in AppSense Environment Manager

### Leveraging Membership Conditions with the Registry in AppSense Environment Manager