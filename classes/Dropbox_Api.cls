public with sharing class Dropbox_Api {
    
    public class DropboxApiException extends Exception {}

    // ----------------------------------------------------------------------------------------

    // To get dropboxAPISelectUser you can use getTeamMember() method 
    // You need dropboxAPISelectUser only if you are conecting to Paid Buisness plan

    // Dropbox_Entities.TeamMemberDto teamMemberInfo = Dropbox_Api.getTeamMember(Your target Dropbox user email);
    // dropboxAPISelectUser = teamMemberInfo.profile.team_member_id;

    public static String dropboxAPISelectUser; // 'Your API Select user from Dropbox'

    // ----------------------------------------------------------------------------------------

    // To get pathRootId you can use getTeamMember() method for Paid Accounts
    // pathRootId = teamMemberInfo.profile.root_folder_id

    // OR

    // getCurrentAccountInfo() for free single user accounts
    // Dropbox_Entities.GetAccountInfoDto accountInfo = Dropbox_Api.getCurrentAccountInfo(null / or access token from Dropbox_Api.getAccessToken());
    // pathRootId = accountInfo.root_info.root_namespace_id

    public static String pathRootId; // Your Path Rood Id from Dropbox;

    // ----------------------------------------------------------------------------------------

    private static final String dropBoxApiPathRoot = '{".tag": "root", "root": "' + pathRootId +'"}';

    // Method to get access token direclty (if using named credentials + auth provider not possible / not working)
    // More info here https://developers.dropbox.com/oauth-guide
    public static Dropbox_Entities.AccessTokenDto getAccessToken(String clientId, String clientSecret, String verificationCode, String refreshToken) {

        Dropbox_Entities.AccessTokenDto result;

        String requestBody;

        if (verificationCode != null) {
            requestBody = 'client_id=' + clientId + '&client_secret=' + clientSecret + '&code=' + verificationCode + '&grant_type=authorization_code'; 
        } else {
            requestBody = 'client_id=' + clientId + '&client_secret=' + clientSecret + '&refresh_token=' + refreshToken + '&grant_type=refresh_token'; 
        }

        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/x-www-form-urlencoded');

        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Base_URL' + Dropbox_Utils.ACCESS_TOKEN, 
            Dropbox_Utils.POST, 
            headers, 
            requestBody, 
            null
        );

        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            result = new Dropbox_Entities.AccessTokenDto();
            result.accessToken = (String) responseMap.get('access_token');
            result.refreshToken = (String) responseMap.get('refresh_token');
            result.expiresIn = (Integer) responseMap.get('expires_in');
            result.accountId = (String) responseMap.get('account_id');
            result.teamId = (String) responseMap.get('team_id');
            result.scope = (String) responseMap.get('scope');
        } else {
            throw new DropboxApiException('Error getting access token: ' + res.getBody());
        }
        return result;
    }

    // Uploades file under specified path
    public static Dropbox_Entities.UploadedFileDto uploadFile(Id contentVersionId, String path, String fileName, String base64, String accessToken) {

        Dropbox_Entities.UploadedFileDto result;

        ContentVersion contentVersion;

        if (contentVersionId != null) {
            contentVersion = [
                SELECT Id, PathOnClient, VersionData 
                FROM ContentVersion 
                WHERE Id = :contentVersionId
                WITH USER_MODE
            ];
        }
        
        Dropbox_Entities.UploadFileDto uploadFileData = new Dropbox_Entities.UploadFileDto();
        uploadFileData.path = contentVersion == null ? path + fileName : path + contentVersion.PathOnClient;
        uploadFileData.mode = 'add';
        uploadFileData.autorename = true;
        uploadFileData.mute = false;
        uploadFileData.strict_conflict = true;

        String dropboxAPIArg = JSON.serialize(uploadFileData);

        Map<String, String> headers = createHeaders('application/octet-stream', accessToken, dropboxAPIArg);

        Blob requestBody = contentVersion != null ? contentVersion.VersionData : EncodingUtil.base64Decode(base64);

        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Content_URL' + Dropbox_Utils.FILES_UPLOAD, 
            Dropbox_Utils.POST, 
            headers, 
            null, 
            requestBody
        );

        if(res.getStatusCode() == 200){
            String data = res.getBody();
            result = (Dropbox_Entities.UploadedFileDto) JSON.deserialize(data, Dropbox_Entities.UploadedFileDto.class);
        } else {
            throw new DropboxApiException(res.getBody());
        }
        return result;
    }

    // Creates folder under specified path
    public static Dropbox_Entities.CreatedFolderInfoDto createFolder(String path, String accessToken) {
        
        Dropbox_Entities.CreatedFolderInfoDto result;

        Dropbox_Entities.NewFolderToCreateDto newFolder = new Dropbox_Entities.NewFolderToCreateDto();
        newFolder.path = path;
        newFolder.autorename = false;

        String requestBody = JSON.serialize(newFolder);

        Map<String, String> headers = createHeaders('application/json', accessToken, null);

        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Base_URL_V2' + Dropbox_Utils.CREATE_FOLDER, 
            Dropbox_Utils.POST, 
            headers, 
            requestBody, 
            null
        );
        
        if(res.getStatusCode() == 200) {
            String data = res.getBody();
            result = (Dropbox_Entities.CreatedFolderInfoDto)JSON.deserialize(data, Dropbox_Entities.CreatedFolderInfoDto.class);
        } else {
            throw new DropboxApiException(res.getBody());
        }
        return result;
    }

    // Copies folder or file under specified path
    public static void copyContent(String pathFrom, String pathTo, String accessToken) {

        Map<String, String> headers = createHeaders('application/json', accessToken, null);

        Dropbox_Entities.CopyFileEntry fileEntry = new Dropbox_Entities.CopyFileEntry();
        fileEntry.from_path = pathFrom;
        fileEntry.to_path = pathTo;
        fileEntry.autorename = true;

        String requestBody = JSON.serialize(fileEntry);
        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Base_URL_V2' + Dropbox_Utils.COPY, 
            Dropbox_Utils.POST, 
            headers, 
            requestBody, 
            null
        );

        if (res.getStatusCode() != 200) {
            throw new DropboxApiException('Error copying file: ' + res.getBody());
        }
    }

    // Copies several files under specified paths
    public static String copyContentBatch(Map<String, String> paths, String accessToken) {

        Map<String, String> headers = createHeaders('application/json', accessToken, null);

        Dropbox_Entities.CopyBatchFileEntries filesEntries = new Dropbox_Entities.CopyBatchFileEntries();
        List<Dropbox_Entities.CopyBatchFileEntry> filesEntriesList = new List<Dropbox_Entities.CopyBatchFileEntry>();

        for (String sourcePath : paths.keySet()) {
            Dropbox_Entities.CopyBatchFileEntry fileEntry = new Dropbox_Entities.CopyBatchFileEntry();
            fileEntry.from_path = sourcePath;
            fileEntry.to_path = paths.get(sourcePath);
            filesEntriesList.add(fileEntry);
        }

        filesEntries.entries = filesEntriesList;
        filesEntries.autorename = true;

       String requestBody = JSON.serialize(filesEntries);

        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Base_URL_V2' + Dropbox_Utils.COPY_BATCH, 
            Dropbox_Utils.POST, 
            headers, 
            requestBody, 
            null
        );

        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) responseMap.get('async_job_id');
        } else {
            throw new DropboxApiException('Error copying files: ' + res.getBody());
        }
    }

    // Cheks copying progress
    public static String checkCopyContentBatch(String asyncJobId, String accessToken) {

        Map<String, String> headers = createHeaders('application/json', accessToken, null);

        Map<String, String> requestBodyMap = new Map<String, String>();
        requestBodyMap.put('async_job_id', asyncJobId);

        String requestBody = JSON.serialize(requestBodyMap);

        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Base_URL_V2' + Dropbox_Utils.COPY_BATCH_CHECK, 
            Dropbox_Utils.POST, 
            headers, 
            requestBody, 
            null
        );

        if (res.getStatusCode() == 200) {
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) resultMap.get('.tag');
        } else {
            throw new DropboxApiException('Error in getting copy status: ' + res.getBody());
        }
    }

    // Searches for files and folders
    public static Dropbox_Entities.SearchResultParser searchContent(String searchInput, String accessToken, String searchPath) {

        Dropbox_Entities.SearchResultParser result;

        Dropbox_Entities.SearchDto searchBody = new Dropbox_Entities.SearchDto();
        searchBody.query = searchInput;
        searchBody.include_highlights = false;

        Dropbox_Entities.SearchOptions options = new Dropbox_Entities.SearchOptions();
        options.max_results = 25;
        options.filename_only = true;

        if (searchPath != null) {
            options.path = searchPath;
        } else {
            options.path = '';
        }
        
        searchBody.options = options;

        Map<String, String> headers = createHeaders('application/json', accessToken, null);

        String requestBody = JSON.serialize(searchBody);

        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Base_URL_V2' + Dropbox_Utils.SEARCH, 
            Dropbox_Utils.POST, 
            headers, 
            requestBody, 
            null
        );

        if (res.getStatusCode() == 200) {
            String data = res.getBody();
            result = new Dropbox_Entities.SearchResultParser(data);
        } else {
            throw new DropboxApiException('Error in search: ' + res.getBody());
        }
        return result;
    }

    // Search next chunk of content by cursor
    public static Dropbox_Entities.SearchResultParser searchNextContent(String accessToken, String cursor) {

        Dropbox_Entities.SearchResultParser result;

        String requestBody = '{ "cursor": "' + cursor + '" }';

        Map<String, String> headers = createHeaders('application/json', accessToken, null);

        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Base_URL_V2' + 
            Dropbox_Utils.SEARCH_CONTINUE, 
            Dropbox_Utils.POST, 
            headers, 
            requestBody, 
            null
        );

        if (res.getStatusCode() == 200) {
            String data = res.getBody();
            result = new Dropbox_Entities.SearchResultParser(data);
        } else {
            throw new DropboxApiException('Error in search: ' + res.getBody());
        }
        return result;
    }

    // Downloads a file
    public static String downLoadFile(String path, String accessToken) { 

        Dropbox_Entities.DownLoadFileDto file = new Dropbox_Entities.DownLoadFileDto();
        file.path = path;

        Map<String, String> headers = createHeaders('application/json', accessToken, null);

        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Content_URL' + Dropbox_Utils.DOWNLOAD_FILE, 
            Dropbox_Utils.POST, 
            headers,
            null, 
            null
        );

        if (res.getStatusCode() == 200) {
            return EncodingUtil.base64Encode(res.getBodyAsBlob());
        } else {
            return null;
        }
    }

    // Downloads file in zip format
    public static String downLoadFileZip(String path, String accessToken) {

        Dropbox_Entities.DownLoadFileDto file = new Dropbox_Entities.DownLoadFileDto();
        file.path = path;

         Map<String, String> headers = createHeaders('application/json', accessToken, null);

        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Content_URL' + Dropbox_Utils.DOWNLOAD_FILE_ZIP, 
            Dropbox_Utils.POST, 
            headers,
            null, 
            null
        );

        if (res.getStatusCode() == 200) { 
            return EncodingUtil.base64Encode(res.getBodyAsBlob());
        } else {
            return null;
        }
    }

    // Delets single folder or file under specified path
    public static void deleteContent(String path, String accessToken) {

        Dropbox_Entities.DeleteContentDto contentToDelete = new Dropbox_Entities.DeleteContentDto();
        contentToDelete.path = path;

        Map<String, String> headers = createHeaders('application/json', accessToken, null);

        String requestBody = JSON.serialize(contentToDelete);

        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Base_URL_V2' + Dropbox_Utils.DELETE_FILES, 
            Dropbox_Utils.POST, 
            headers, 
            requestBody, 
            null
        );

        if (res.getStatusCode() != 200) {
            throw new DropboxApiException(res.getBody());
        } 
    }

    // Delets several folders and/or file under specified paths
    public static String deleteContentBatch(Dropbox_Entities.DeletedContentBatchDto entries, String accessToken) {

        String result;

        Map<String, String> headers = createHeaders('application/json', accessToken, null);

        String requestBody = JSON.serialize(entries);

        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Base_URL_V2' + Dropbox_Utils.DELETE_FILES_BATCH, 
            Dropbox_Utils.POST, 
            headers, 
            requestBody, 
            null
        );

        if (res.getStatusCode() == 200) {
            String data = res.getBody();
            Dropbox_Entities.AsyncBatchJobIdDto jobId = 
            (Dropbox_Entities.AsyncBatchJobIdDto)JSON.deserialize(data, Dropbox_Entities.AsyncBatchJobIdDto.class);
            result = jobId.async_job_id;
        } else {
            throw new DropboxApiException('Error deleting files and folders: ' + res.getBody());
        }
        return result;
    }

    // Check delete status
    public static String checkDeleteBatch(String jobId, String accessToken) {

        String result;
        
        Map<String, Object> requestBody = new Map<String, Object>{
            'async_job_id' => jobId
        };

        Map<String, String> headers = createHeaders('application/json', accessToken, null);

        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Base_URL_V2' + Dropbox_Utils.DELETE_FILES_BATCH_CHECK, 
            Dropbox_Utils.POST, 
            headers, 
            JSON.serialize(requestBody), 
            null
        );

        if (res.getStatusCode() == 200) {
            Map<String, Object> deleteBatchStatusMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            result = (String) deleteBatchStatusMap.get('.tag');
        } else {
            throw new DropboxApiException('Error checking delete status: ' + res.getBody());
        }
        return result;
    }
    
    // Returns info about single file or folder specified in the 'path' param
    public static Dropbox_Entities.ContentFolderEntryParser getContentMetadata(String path, String accessToken) {

        Dropbox_Entities.ContentFolderEntryParser result;

        Dropbox_Entities.GetContentMetadataDto getFolderData = new Dropbox_Entities.GetContentMetadataDto();
        getFolderData.include_deleted = false;
        getFolderData.include_has_explicit_shared_members = false;
        getFolderData.include_media_info = false;
        getFolderData.path = path;

        String requestBody = JSON.serialize(getFolderData);

        Map<String, String> headers = createHeaders('application/json', accessToken, null);

        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Base_URL_V2' + Dropbox_Utils.CONTENT_METADATA, 
            Dropbox_Utils.POST, 
            headers, 
            requestBody, 
            null
        );

        if(res.getStatusCode() == 200) {
            result = new Dropbox_Entities.ContentFolderEntryParser(res.getBody());
        } else {
            throw new DropboxApiException(res.getBody());
        }
        return result;
    }

    // Returns info about ALL files and/or folders under folder which path is specified in the 'path' param
    public static Dropbox_Entities.ContentFolderParser getContentOfAFolder(String path, String accessToken) {

        Dropbox_Entities.ContentFolderParser result;

        Dropbox_Entities.GetContentFolderDto getContentFolder = new Dropbox_Entities.GetContentFolderDto();
        getContentFolder.path = path;
        getContentFolder.recursive = false;
        getContentFolder.include_media_info = true;
        getContentFolder.include_deleted = false;
        getContentFolder.include_has_explicit_shared_members = false;
        getContentFolder.include_mounted_folders = false;
        getContentFolder.include_non_downloadable_files = true;

        Map<String, String> headers = createHeaders('application/json', accessToken, null);

        String requestBody = JSON.serialize(getContentFolder);

        // Using map here with 'limit' field because cannot create 'limit' class field because 'limit' is reserved key word
        Map<String, Integer> limitMap = new Map<String, Integer>();
        limitMap.put('limit', 24);
        String mapStr = JSON.serialize(limitMap);

        requestBody = requestBody.replace('}', ',');
        mapStr = mapStr.replace('{', ' ');

        requestBody += mapStr;

        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Base_URL_V2' + Dropbox_Utils.GET_CONTENT_OF_A_FOLDER, 
            Dropbox_Utils.POST, 
            headers, 
            requestBody, 
            null
        );

        if (res.getStatusCode() == 200) {
            Dropbox_Entities.ContentFolderParser content = new Dropbox_Entities.ContentFolderParser(res.getBody());
            result = content;
        } else {
            throw new DropboxApiException(res.getBody());
        }
        return result;
    }

    // Returns info about all files and/or folders under folder according to cursor
    public static Dropbox_Entities.ContentFolderParser getNextContentOfAFolder(String accessToken, String cursor) {

        Dropbox_Entities.ContentFolderParser result;

        Map<String, String> cursorMap = new Map<String, String>();
        cursorMap.put('cursor', cursor);

        Map<String, String> headers = createHeaders('application/json', accessToken, null);

        String requestBody = JSON.serialize(cursorMap);

        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Base_URL_V2' + Dropbox_Utils.GET_NEXT_CHUNK_OF_CONTENT, 
            Dropbox_Utils.POST, 
            headers, 
            requestBody, 
            null
        );

        if (res.getStatusCode() == 200) {
            Dropbox_Entities.ContentFolderParser content = new Dropbox_Entities.ContentFolderParser(res.getBody());
            result = content;
        } else {
            throw new DropboxApiException(res.getBody());
        }
        return result;
    }

    // Returns team member id of a user by the Dropbdox user email
    public static Dropbox_Entities.TeamMemberDto getTeamMember(String userEmail, String accessToken) {

        Dropbox_Entities.TeamMemberDto result;

        Map<String, String> headers = createHeaders('application/json', accessToken, null);

        String requestBody = '{"limit": ' + 100 + ', "include_removed": false}';

        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Base_URL_V2' + Dropbox_Utils.TEAM_MEMBERS, 
            Dropbox_Utils.POST, 
            headers, 
            requestBody, 
            null
        );

        if (res.getStatusCode() == 200) {

            String data = res.getBody();
            Dropbox_Entities.GetTeamMembersDto teamMembers = 
            (Dropbox_Entities.GetTeamMembersDto)JSON.deserialize(data, Dropbox_Entities.GetTeamMembersDto.class);

            for (Dropbox_Entities.TeamMemberDto teamMember : teamMembers.members) {
                if (teamMember.profile.email == userEmail) {
                    result = teamMember;
                    break;
                } 
            }

        } else {
            throw new DropboxApiException(res.getBody());
        }
        return result;
    }

    // Returns account info of Dropbox environment
    public static Dropbox_Entities.GetAccountInfoDto getCurrentAccountInfo(String accessToken) {

        Dropbox_Entities.GetAccountInfoDto result;

        Map<String, String> headers = new Map<String, String>();
        if (accessToken != null) {
            headers.put('Authorization', 'Bearer ' + accessToken);
        }
        
        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Base_URL_V2' + Dropbox_Utils.GET_CURRENT_ACCOUNT, 
            Dropbox_Utils.POST, 
            headers, 
            null, 
            null
        );

        if(res.getStatusCode() == 200){
            String data = res.getBody();
            result = (Dropbox_Entities.GetAccountInfoDto)JSON.deserialize(data, Dropbox_Entities.GetAccountInfoDto.class);
        } else {
            if (!res.getBody().contains(Dropbox_Utils.TEAM_ACCESS_ERROR)) {
                throw new DropboxApiException(res.getBody());
            }
        }
        return result;
    }

    // Renaming content under specified path
    public static void renameContent(String accessToken, String oldContentPath, String newContentPath) {

        Dropbox_Entities.MoveFileEntry renameFileEntry = new Dropbox_Entities.MoveFileEntry();
        renameFileEntry.from_path = oldContentPath;
        renameFileEntry.to_path = newContentPath;
        renameFileEntry.autorename = true;
        renameFileEntry.allow_ownership_transfer = false;

        String requestBody = JSON.serialize(renameFileEntry);

        Map<String, String> headers = createHeaders('application/json', accessToken, null);

        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Base_URL_V2' + Dropbox_Utils.MOVE_FILES, 
            Dropbox_Utils.POST, 
            headers, 
            requestBody, 
            null
        );

        if (res.getStatusCode() != 200) {
            throw new DropboxApiException('Erorr renaming file: ' + res.getBody());
        } 
    }

    // Moving files under specified paths
    public static String moveContentBatch(Map<String, String> paths, String accessToken) {

        Dropbox_Entities.MoveFileEntriesBatch fileEntries = new Dropbox_Entities.MoveFileEntriesBatch();
        List<Dropbox_Entities.MoveFileEntryBatch> fileEntriesList = new List<Dropbox_Entities.MoveFileEntryBatch>();

        Map<String, String> headers = createHeaders('application/json', accessToken, null);

        for (String pathFrom : paths.keySet()) {
            Dropbox_Entities.MoveFileEntryBatch fileEntry = new Dropbox_Entities.MoveFileEntryBatch();
            fileEntry.from_path = pathFrom;
            fileEntry.to_path = paths.get(pathFrom);
            fileEntriesList.add(fileEntry);
        }

        fileEntries.entries = fileEntriesList;
        fileEntries.allow_ownership_transfer = false;
        fileEntries.autorename = true;

        String requestBody = JSON.serialize(fileEntries);

        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Base_URL_V2' + Dropbox_Utils.MOVE_FILES_BATCH, 
            Dropbox_Utils.POST, 
            headers, 
            requestBody, 
            null
        );

        if (res.getStatusCode() == 200) {
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) resultMap.get('async_job_id');
        } else {
            throw new DropboxApiException('Erorr moving files: ' + res.getBody());
        }
    }

    // Checks moving files progress
    public static String checkMoveContentBatch(String asyncJobId, String accessToken) {

        Map<String, String> headers = createHeaders('application/json', accessToken, null);

        Map<String, String> requestBodyMap = new Map<String, String>();
        requestBodyMap.put('async_job_id', asyncJobId);
        String requestBody = JSON.serialize(requestBodyMap);

        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Base_URL_V2' + Dropbox_Utils.MOVE_FILES_BATCH_CHECK, 
            Dropbox_Utils.POST, 
            headers, 
            requestBody, 
            null
        );

        if (res.getStatusCode() == 200) {
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) resultMap.get('.tag');
        } else {
            throw new DropboxApiException('Error getting batch status: ' + res.getBody());
        }
    }
    
    // Get preview link for a img file (supports png, jpg, jpeg file formats)
    public static String getTemporaryLink(String filePath, String accessToken) {

        Map<String, String> headers = createHeaders('application/json', accessToken, null);

        String requestBody = '{"path" : "' + filePath + '"}';

        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Base_URL_V2' + Dropbox_Utils.GET_FILE_PREVIEW_LINK, 
            Dropbox_Utils.POST, 
            headers, 
            requestBody, 
            null
        );

        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            String temporaryLink = (String) responseMap.get('link');
            return temporaryLink;
        } else {
            throw new DropboxApiException('Error getting preview link: ' + res.getBody());
        }
    }

    // Get single thumbnail image for file
    public static String getThumbnail(String path, String accessToken) {
        Map<String, String> headers = createHeaders('application/json', accessToken, '{"path":"/' + path + '"}');
        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest('callout:Dropbox_Content_URL' + Dropbox_Utils.GET_THUMBNAIL, Dropbox_Utils.GET, headers, null, null);
        if (res.getStatusCode() == 200) {
            return EncodingUtil.base64Encode(res.getBodyAsBlob());
        } else {
            throw new DropboxApiException('Error getting thumbnail: ' + res.getBody());
        }
    }

    // Get thumbnail images for files up to 25 images in a batch
    public static Dropbox_Entities.GetThumbnailButchEntries getThumbnailBatch(List<Dropbox_Entities.GetThumbnailButchEntriesDto> filePaths, String accessToken) {

        // Create a JSON payload with the list of file IDs
        Map<String, List<Dropbox_Entities.GetThumbnailButchEntriesDto>> requestBodyMap = new Map<String, List<Dropbox_Entities.GetThumbnailButchEntriesDto>>();
        requestBodyMap.put('entries', filePaths);
        String requestBody = JSON.serialize(requestBodyMap);

        Map<String, String> headers = createHeaders('application/json', accessToken, null);

        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Content_URL' + Dropbox_Utils.GET_THUMBNAIL_BATCH, 
            Dropbox_Utils.POST,
            headers, 
            requestBody, 
            null
        );

        if (res.getStatusCode() == 200) {
            Dropbox_Entities.GetThumbnailButchEntries entries = 
            (Dropbox_Entities.GetThumbnailButchEntries)JSON.deserialize(res.getBody(), Dropbox_Entities.GetThumbnailButchEntries.class);
            return entries;
        } else {
            throw new DropboxApiException('Error getting thumbnail batch: ' + res.getBody());
        }
    }

    // Get preview for not img files (supports excel, csv, doxc, doc, and other text formats)
    public static String getFilePreview(String path, String accessToken) {

        Map<String, String> apiArg = new Map<String, String>();
        apiArg.put('path', path);

        Map<String, String> headers = createHeaders('application/octet-stream', accessToken, JSON.serialize(apiArg));

        HTTPResponse res = Dropbox_HttpRequestGenerator.generateRequest(
            'callout:Dropbox_Content_URL' + Dropbox_Utils.FILE_PREVIEW, 
            Dropbox_Utils.POST, 
            headers, 
            null, 
            null
        );
        
        if (res.getStatusCode() == 200) {
            return EncodingUtil.base64Encode(res.getBodyAsBlob());
        } else {
            throw new DropboxApiException('Error getting file preview: ' + res.getBody());
        }
    }

    private static Map<String,String> createHeaders(String contentType, String accessToken, String apiArg) {
        Map<String, String> headers = new Map<String, String>();
        headers.put('Dropbox-API-Path-Root', dropBoxApiPathRoot);
        if (contentType != null) {
            headers.put('Content-Type', contentType);
        }
        if (accessToken != null) {
            headers.put('Authorization', 'Bearer ' + accessToken);
        }
        if (dropboxAPISelectUser != null) {
            headers.put('Dropbox-API-Select-User', dropboxAPISelectUser);
        }
        if (apiArg != null) {
            headers.put('Dropbox-API-Arg', apiArg);
        }
        return headers;
    }
}
