# Xojo-iCloudFolders
Xojo implementation for accessing iCloud folders on both macOS and iOS



## Setup

There are a few things that you need to do to add iCloud folder support to your Xojo macOS or iOS app. 

1. Copy the iCloud Module from one of the projects to your project.
2. Add needed pieces to your app on your Apple Developer Account
   1. Open the Portal https://developer.apple.com/account
   2. Select **Identifiers**
   3. If you don't already have an App Identifier for your app in this list, create one now. For this example we are using com.example.myapp as the bundle identifier. Save it.
   4. **Create the iCloud Container**
      1. Add a new Identifier, selecting **iCloud Containers** as the type.
      2. Give it a name that you'll remember and an identifier for your app. If you expect to have only one, use the same identifier as your app prefixed by iCloud (iCloud.com.example.myapp)
      3. Click Continue to save it.
   5. **Add the container to your app**
      1. Go back to the App Identifier for your app and edit it.
      2. Scroll down in the Capabilities list to iCloud and check it.
      3. Click the Edit button to the right and select the iCloud Container that you just created
      4. Click Continue to dismiss the dialog
      5. Click Save to save your changes. If this was an existing identifier, making this change will invalidate any existing profiles.
   6. **Update the profiles**
      1. Select **Profiles**
      2. The Development and Distribution profiles for your app should now **Invalid** under Expiration.
      3. For each of the Invalid profiles:
         1. Click the name to edit the profile
         2. Click Edit
         3. Click Save
   7. **Download profiles**
      1. Using Xcode
         1. Xcode > Preferences
         2. Click Accounts
         3. Select your account in the Apple IDs list
         4. Select your Team
         5. Click Download Manual Profiles
      2. Using Apple Profile Triage
         1. Edit > Profiles > Download
3. If you are working on an iOS project, 
   1. Enable the iCloud Capability in the Advanced panel of the iOS build target.
   2. Click the Options button
   3. Enable **iCloud Documents**
   4. Click Specify custom containers
   5. Add a container ID that matches the iCloud Container's identifier you created above in step 2.4.2
   6. Click OK

## Usage

To access the folder for your app in a user's iCloud folder, you need to take a few steps:

1. Call iCloud.iCloudAvailable. This is a very low-latency way to find out if the user has even enabled iCloud on their account on the current device. If this returns True, all of the rest of the methods in the iCloud module should now work. 
2. To create a reference to a file within the iCloud folder, you'll need to use the iCloud.iCloudFolder method. If your app has only one iCloud Container applied to it, you don't need to worry about the ID parameter. If it does, you'll need to pass in the ID of the container you are interested in (iCloud.com.example.myapp).
3. Once you have a folderitem, you can read/write to the file just as you would any other folderitem. See the API section below for more things you can do with a file.

## API

**EvictItem(f as FolderItem) As Boolean**

Removes a file from the local device, leaving it stored on the server in the user's iCloud folder.

**FileIsDownloaded(f as Folderitem) as iCloud.DownloadStatus**

While it feels like this should be a boolean, there are actually three states:

1. Downloaded & Current - The local version is the most recent version of the file.
2. Downloaded & Stale - The local version is **not** the most recent version of the file.
3. Not Downloaded - The file exists on the server but not locally.

**iCloudAvailable() as Boolean**

Returns True if the user has enabled iCloud on the current device.

**iCloudFolder(ID as String = "") As FolderItem**

Returns a folderitem that points to the iCloud folder for your app. The folderitem may be Nil if an error occurred. 

NOTE: If your folder didn't previously exist, it will be created when this method is called.

**IsICloudFile(f as Folderitem) as Boolean**

Returns True if the folderitem points to a file that is being synced with the user's iCloud account.

**StartDownloading(f as Folderitem) as Boolean**

Starts the downloading process. Throws a RuntimeException if the download failed for some reason.

## Examples

To use the example files, you'll need to update the bundle identifier for each of the apps as well as their iCloud Container IDs in the plist files and in the iOS Capabilities panel.

## Notes

#### iOS Debugging

It is important to remember that you must debug your iOS app on a device for this api to work. Using a simulator will give you a false positive in the iCloudAvailable method with iCloudFolder returning Nil. On-device debugging is available in Xojo 2022r1 and later.

#### Visible vs Non-Visible files

For files to be visible to the user, you need to create a folder named "Documents" within the folder that iCloudFolder returns.

#### PList File

NSUbiquitousContainers is a dictionary of iCloud Containers and requires you to have one entry per Container that you attached to your project in your Apple Developer Account if you want to have access to them at runtime. Each item within the dictionary is in itself a Dictionary of values specifying the parameters for creating and accessing the specific folder. These entries are:

1. NSUbiquitousContainerIsDocumentScopePublic: Boolean – Indicates whether or not the user should be able to see the folder.
2. NSUbiquitousContainerName: String – The name of the folder to be created.
3. NSUbiquitousContainerSupportedFolderLevels: String - The number of levels that can be created inside this folder:
   1. None - The iCloud drive only has access to the container's Documents directory and that your app promises that it does not create any directories inside the Documents directory. On macOS, the Finder will prevent users from creating subdirectories inside your app's iCloud Drive directory.
   2. One - The iCloud Drive has access to the app's Documents directory and one additional layer of subdirectories. Your app promises that it only creates a single layer of directories below the Documents directory. On macOS the Finder prevents users from creating more than one layer of subdirectories in the app's iCloud Drive directory.
   3. Any - The iCloud Drive has complete access to your app's Documents directory. Both your app and the Finder can create as many layers of subdirectories as are desired.

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSUbiquitousContainers</key>
    <dict>
        <key>iCloud.com.example.myapp</key>
        <dict>
            <key>NSUbiquitousContainerIsDocumentScopePublic</key>
            <true/>
            <key>NSUbiquitousContainerName</key>
            <string>My Example App</string>
            <key>NSUbiquitousContainerSupportedFolderLevels</key>
            <string>None</string>
        </dict>
    </dict>
</dict>
</plist>
```

