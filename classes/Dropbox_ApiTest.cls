@isTest
public class Dropbox_ApiTest {

    @isTest
    static void getAccessTokenTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Dropbox_ApiMock());
        Dropbox_Entities.AccessTokenDto accessToken = Dropbox_Api.getAccessToken('client_id', 'client_secret', 'verification_code', null);
        Assert.areEqual('12345', accessToken.accessToken);
        Assert.areEqual('54321', accessToken.refreshToken);
        Test.stopTest();
    }

    @isTest
    static void uploadFileTest() {
        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Test file content'),
            PathOnClient = 'testFile.txt'
        );
        insert testContentVersion;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Dropbox_ApiMock());

        Dropbox_Entities.UploadedFileDto uploadedFile = Dropbox_Api.uploadFile(testContentVersion.Id, '/test/', 'uploadedFile.txt', null, 'access_token');

        System.assertEquals('test.txt', uploadedFile.name);

        Test.stopTest();
    }

    @isTest
    static void createFolderTest() {
        // Set up mock HTTP response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Dropbox_ApiMock());

        // Call the createFolder method
        Dropbox_Entities.CreatedFolderInfoDto createdFolderInfo = Dropbox_Api.createFolder('/testFolder', 'access_token');

        // Verify the created folder details
        System.assertEquals('test', createdFolderInfo.metadata.name);

        Test.stopTest();
    }

    @isTest 
    static void copyContentTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Dropbox_ApiMock());
        Dropbox_Api.copyContent('path/from', 'path/to', 'access_token');
        Test.stopTest();
    }

    @isTest 
    static void copyContentBatchTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Dropbox_ApiMock());
        Map<String, String> paths = new Map<String, String>();
        paths.put('path/from', 'path/to');
        String result = Dropbox_Api.copyContentBatch(paths, 'access_token');
        Assert.areEqual('12345', result);
        Test.stopTest();
    }

    @isTest
    static void checkCopyContentBatchTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Dropbox_ApiMock());
        String result = Dropbox_Api.checkCopyContentBatch('12345', 'access_token');
        Assert.areEqual('complete', result);
        Test.stopTest();
    }

    @isTest 
    static void searchContentTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Dropbox_ApiMock());
        Dropbox_Entities.SearchResultParser result = Dropbox_Api.searchContent('test', 'access_token', 'test/path');
        Assert.areEqual(false, result.has_more);
        Assert.areEqual(2, result.matches.size());
        Test.stopTest();
    }

    @isTest 
    static void downLoadFileTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Dropbox_ApiMock());
        String result = Dropbox_Api.downLoadFile('test/path', 'access_token');
        Assert.areNotEqual(null, result);
        Test.stopTest();
    }

    @isTest 
    static void downLoadFileZipTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Dropbox_ApiMock());
        String result = Dropbox_Api.downLoadFileZip('test/path', 'access_token');
        Assert.areNotEqual(null, result);
        Test.stopTest();
    }

    @isTest 
    static void deleteContentTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Dropbox_ApiMock());
        Dropbox_Api.deleteContent('test/path', 'access_token');
        Test.stopTest();
    }

    @isTest 
    static void deleteContentBatchTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Dropbox_ApiMock());
        Dropbox_Entities.DeletedContentBatchDto entries  = new Dropbox_Entities.DeletedContentBatchDto();
        Dropbox_Entities.DeletedContentPathDto path = new Dropbox_Entities.DeletedContentPathDto();
        path.path = 'test/path';
        List<Dropbox_Entities.DeletedContentPathDto> paths = new List<Dropbox_Entities.DeletedContentPathDto>();
        paths.add(path);
        entries.entries = paths;
        String result = Dropbox_Api.deleteContentBatch(entries, 'access_token');
        Assert.areEqual('12345', result);
        Test.stopTest();
    }

    @isTest 
    static void checkDeleteBatchTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Dropbox_ApiMock());
        String result = Dropbox_Api.checkDeleteBatch('12345', 'access_token');
        Assert.areEqual('complete', result);
        Test.stopTest();
    }

    @isTest 
    static void getContentMetadataTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Dropbox_ApiMock());
        Dropbox_Entities.ContentFolderEntryParser result = Dropbox_Api.getContentMetadata('path/test', 'access_token');
        Assert.areEqual('file1.txt', result.name);
        Test.stopTest();
    }

    @isTest 
    static void getContentOfAFolderTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Dropbox_ApiMock());
        Dropbox_Entities.ContentFolderParser result = Dropbox_Api.getContentOfAFolder('path/test', 'access_token');
        Assert.areEqual(true, result.has_more);
        Assert.areEqual(3, result.entries.size());
        Test.stopTest();
    }

    @isTest 
    static void getNextContentOfAFolderTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Dropbox_ApiMock());
        Dropbox_Entities.ContentFolderParser result = Dropbox_Api.getNextContentOfAFolder('access_token', '12345');
        Assert.areEqual(false, result.has_more);
        Assert.areEqual(3, result.entries.size());
        Test.stopTest();
    }

    @isTest 
    static void getCurrentAccountInfoTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Dropbox_ApiMock());
        Dropbox_Entities.GetAccountInfoDto result = Dropbox_Api.getCurrentAccountInfo('access_token');
        Assert.areEqual('test', result.name.display_name);
        Assert.areEqual('test@gmail.com', result.email);
        Test.stopTest();
    }

    @isTest 
    static void renameContentTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Dropbox_ApiMock());
        Dropbox_Api.renameContent('access_token', 'path/from', 'path/to');
        Test.stopTest();
    }

    @isTest 
    static void moveContentBatchTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Dropbox_ApiMock());
        Map<String, String> paths = new Map<String, String>();
        paths.put('path/from', 'path/to');
        String result = Dropbox_Api.moveContentBatch(paths, 'access_token');
        Assert.areEqual('12345', result);
        Test.stopTest();
    }

    @isTest 
    static void checkMoveContentBatchTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Dropbox_ApiMock());
        String result = Dropbox_Api.checkMoveContentBatch('12345', 'access_token');
        Assert.areEqual('complete', result);
        Test.stopTest();
    }

    @isTest 
    static void getTemporaryLinkTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Dropbox_ApiMock());
        String result = Dropbox_Api.getTemporaryLink('path/test', 'access_token');
        Assert.areEqual('test link', result);
        Test.stopTest();
    }

    @isTest 
    static void getThumbnailBatchTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Dropbox_ApiMock());
        List<Dropbox_Entities.GetThumbnailButchEntriesDto> filePaths = new List<Dropbox_Entities.GetThumbnailButchEntriesDto>();
        Dropbox_Entities.GetThumbnailButchEntriesDto filePath = new Dropbox_Entities.GetThumbnailButchEntriesDto();
        filePath.path = 'path/test';
        filePath.format = 'png';
        filePaths.add(filePath);
        Dropbox_Entities.GetThumbnailButchEntries result = Dropbox_Api.getThumbnailBatch(filePaths, 'access_token');
        Assert.areEqual(1, result.entries.size());
        Assert.areEqual('test.txt', result.entries[0].metadata.name);
        Test.stopTest();
    }

}