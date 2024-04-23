# Dropbox API Integration Guide

In the Dropbox_Api class there are methods designed to facilitate various actions such as uploading files to Dropbox, creating folders, retrieving file/folder information, searching within Dropbox, downloading files locally, and more. Follow these steps to set up the integration properly:

## Install Necessary Components: 

Begin by installing the required components including Classes, Named Credentials, and Auth Provider in your Salesforce org.

## Obtaining API Key and Secret: 

1. Go to [Dropbox Developer Console](https://www.dropbox.com/developers/reference/getting-started)

2. Click 'App Console', click 'Create App' if your app has not beed created. Take API key and API secret from your Dropbox connected app.

## Ensure you set permission scopes carefully. 

* For free accounts, you'll need files.content.write and files.content.read.

* For paid team accounts: team_data.member, files.content.write, files.content.read.


## Setting up Authentication Provider

Edit Auth Provider: Navigate to Auth Provider in your org, locate the Dropbox provider, and click 'Edit'. Input the API key and API secret obtained from your Dropbox Connected App.

## Redirect URIs Configuration

Retrieve the callback URL from the Salesforce Configuration section and add it to the 'Redirect URIs' section of your Dropbox connected app.

## Named Credentials Configuration

Edit each of the three credentials. Choose 'Dropbox' as the 'Authentication Provider' and ensure the 'Start Authentication Flow on Save' checkbox is selected.

Save the Named Credentials. The Authentication Status should change from 'Pending' to 'Authenticated'.

## Accessing Dropbox API

Once the setup is complete and authentication is successful, you'll have access to the Dropbox API through the provided classes. These classes will enable you to perform various operations seamlessly.

## Custom Implementation
Alternatively, you can create your own set of classes based on https://www.dropbox.com/developers/documentation/http/documentation
Customize and adapt these classes to fit your specific requirements, ensuring error handling and readability are maintained throughout the implementation.


