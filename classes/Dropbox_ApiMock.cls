@isTest
public class Dropbox_ApiMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        String reqBody = req.getBody();
        String endPoint = req.getEndpoint();
        String authorization = req.getHeader('Authorization');
        HTTPResponse res = new HTTPResponse();
        if (endPoint.endsWith(Dropbox_Utils.ACCESS_TOKEN)) {
            Map<String, Object> responseMap = new Map<String, Object>();
            responseMap.put('access_token', '12345');
            responseMap.put('refresh_token', '54321');
            responseMap.put('expires_in', 100000);
            res.setBody(JSON.serialize(responseMap));
            res.setStatusCode(200);
        } else if (endPoint.endsWith(Dropbox_Utils.FILES_UPLOAD)) {
            Dropbox_Entities.UploadedFileDto uploadFile = new Dropbox_Entities.UploadedFileDto();
            uploadFile.name = 'test.txt';
            res.setBody(JSON.serialize(uploadFile));
            res.setStatusCode(200);
        } else if (endPoint.endsWith(Dropbox_Utils.CREATE_FOLDER)) {
            Dropbox_Entities.CreatedFolderInfoDto createFolder = new Dropbox_Entities.CreatedFolderInfoDto();
            Dropbox_Entities.CreatedFolderMetadataDto metadata = new Dropbox_Entities.CreatedFolderMetadataDto();
            metadata.name = 'test';
            createFolder.metadata = metadata;
            res.setBody(JSON.serialize(createFolder));
            res.setStatusCode(200);
        } else if (endPoint.endsWith(Dropbox_Utils.COPY)) {
            res.setStatusCode(200);
        } else if (endPoint.endsWith(Dropbox_Utils.COPY_BATCH)) {
            Map<String, Object> resultMap = new Map<String, Object>();
            resultMap.put('async_job_id', '12345');
            res.setBody(JSON.serialize(resultMap));
            res.setStatusCode(200);
        } else if (endPoint.endsWith(Dropbox_Utils.COPY_BATCH_CHECK)) {
            Map<String, Object> resultMap = new Map<String, Object>();
            resultMap.put('.tag', 'complete');
            res.setBody(JSON.serialize(resultMap));
            res.setStatusCode(200);
        } else if (endPoint.endsWith(Dropbox_Utils.SEARCH)) {
            String testData = '{"cursor": "12345", "has_more": false, "matches": [' +
                          '{"metadata": { "metadata" : {".tag": "file", "id": "123", "name": "file1.txt", "path_display": "/path/to/file1.txt", "path_lower": "/path/to/file1.txt", "client_modified": "2023-11-03T10:00:00Z", "is_downloadable": true, "size": 1024}}},' +
                          '{"metadata": { "metadata" : {".tag": "file", "id": "456", "name": "file2.txt", "path_display": "/path/to/file2.txt", "path_lower": "/path/to/file2.txt", "client_modified": "2023-11-03T11:00:00Z", "is_downloadable": false, "size": 2048}}}' +
                          ']}';
            res.setBody(testData);
            res.setStatusCode(200);
        } else if (endPoint.endsWith(Dropbox_Utils.DOWNLOAD_FILE)) {
            res.setBodyAsBlob(Blob.valueOf('Test'));
            res.setStatusCode(200);
        } else if (endPoint.endsWith(Dropbox_Utils.DOWNLOAD_FILE_ZIP)) {
            res.setBodyAsBlob(Blob.valueOf('Test.zip'));
            res.setStatusCode(200);
        } else if (endPoint.endsWith(Dropbox_Utils.DOWNLOAD_FILE_ZIP)) {
            res.setStatusCode(200);
        } else if (endPoint.endsWith(Dropbox_Utils.DELETE_FILES)) {
            res.setStatusCode(200);
        } else if (endPoint.endsWith(Dropbox_Utils.DELETE_FILES_BATCH)) {
            Dropbox_Entities.AsyncBatchJobIdDto asyncJobId = new Dropbox_Entities.AsyncBatchJobIdDto();
            asyncJobId.async_job_id = '12345';
            res.setBody(JSON.serialize(asyncJobId));
            res.setStatusCode(200);
        } else if (endPoint.endsWith(Dropbox_Utils.DELETE_FILES_BATCH_CHECK)) {
            Map<String, Object> deleteBatchStatusMap = new Map<String, Object>();
            deleteBatchStatusMap.put('.tag', 'complete');
            res.setBody(JSON.serialize(deleteBatchStatusMap));
            res.setStatusCode(200);
        } else if (endPoint.endsWith(Dropbox_Utils.CONTENT_METADATA)) {
            String testData = '{".tag": "file", "name": "file1.txt", "path_lower": "/path/to/file1.txt", "path_display": "/path/to/file1.txt", "client_modified": "2023-11-03T10:00:00Z", "size": 1024}';
            res.setBody(testData);
            res.setStatusCode(200);
        } else if (endPoint.endsWith(Dropbox_Utils.GET_CONTENT_OF_A_FOLDER)) {
            String testData = '{"entries": [' +
            '{".tag": "file", "name": "file1.txt", "path_lower": "/path/to/file1.txt", "path_display": "/path/to/file1.txt", "client_modified": "2023-11-03T10:00:00Z", "size": 1024},' +
            '{".tag": "folder", "name": "folder1", "path_lower": "/path/to/folder1", "path_display": "/path/to/folder1"},' +
            '{".tag": "file", "name": "file2.txt", "path_lower": "/path/to/file2.txt", "path_display": "/path/to/file2.txt", "client_modified": "2023-11-03T11:00:00Z", "size": 2048}' +
            '], "cursor": "12345", "has_more": true}';
            res.setBody(testData);
            res.setStatusCode(200);
        } else if (endPoint.endsWith(Dropbox_Utils.GET_NEXT_CHUNK_OF_CONTENT)) {
            String testData = '{"entries": [' +
            '{".tag": "file", "name": "file1.txt", "path_lower": "/path/to/file1.txt", "path_display": "/path/to/file1.txt", "client_modified": "2023-11-03T10:00:00Z", "size": 1024},' +
            '{".tag": "folder", "name": "folder1", "path_lower": "/path/to/folder1", "path_display": "/path/to/folder1"},' +
            '{".tag": "file", "name": "file2.txt", "path_lower": "/path/to/file2.txt", "path_display": "/path/to/file2.txt", "client_modified": "2023-11-03T11:00:00Z", "size": 2048}' +
            '], "cursor": "12345", "has_more": false}';
            res.setBody(testData);
            res.setStatusCode(200);
        } else if (endPoint.endsWith(Dropbox_Utils.GET_CURRENT_ACCOUNT)) {
            Dropbox_Entities.GetAccountInfoDto accountInfo = new Dropbox_Entities.GetAccountInfoDto();
            Dropbox_Entities.AccountNameInfo nameInfo = new Dropbox_Entities.AccountNameInfo();
            Dropbox_Entities.RootInfoDto rootInfo = new Dropbox_Entities.RootInfoDto();
            rootInfo.root_namespace_id = '12345';
            nameInfo.display_name = 'test';
            accountInfo.email = 'test@gmail.com';
            accountInfo.name = nameInfo;
            accountInfo.root_info = rootInfo;
            res.setBody(JSON.serialize(accountInfo));
            res.setStatusCode(200);
        } else if (endPoint.endsWith(Dropbox_Utils.MOVE_FILES)) {
            res.setStatusCode(200);
        } else if (endPoint.endsWith(Dropbox_Utils.MOVE_FILES_BATCH)) {
            Map<String, Object> resultMap = new Map<String, Object>();
            resultMap.put('async_job_id', '12345');
            res.setBody(JSON.serialize(resultMap));
            res.setStatusCode(200);
        } else if (endPoint.endsWith(Dropbox_Utils.MOVE_FILES_BATCH_CHECK)) {
            Map<String, Object> resultMap = new Map<String, Object>();
            resultMap.put('.tag', 'complete');
            res.setBody(JSON.serialize(resultMap));
            res.setStatusCode(200);
        } else if (endPoint.endsWith(Dropbox_Utils.GET_FILE_PREVIEW_LINK)) {
            Map<String, Object> resultMap = new Map<String, Object>();
            resultMap.put('link', 'test link');
            res.setBody(JSON.serialize(resultMap));
            res.setStatusCode(200);
        } else if (endPoint.endsWith(Dropbox_Utils.GET_THUMBNAIL)) {
            res.setBodyAsBlob(Blob.valueOf('thumbnail'));
            res.setStatusCode(200);
        } else if (endPoint.endsWith(Dropbox_Utils.GET_THUMBNAIL_BATCH)) {
            Dropbox_Entities.GetThumbnailButchEntries entries = new Dropbox_Entities.GetThumbnailButchEntries();
            List<Dropbox_Entities.GetThumbnailButchEntry> entriesList = new List<Dropbox_Entities.GetThumbnailButchEntry>();
            Dropbox_Entities.GetThumbnailButchEntry entry = new Dropbox_Entities.GetThumbnailButchEntry();
            Dropbox_Entities.GetThumbnailButchEntryMetadata metadata = new Dropbox_Entities.GetThumbnailButchEntryMetadata();
            metadata.name = 'test.txt';
            entry.metadata = metadata;
            entry.thumbnail = 'thumbnail';
            entriesList.add(entry);
            entries.entries = entriesList;
            res.setBody(JSON.serialize(entries));
            res.setStatusCode(200);
        }
        return res;
    }
}