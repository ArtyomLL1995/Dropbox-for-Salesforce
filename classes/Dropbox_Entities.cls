public class Dropbox_Entities {

    //Uupload file

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

    // Create folder

    public class NewFolderToCreateDto {
        public String path;
        public Boolean autorename;
    }

    public class CreatedFolderMetadataDto {
        public String name;
        public String path_lower;
        public String path_display;
        public String id;
    }

    public class CreatedFolderInfoDto {
        public CreatedFolderMetadataDto metadata;
    }

    // Delete content

    public class DeleteContentDto {
        public String path;
    }

    public class DeletedContentParser {
        public DeletedContentMetadataParser metadata;
        public DeletedContentParser(String data) {
            Map<String, Object> content = (Map<String, Object>)JSON.deserializeUntyped(data);
            Map<String, Object> contentMetadata = (Map<String, Object>) content.get('metadata');
            metadata = new DeletedContentMetadataParser(contentMetadata);
        }
    }

    public class DeletedContentMetadataParser {
        public String tag;
        public String name;
        public String path_display;
        public String id;
        public String client_modified;
        public String server_modified;
        public Long size;
        DeletedContentMetadataParser(Map<String, Object> metadata) {
            tag = (String) metadata.get('.tag');
            name = (String) metadata.get('name');
            path_display = (String) metadata.get('path_display');
            id = (String) metadata.get('id');
            client_modified = (String) metadata.get('client_modified');
            server_modified = (String) metadata.get('server_modified');
            size = (Long) metadata.get('size');
        }
    }

    // Get file or folder metadata

    public class GetContentMetadataDto {
        public Boolean include_deleted;
        public Boolean include_has_explicit_shared_members;
        public Boolean include_media_info;
        public String path;
    }

    // Get content of a folder

    public class GetContentFolderDto {
        public String path;
        public Boolean recursive; // if 'true' returns also content of all subfolders
        public Boolean include_media_info;
        public Boolean include_deleted;
        public Boolean include_has_explicit_shared_members;
        public Boolean include_mounted_folders;
        public Boolean include_non_downloadable_files;
    }

    public class ContentFolderParser {
        public List<ContentFolderEntryParser> entries = new List<ContentFolderEntryParser>();

        public ContentFolderParser(String data) {
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(data);
            List<Map<String, Object>> entries = new List<Map<String, Object>>();
            for (Object instance : (List<Object>)responseMap.get('entries')) entries.add((Map<String, Object>)instance);
            for (Map<String, Object> entry : entries) this.entries.add(new ContentFolderEntryParser(entry)); 
        }
    }

    public class ContentFolderEntryParser {
        public String tag; // in json: .tag
        public String name; 
        public String path_lower;
        public String path_display;

        public ContentFolderEntryParser(Map<String, Object> content) {
            tag = (String) content.get('.tag');
            name = (String) content.get('name');
            path_lower = (String) content.get('path_lower');
            path_display = (String) content.get('path_display');
        }

        public ContentFolderEntryParser(String data) {
            Map<String, Object> content = (Map<String, Object>)JSON.deserializeUntyped(data);
            tag = (String) content.get('.tag');
            name = (String) content.get('name');
            path_lower = (String) content.get('path_lower');
        }
    }

    // Get account info

    public class GetAccountInfoDto {
        public String team_member_id;
        public RootInfoDto root_info;
    }

    public class RootInfoDto {
        public String root_namespace_id;
    }

    // Get team memebers info

    public class GetTeamMembersDto {
        public List<TeamMemberDto> members;
    }

    public class TeamMemberDto {
        public ProfileDto profile; 
    }

    public class ProfileDto {
        public String team_member_id;
        public String email;
    }

    // Search

    public class SearchDto {
        public String query;
        public Boolean include_highlights;
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

    // download file
    public class downLoadFileDto {
        public String path;
    }
}