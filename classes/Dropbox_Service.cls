public class Dropbox_Service {

    public class DropboxApiException extends Exception {}

    // -------------------------------------------------------------------- 

    // Your user Team Member Id from DropBox. To get it you can use method Dropbox_Service.getTeamMemberId(). In 'userEmail' param put your Dropbox user email
    // Once you get it, store it somewhere secure, preferably in custom metadata and then put into dropboxAPISelectUser
    // If you are using basic 2GB plan, you won't have access to Team Member Id and you basically won't need it so you can skip this step and
    // leave dropboxAPISelectUser as null

    private static final String dropboxAPISelectUser;
    
    // -------------------------------------------------------------------- 

    // Your root instance id from Dropbox. To get root instance id you can use method Dropbox_Service.getRootId()

    private static final String rootId = ''; 

    // -------------------------------------------------------------------- 

    private static final String dropBoxApiPathRoot = '{".tag": "root", "root": "' + rootId +'"}';

    // -------------------------------------------------------------------- 

    // creates file under specified path
    // If you upload file from Salesforce attachments specify contentVersionId id of the file, fileName and base64 must be null
    // If you uploading file directly from Javascript, specify fileName, take fileBody, encode it in base64 format and put it into base64 param
    // path param defines where in Dropbox you want this file to be stored
    
    public static Dropbox_Entities.UploadedFileDto uploadFile(Id contentVersionId, String path, String fileName, String base64) {

        Dropbox_Entities.UploadedFileDto result;

        ContentVersion contentVersion;

        if (contentVersionId != null) {
            contentVersion = [
                SELECT Id, PathOnClient, VersionData 
                FROM ContentVersion 
                WHERE Id = :contentVersionId
                ];
        }
        
        Dropbox_Entities.UploadFileDto uploadFileData = new Dropbox_Entities.UploadFileDto();
        uploadFileData.path = contentVersion == null ? path + fileName : path + contentVersion.PathOnClient;
        uploadFileData.mode = 'add';
        uploadFileData.autorename = true;
        uploadFileData.mute = false;
        uploadFileData.strict_conflict = false;

        String dropboxAPIArg = JSON.serialize(uploadFileData);
            
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:DropboxContent/files/upload');
        req.setMethod('POST');
        req.setHeader('content-type', 'application/octet-stream');
        req.setHeader('Dropbox-API-Arg', dropboxAPIArg);

        if (dropboxAPISelectUser != null) {
            req.setHeader('Dropbox-API-Select-User', dropboxAPISelectUser);
        }
          
        req.setHeader('Dropbox-API-Path-Root', dropboxAPIPathRoot);  

        if (contentVersion != null) {
            req.setBodyAsBlob(contentVersion.VersionData);
        } else {
            Blob file = EncodingUtil.base64Decode(base64);
            req.setBodyAsBlob(file);
        }
        
        Http http = new Http();
        HTTPResponse res = http.send(req);

        if(res.getStatusCode() == 200){
            String data = res.getBody();
            result = (Dropbox_Entities.UploadedFileDto) JSON.deserialize(data, Dropbox_Entities.UploadedFileDto.class);
        } else {
            throw new DropboxApiException(res.getBody());
        }
        return result;
    }

    // creates folder under specified path
    public static Dropbox_Entities.CreatedFolderInfoDto createFolder(String path) {

        Dropbox_Entities.CreatedFolderInfoDto result;

        Dropbox_Entities.NewFolderToCreateDto newFolder = new Dropbox_Entities.NewFolderToCreateDto();
        newFolder.path = path;
        newFolder.autorename = false;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Dropbox/files/create_folder_v2');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        if (dropboxAPISelectUser != null) {
            req.setHeader('Dropbox-API-Select-User', dropboxAPISelectUser);
        }

        req.setHeader('Dropbox-API-Path-Root', dropBoxApiPathRoot);

        String body = JSON.serialize(newFolder);
        req.setBody(body);

        Http http = new Http();
        HTTPResponse res = http.send(req);

        if(res.getStatusCode() == 200) {
            String data = res.getBody();
            result = (Dropbox_Entities.CreatedFolderInfoDto)JSON.deserialize(data, Dropbox_Entities.CreatedFolderInfoDto.class);
        } else {
            throw new DropboxApiException(res.getBody());
        }
        return result;
    }

    // copies folder or file under specified path
    public static void copyContent(String pathFrom, String pathTo) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Dropbox/files/copy_v2');
        req.setMethod('POST');
    }

    // searches for files and folders
    public static Dropbox_Entities.SearchResultParser search(String searchInput) {

        Dropbox_Entities.SearchResultParser result;

        Dropbox_Entities.SearchDto search = new Dropbox_Entities.SearchDto();
        search.query = searchInput;
        search.include_highlights = false;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Dropbox/files/search_v2');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        String body = JSON.serialize(search);
        req.setBody(body);

        Http http = new Http();
        HTTPResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            String data = res.getBody();
            result = new Dropbox_Entities.SearchResultParser(data);
        } else {
            throw new DropboxApiException(res.getBody());
        }
        return result;
    }

    // downloads a file
    // public static void downLoad() {
    //     HttpRequest req = new HttpRequest();
    //     req.setEndpoint('callout:DropboxContent/files/download');
    //     req.setMethod('POST');
    // }

    // delets folder or file under specified path
    public static Dropbox_Entities.DeletedContentParser deleteContent(String path) {

        Dropbox_Entities.DeletedContentParser result;

        Dropbox_Entities.DeleteContentDto contentToDelete = new Dropbox_Entities.DeleteContentDto();
        contentToDelete.path = path;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Dropbox/files/delete_v2');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        if (dropboxAPISelectUser != null) {
            req.setHeader('Dropbox-API-Select-User', dropboxAPISelectUser);
        }
        
        req.setHeader('Dropbox-API-Path-Root', dropBoxApiPathRoot);

        String body = JSON.serialize(contentToDelete);
        req.setBody(body);

        Http http = new Http();
        HTTPResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            String data = res.getBody();
            result = new Dropbox_Entities.DeletedContentParser(data);
        } else {
            throw new DropboxApiException(res.getBody());
        }
        return result;
    }

    // returns info about single file or folder specified in the 'path' param
    public static Dropbox_Entities.ContentFolderEntryParser getContentMetadata(String path) {

        Dropbox_Entities.ContentFolderEntryParser result;

        Dropbox_Entities.GetContentMetadataDto getFolderData = new Dropbox_Entities.GetContentMetadataDto();
        getFolderData.include_deleted = false;
        getFolderData.include_has_explicit_shared_members = false;
        getFolderData.include_media_info = false;
        getFolderData.path = path;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Dropbox/files/get_metadata');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        if (dropboxAPISelectUser != null) {
            req.setHeader('Dropbox-API-Select-Admin', dropboxAPISelectUser);
        }

        req.setHeader('Dropbox-API-Path-Root', dropBoxApiPathRoot);

        String body = JSON.serialize(getFolderData);
        req.setBody(body);

        Http http = new Http();
        HTTPResponse res = http.send(req);

        if(res.getStatusCode() == 200) {
            result = new Dropbox_Entities.ContentFolderEntryParser(res.getBody());
        } else {
            throw new DropboxApiException(res.getBody());
        }
        return result;
    }

    // returns info about all files and/or folders under folder which path is specified in the 'path' param
    public static List<Dropbox_Entities.ContentFolderEntryParser> getContentOfAFolder(String path) {

        List<Dropbox_Entities.ContentFolderEntryParser> result;

        Dropbox_Entities.GetContentFolderDto getContentFolder = new Dropbox_Entities.GetContentFolderDto();
        getContentFolder.path = path;
        getContentFolder.recursive = false;
        getContentFolder.include_media_info = true;
        getContentFolder.include_deleted = false;
        getContentFolder.include_has_explicit_shared_members = false;
        getContentFolder.include_mounted_folders = false;
        getContentFolder.include_non_downloadable_files = false;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Dropbox/files/list_folder');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        if (dropboxAPISelectUser != null) {
            req.setHeader('Dropbox-API-Select-Admin', dropboxAPISelectUser);
        }
        
        req.setHeader('Dropbox-API-Path-Root', dropBoxApiPathRoot);

        String body = JSON.serialize(getContentFolder);
        req.setBody(body);

        Http http = new Http();
        HTTPResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Dropbox_Entities.ContentFolderParser content = new Dropbox_Entities.ContentFolderParser(res.getBody());
            result = content.entries;
        } else {
            throw new DropboxApiException(res.getBody());
        }
        return result;
    }

    // returns team member id of a user by the Dropbdox user email
    public static String getTeamMemberId(Integer numberOfAccountsToReturn, String userEmail) {

        String teamMemberId;

        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint('callout:Dropbox/team/members/list');
        req.setMethod('POST');

        String body = '{"limit": '+ numberOfAccountsToReturn +', "include_removed": false}';
        req.setBody(body);

        Http http = new Http();
        HTTPResponse res = http.send(req);

        if (res.getStatusCode() == 200) {

            String data = res.getBody();
            Dropbox_Entities.GetTeamMembersDto teamMembers = 
            (Dropbox_Entities.GetTeamMembersDto)JSON.deserialize(data, Dropbox_Entities.GetTeamMembersDto.class);

            for (Dropbox_Entities.TeamMemberDto teamMember : teamMembers.members) {
                if (teamMember.profile.email == userEmail) teamMemberId = teamMember.profile.team_member_id;
                break;
            }
        } else {
            throw new DropboxApiException(res.getBody());
        }
        return teamMemberId;
    }

    // returns root instance id of Dropbox environment
    public static String getRootId() {

        String rootId;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Dropbox/users/get_current_account');
        req.setHeader('Dropbox-API-Select-Admin', dropboxAPISelectUser);
        req.setMethod('POST');

        Http http = new Http();
        HTTPResponse res = http.send(req);

        if(res.getStatusCode() == 200){
            String data = res.getBody();
            Dropbox_Entities.GetAccountInfoDto accountInfo = 
            (Dropbox_Entities.GetAccountInfoDto)JSON.deserialize(data, Dropbox_Entities.GetAccountInfoDto.class);

            rootId = accountInfo.root_info.root_namespace_id;

        } else {
            throw new DropboxApiException(res.getBody());
        }
        return rootId;
    }
}