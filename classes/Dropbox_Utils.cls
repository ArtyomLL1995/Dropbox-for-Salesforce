public with sharing class Dropbox_Utils {

    public static final String GET = 'GET';
    public static final String POST = 'POST';
    public static final String TEAM_ACCESS_ERROR = 'This API function operates on a single Dropbox account, but the OAuth 2 access token you provided is for an entire Dropbox Business team.';
    
    public static final String ACCESS_TOKEN = '/oauth2/token';
    public static final String FILES_UPLOAD = '/files/upload';
    public static final String CREATE_FOLDER = '/files/create_folder_v2';
    public static final String DOWNLOAD_FILE = '/files/download';
    public static final String DOWNLOAD_FILE_ZIP = '/files/download_zip';
    public static final String DELETE_FILES = '/files/delete_v2';
    public static final String DELETE_FILES_BATCH = '/files/delete_batch';
    public static final String DELETE_FILES_BATCH_CHECK = '/files/delete_batch/check';
    public static final String GET_CONTENT_OF_A_FOLDER = '/files/list_folder';
    public static final String GET_NEXT_CHUNK_OF_CONTENT = '/files/list_folder/continue';
    public static final String GET_CURRENT_ACCOUNT = '/users/get_current_account';
    public static final String MOVE_FILES = '/files/move_v2';
    public static final String MOVE_FILES_BATCH = '/files/move_batch_v2';
    public static final String MOVE_FILES_BATCH_CHECK = '/files/move_batch/check_v2';
    public static final String GET_FILE_PREVIEW_LINK = '/files/get_temporary_link';
    public static final String GET_THUMBNAIL  = '/files/get_thumbnail';
    public static final String GET_THUMBNAIL_BATCH = '/files/get_thumbnail_batch';
    public static final String SEARCH = '/files/search_v2';
    public static final String SEARCH_CONTINUE = '/files/search/continue_v2';
    public static final String COPY = '/files/copy_v2';
    public static final String COPY_BATCH = '/files/copy_batch_v2';
    public static final String COPY_BATCH_CHECK = '/files/copy_batch/check_v2';
    public static final String CONTENT_METADATA = '/files/get_metadata';
    public static final String FILE_PREVIEW = '/files/get_preview';
    public static final String TEAM_MEMBERS = '/team/members/list';

}