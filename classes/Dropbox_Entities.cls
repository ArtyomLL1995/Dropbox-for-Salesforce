public class Dropbox_Entities {

    public class AccessTokenDto {
        public String accessToken;
        public String refreshToken;
        public Integer expiresIn;
        public String clientId;
        public String clientSecret;
        public String rootId;
        public String accountId;
        public String teamId;
        public String scope;
        public String selectUserId;
        @AuraEnabled public String email;
        @AuraEnabled public String accessInfoId;
        @AuraEnabled public Boolean currentActiveAccessInfo;
    }

    public class UploadFileDto {
        public String path;
        public String mode;
        public Boolean autorename;
        public Boolean mute;
        public Boolean strict_conflict;
    }

    public class UploadedFileDto {
        public String client_modified;
        public String is_downloadable;
        public String name;
        public String path_display;
        public String id;
        public String server_modified;
    }

    public class NewFolderToCreateDto {
        public String path;
        public Boolean autorename;
    }

    public class DeleteFolderDto {
        public String path;
    }

    public class CreatedFolderInfoDto {
        public CreatedFolderMetadataDto metadata;
    }

    public class CreatedFolderMetadataDto {
        public String name;
        public String path_lower;
        public String path_display;
        public String id;
    }

    public class GetFolderMetadataDto {
        public Boolean include_deleted;
        public Boolean include_has_explicit_shared_members;
        public Boolean include_media_info;
        public String path;
    }

    public class GetContentFolderDto {
        public String path;
        public Boolean recursive;
        public Boolean include_media_info;
        public Boolean include_deleted;
        public Boolean include_has_explicit_shared_members;
        public Boolean include_mounted_folders;
        public Boolean include_non_downloadable_files;
    }

    public class GetAccountInfoDto {
        public String team_member_id;
        public RootInfoDto root_info;
        public AccountNameInfo name;
        public String email;
    }

    public class RootInfoDto {
        public String root_namespace_id;
        public String home_namespace_id;
    }

    public class AccountNameInfo {
        public String display_name;
    }

    public class GetTeamMembersDto {
        public List<TeamMemberDto> members;
    }

    public class TeamMemberDto {
        public ProfileDto profile; 
    }

    public class ProfileDto {
        public String team_member_id;
        public String email;
        public String root_folder_id;
        public ProfileName name;
    }

    public class ProfileName {
        public String display_name;
    }

    public class ContentFolderParser {

        public List<ContentFolderEntryParser> entries = new List<ContentFolderEntryParser>();
        public String cursor;
        public Boolean has_more;

        public ContentFolderParser(String data) {
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(data);
            List<Map<String, Object>> entries = new List<Map<String, Object>>();
            for (Object instance : (List<Object>)responseMap.get('entries')) entries.add((Map<String, Object>)instance);
            for (Map<String, Object> entry : entries) this.entries.add(new ContentFolderEntryParser(entry)); 
            cursor = (String) responseMap.get('cursor');
            has_more = (Boolean) responseMap.get('has_more');
        }
    }

    public class ContentFolderEntryParser {

        public String tag; // in json: .tag
        public String name; 
        public String path_lower;
        public String path_display;
        public String client_modified;
        public String shared_folder_id;
        public Long size;

        public ContentFolderEntryParser(Map<String, Object> content) {
            parseContent(content);
        }

        public ContentFolderEntryParser(String data) {
            Map<String, Object> content = (Map<String, Object>)JSON.deserializeUntyped(data);
            parseContent(content);
        }

        private void parseContent(Map<String, Object> content) {
            tag = (String) content.get('.tag');
            name = (String) content.get('name');
            path_lower = (String) content.get('path_lower');
            path_display = (String) content.get('path_display');
            if (content.get('client_modified') != null) {
                client_modified = (String) content.get('client_modified');
            }
            if (content.get('size') != null) {
                size = (Long) content.get('size');
            }
            if (content.get('shared_folder_id') != null) {
                shared_folder_id = (String) content.get('shared_folder_id');
            }
        }
    }

    public class DownLoadFileDto {
        public String path;
    }

    public class SearchResultParser {

        public String cursor;
        public Boolean has_more;
        public List<SearchSingleResultParser> matches = new List<SearchSingleResultParser>();

        public SearchResultParser(String data) {
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(data);
            cursor = (String) responseMap.get('cursor');
            has_more = (Boolean) responseMap.get('has_more');
            List<Map<String, Object>> entries = new List<Map<String, Object>>();
            for (Object instance : (List<Object>)responseMap.get('matches')) entries.add((Map<String, Object>)instance);
            for (Map<String, Object> entry : entries) {
                Map<String, Object> metadata = (Map<String, Object>) entry.get('metadata');
                matches.add(new SearchSingleResultParser(metadata));
            } 
        }
    }

    public class SearchSingleResultParser {
        public SearchSingleResultDataParser metadata;
        public SearchSingleResultParser(Map<String, Object> data) {
            metadata = new SearchSingleResultDataParser((Map<String, Object>) data.get('metadata'));
        }
    }

    public class SearchSingleResultDataParser {
        public String tag;
        public String id;
        public String name;
        public String path_display;
        public String path_lower;
        public String client_modified;
        public Boolean is_downloadable;
        public Long size;
        public SearchSingleResultDataParser(Map<String, Object> content) {
            tag = (String) content.get('.tag');
            id = (String) content.get('id');
            name = (String) content.get('name');
            path_display = (String) content.get('path_display');
            path_lower = (String) content.get('path_lower');
            client_modified = (String) content.get('client_modified');
            is_downloadable = (Boolean) content.get('is_downloadable');
            size = (Long) content.get('size');
        }
    }

    public class SearchDto {
        public String query;
        public Boolean include_highlights;
        public SearchOptions options;
    }

    public class SearchOptions {
       public Integer max_results;
       public String path;
       public Boolean filename_only;
    }

    public class DeleteContentDto {
        public String path;
    }

    public class GetContentMetadataDto {
        public Boolean include_deleted;
        public Boolean include_has_explicit_shared_members;
        public Boolean include_media_info;
        public String path;
    }

    public class DeletedContentBatchDto {
        public List<DeletedContentPathDto> entries;
    }

    public class DeletedContentPathDto {
        public String path;
    }

    public class AsyncBatchJobIdDto {
        public String async_job_id;
    }

    public class GetThumbnailButchEntriesDto {
        public String path;
        public String format;
        public String size;
    }

    public class GetThumbnailButchEntries {
        public List<GetThumbnailButchEntry> entries;
    }

    public class GetThumbnailButchEntry {
        public GetThumbnailButchEntryMetadata metadata;
        public String thumbnail;
    }

    public class GetThumbnailButchEntryMetadata {
        public String name;
        public String path_lower;
        public String path_display;
        public String id;
    }

    public class CopyBatchFileEntries {
        public List<CopyBatchFileEntry> entries;
        public Boolean autorename;
    }

    public class CopyBatchFileEntry {
        public String from_path;
        public String to_path;
    }

    public class CopyFileEntry {
        public String from_path;
        public String to_path;
        public Boolean autorename;
    }

    public class MoveFileEntry {
        public String from_path;
        public String to_path;
        public Boolean autorename;
        public Boolean allow_ownership_transfer;
    }

    public class MoveFileEntryBatch {
        public String from_path;
        public String to_path;
    }

    public class MoveFileEntriesBatch {
        public List<MoveFileEntryBatch> entries;
        public Boolean autorename;
        public Boolean allow_ownership_transfer;
    }
}