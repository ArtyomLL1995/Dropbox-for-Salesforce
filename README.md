# Dropbox for Salesforce

In Dropbox_Api class there are number of methods that allow to interact with Dropbox api, such as upload file to Dropbox from Salesforce and directly from Javascript, creating folder in Dropbox, getting folder / file info, getting content of a folder info, searching within Dropbox account, downloading file from Dropbox to local machine, etc.

Before making api calls you will need to setup Auth.Provider. After installing Classes, Named Credentials and Auth.Provider, go to Auth.Provider in your org, find Dropbox provider
and click 'Edit'. Then put api key and api secret from your Dropbox Connected App. Go to https://www.dropbox.com/developers then click 'App Console' then click 'Create App'. Be carefull with permission scopes. To make this integration fully work you will need files.content.write and files.content.read for free accounts. For paid team accounts you will need files.content.write, files.content.read and team_data.member scopes.

After setting up your Auth.Provider take callback url from Salesforce Configuration section and put it to the Redirect URIs section of your connected app. Then go to Named Credentials.
Click each of 3 named credentials then click 'Edit'. For 'Authentication Provider' choose 'Dropbox'. Check 'Start Authentication Flow on Save' checkbox. It must be checked. Then click 'Save'. Authentication Status should be changed from 'Pending' to 'Authenticated'. If everything setup correctly you should have access to the Dropbox api and can use the classes. Or you can create your own set of classes based on https://www.dropbox.com/developers/documentation/http/documentation


