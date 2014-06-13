
local photoMetadata = {}

photoMetadata[#photoMetadata + 1] = { id='lastUpdate', title = 'Last Update', version=1, dataType='string', searchable=true, browsable=true }

return {

    metadataFieldsForPhotos = photoMetadata,
   
    schemaVersion = 1,
    
    -- updateFromEarlierSchemaVersion = function( catalog, previousSchemaVersion ) ... end
    
}
