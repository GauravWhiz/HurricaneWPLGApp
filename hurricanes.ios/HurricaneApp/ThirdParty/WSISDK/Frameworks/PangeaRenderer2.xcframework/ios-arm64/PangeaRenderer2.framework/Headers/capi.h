#pragma once

#include <stddef.h>
#include <stdint.h>

#if defined(__cplusplus)
extern "C" {
#endif

typedef enum PangeaError {

    /// The operation has completed successfully.
    PANGEA_SUCCESS = 0,

    /// The operation has failed for unknown reason.
    PANGEA_FAILURE = -1,

    /// The given argument was not valid.
    PANGEA_INVALID_ARGUMENT = -2,

    /// The operation is not yet implemented.
    PANGEA_NOT_IMPLEMENTED = -3,

} PangeaError;

typedef struct PangeaRenderer* PangeaRendererHandle;

PangeaError pangea_create_sync_renderer(PangeaRendererHandle* renderer);

PangeaError pangea_destroy_sync_renderer(PangeaRendererHandle* renderer);

//----------------------------------------------------------------------------------------------------------------------
// Command queue
//----------------------------------------------------------------------------------------------------------------------

typedef struct PangeaRendererCommandQueue* PangeaRendererCommandQueueHandle;

PangeaError pangea_create_renderer_command_queue(PangeaRendererCommandQueueHandle* queue);

PangeaError pangea_destroy_renderer_command_queue(PangeaRendererCommandQueueHandle* queue);

PangeaError pangea_renderer_enqueue(PangeaRendererHandle renderer, PangeaRendererCommandQueueHandle queue);

PangeaError pangea_renderer_set_viewport(PangeaRendererHandle renderer, int width, int height);

PangeaError pangea_renderer_submit(PangeaRendererHandle renderer);

PangeaError pangea_renderer_context_lost(PangeaRendererHandle renderer);

//----------------------------------------------------------------------------------------------------------------------
// Palette
//----------------------------------------------------------------------------------------------------------------------

typedef struct PangeaPaletteEntry {

    float step;

    float r;
    float g;
    float b;
    float a;

} PangeaPaletteEntry;

typedef enum PangeaPaletteKind {

    PANGEA_PALETTE_KIND_INTERPOLATED = 0,
    PANGEA_PALETTE_KIND_STEPPED      = 1,

} PangeaPaletteKind;

typedef struct PangeaPalette* PangeaPaletteHandle;

PangeaError pangea_renderer_create_palette(PangeaRendererHandle renderer,
                                           PangeaPaletteHandle* palette,
                                           PangeaPaletteKind    palette_kind);

PangeaError pangea_renderer_destroy_palette(PangeaPaletteHandle* palette);

PangeaError pangea_palette_set_entries(PangeaPaletteHandle              palette,
                                       PangeaRendererCommandQueueHandle queue,
                                       PangeaPaletteEntry const*        entries,
                                       size_t                           num_entries);

PangeaError pangea_palette_change_kind(PangeaPaletteHandle              palette,
                                       PangeaRendererCommandQueueHandle queue,
                                       PangeaPaletteKind                palette_kind);

typedef enum PangeaQueryStatus {

    PANGEA_QUERY_PENDING   = 0,
    PANGEA_QUERY_COMPLETED = 1,

} PangeaQueryStatus;

typedef struct PangeaTilePosition {

    int x, y, z;

} PangeaTilePosition;

//----------------------------------------------------------------------------------------------------------------------
// Receiving messages
//----------------------------------------------------------------------------------------------------------------------

typedef struct PangeaSink* PangeaSinkHandle;

PangeaError pangea_renderer_create_sink(PangeaRendererHandle renderer, PangeaSinkHandle* sink);

PangeaError pangea_renderer_destroy_sink(PangeaSinkHandle* sink);

PangeaError pangea_sink_get_file_descriptor(PangeaSinkHandle sink, int* file_descriptor);

//----------------------------------------------------------------------------------------------------------------------
// Querying tiles
//----------------------------------------------------------------------------------------------------------------------

typedef struct PangeaTilesQuery* PangeaTilesQueryHandle;

PangeaError pangea_renderer_create_tiles_query(PangeaRendererHandle renderer, PangeaTilesQueryHandle* query);

PangeaError pangea_renderer_destroy_tiles_query(PangeaTilesQueryHandle* query);

PangeaError pangea_tiles_query_get_status(PangeaTilesQueryHandle query, PangeaQueryStatus* status);

PangeaError pangea_tiles_query_get_tile_count(PangeaTilesQueryHandle query, size_t* tile_count);

PangeaError pangea_tiles_query_get_tiles(PangeaTilesQueryHandle query, PangeaTilePosition* tiles, size_t tile_count);

//----------------------------------------------------------------------------------------------------------------------
// Camera
//----------------------------------------------------------------------------------------------------------------------

typedef struct PangeaCamera* PangeaCameraHandle;

PangeaError pangea_renderer_create_camera(PangeaRendererHandle renderer, PangeaCameraHandle* camera);

PangeaError pangea_renderer_destroy_camera(PangeaCameraHandle* camera);

PangeaError pangea_camera_update(PangeaCameraHandle               camera,
                                 PangeaRendererCommandQueueHandle queue,
                                 double const                     longitude,
                                 double const                     latitude,
                                 double const                     zoom,
                                 double const                     viewport_width,
                                 double const                     viewport_height);

PangeaError pangea_camera_query_visible_tiles(PangeaCameraHandle               camera,
                                              PangeaRendererCommandQueueHandle queue,
                                              PangeaTilesQueryHandle           query);

PangeaError pangea_camera_set_viewport(PangeaCameraHandle               camera,
                                       PangeaRendererCommandQueueHandle queue,
                                       int                              width,
                                       int                              height);

PangeaError pangea_camera_set_location(PangeaCameraHandle               camera,
                                       PangeaRendererCommandQueueHandle queue,
                                       double                           longitude,
                                       double                           latitude,
                                       double                           zoom);

PangeaError pangea_camera_set_pixels_per_point(PangeaCameraHandle               camera,
                                               PangeaRendererCommandQueueHandle queue,
                                               double                           pixels_per_point);

PangeaError pangea_camera_set_zoom_offset(PangeaCameraHandle               camera,
                                          PangeaRendererCommandQueueHandle queue,
                                          double const                     zoom_offset);

PangeaError pangea_camera_set_zoom_constraint(PangeaCameraHandle               camera,
                                              PangeaRendererCommandQueueHandle queue,
                                              double const                     min_zoom,
                                              double const                     max_zoom);

PangeaError pangea_camera_set_density(PangeaCameraHandle               camera,
                                      PangeaRendererCommandQueueHandle queue,
                                      double const                     value);

//----------------------------------------------------------------------------------------------------------------------
// Tile filtering
//----------------------------------------------------------------------------------------------------------------------

typedef struct PangeaTileFilter* PangeaTileFilterHandle;

typedef struct PangeaNullTileFilter* PangeaNullTileFilterHandle;

PangeaError pangea_renderer_create_null_tile_filter(PangeaRendererHandle renderer, PangeaNullTileFilterHandle* filter);

PangeaError pangea_renderer_destroy_null_tile_filter(PangeaNullTileFilterHandle* filter);

PangeaError pangea_cast_null_tile_filter_to_tile_filter(PangeaNullTileFilterHandle from_filter,
                                                        PangeaTileFilterHandle*    to_filter);

typedef struct PangeaZoomTileFilter* PangeaZoomTileFilterHandle;

PangeaError pangea_renderer_create_zoom_tile_filter(PangeaRendererHandle        renderer,
                                                    PangeaZoomTileFilterHandle* filter,
                                                    int                         min_zoom,
                                                    int                         max_zoom);

PangeaError pangea_renderer_destroy_zoom_tile_filter(PangeaZoomTileFilterHandle* filter);

PangeaError pangea_cast_zoom_tile_filter_to_tile_filter(PangeaZoomTileFilterHandle from_filter,
                                                        PangeaTileFilterHandle*    to_filter);

typedef struct PangeaBoundedTileFilter* PangeaBoundedTileFilterHandle;

PangeaError pangea_renderer_create_bounded_tile_filter(PangeaRendererHandle           renderer,
                                                       PangeaBoundedTileFilterHandle* filter,
                                                       double                         north,
                                                       double                         west,
                                                       double                         south,
                                                       double                         east);

PangeaError pangea_renderer_destroy_bounded_tile_filter(PangeaBoundedTileFilterHandle* filter);

PangeaError pangea_cast_bounded_tile_filter_to_tile_filter(PangeaBoundedTileFilterHandle from_filter,
                                                           PangeaTileFilterHandle*       to_filter);

//----------------------------------------------------------------------------------------------------------------------
// Client side rendering
//----------------------------------------------------------------------------------------------------------------------

typedef enum PangeaTileSize {

    PANGEA_TILE_SIZE_SMALL = 0,
    PANGEA_TILE_SIZE_LARGE = 1

} PangeaTileSize;

typedef enum PangeaDataFormat {

    PANGEA_DATA_FORMAT_FLOAT_LE = 0,
    PANGEA_DATA_FORMAT_FLOAT_BE = 1,

} PangeaDataFormat;

typedef struct PangeaClientSideRenderingLayer* PangeaClientSideRenderingLayerHandle;

PangeaError pangea_renderer_create_client_side_rendering_layer(PangeaRendererHandle                  renderer,
                                                               PangeaClientSideRenderingLayerHandle* layer,
                                                               size_t                                capacity);

PangeaError pangea_renderer_destroy_client_side_rendering_layer(PangeaClientSideRenderingLayerHandle* layer);

PangeaError pangea_client_side_rendering_layer_add_tile(PangeaClientSideRenderingLayerHandle layer,
                                                        PangeaRendererCommandQueueHandle     queue,
                                                        void const*                          tile_data,
                                                        size_t                               tile_data_size,
                                                        size_t                               tile_data_offset,
                                                        size_t                               tile_data_stride,
                                                        PangeaDataFormat                     tile_data_format,
                                                        PangeaTileSize                       tile_size,
                                                        int                                  tile_x,
                                                        int                                  tile_y,
                                                        int                                  tile_z);

PangeaError pangea_client_side_rendering_layer_draw(PangeaClientSideRenderingLayerHandle layer,
                                                    PangeaRendererCommandQueueHandle     queue,
                                                    PangeaCameraHandle                   camera);

PangeaError pangea_client_side_rendering_layer_set_name(PangeaClientSideRenderingLayerHandle layer,
                                                        PangeaRendererCommandQueueHandle     queue,
                                                        char const*                          name,
                                                        size_t                               name_length);

PangeaError pangea_client_side_rendering_layer_set_palette(PangeaClientSideRenderingLayerHandle layer,
                                                           PangeaRendererCommandQueueHandle     queue,
                                                           PangeaPaletteHandle                  palette);

PangeaError pangea_client_side_rendering_layer_set_tile_data_range(PangeaClientSideRenderingLayerHandle layer,
                                                                   PangeaRendererCommandQueueHandle     queue,
                                                                   float                                lower_bound,
                                                                   float                                upper_bound);

PangeaError pangea_client_side_rendering_layer_enable_tile_data_filtering(PangeaClientSideRenderingLayerHandle layer,
                                                                          PangeaRendererCommandQueueHandle     queue,
                                                                          bool const                           enabled);

PangeaError pangea_client_side_rendering_layer_get_value_at(PangeaClientSideRenderingLayerHandle layer,
                                                            PangeaRendererCommandQueueHandle     queue,
                                                            PangeaCameraHandle                   camera,
                                                            double const                         longitude,
                                                            double const                         latitude,
                                                            PangeaSinkHandle                     sink);

PangeaError pangea_client_side_rendering_layer_query_missing_tiles(PangeaClientSideRenderingLayerHandle layer,
                                                                   PangeaRendererCommandQueueHandle     queue,
                                                                   PangeaCameraHandle                   camera,
                                                                   PangeaTilesQueryHandle               query);

PangeaError pangea_client_side_rendering_layer_set_opacity(PangeaClientSideRenderingLayerHandle layer,
                                                           PangeaRendererCommandQueueHandle     queue,
                                                           float                                value);

PangeaError pangea_client_side_rendering_layer_set_tile_filter(PangeaClientSideRenderingLayerHandle layer,
                                                               PangeaRendererCommandQueueHandle     queue,
                                                               PangeaTileFilterHandle               filter);

PangeaError pangea_client_side_rendering_layer_add_empty_tile(PangeaClientSideRenderingLayerHandle layer,
                                                              PangeaRendererCommandQueueHandle     queue,
                                                              int                                  tile_x,
                                                              int                                  tile_y,
                                                              int                                  tile_z);

//----------------------------------------------------------------------------------------------------------------------
// Server side rendering
//----------------------------------------------------------------------------------------------------------------------

typedef enum PangeaPixelFormat {

    PANGEA_PIXEL_FORMAT_RGBA = 1, // Memory layout: [R][G][B][A]
                                  // Byte   offset:  0  1  2  3

} PangeaPixelFormat;

typedef struct PangeaServerSideRenderingLayer* PangeaServerSideRenderingLayerHandle;

PangeaError pangea_renderer_create_server_side_rendering_layer(PangeaRendererHandle                  renderer,
                                                               PangeaServerSideRenderingLayerHandle* layer,
                                                               size_t                                capacity);

PangeaError pangea_renderer_destroy_server_side_rendering_layer(PangeaServerSideRenderingLayerHandle* layer);

PangeaError pangea_server_side_rendering_layer_draw(PangeaServerSideRenderingLayerHandle layer,
                                                    PangeaRendererCommandQueueHandle     queue,
                                                    PangeaCameraHandle                   camera);

PangeaError pangea_server_side_rendering_layer_set_name(PangeaServerSideRenderingLayerHandle layer,
                                                        PangeaRendererCommandQueueHandle     queue,
                                                        char const*                          name,
                                                        size_t                               name_length);

PangeaError pangea_server_side_rendering_layer_get_value_at(PangeaClientSideRenderingLayerHandle layer,
                                                            PangeaRendererCommandQueueHandle     queue,
                                                            PangeaCameraHandle                   camera,
                                                            double const                         longitude,
                                                            double const                         latitude,
                                                            PangeaSinkHandle                     sink);

PangeaError pangea_server_side_rendering_layer_query_missing_tiles(PangeaServerSideRenderingLayerHandle layer,
                                                                   PangeaRendererCommandQueueHandle     queue,
                                                                   PangeaCameraHandle                   camera,
                                                                   PangeaTilesQueryHandle               query);

PangeaError pangea_server_side_rendering_layer_add_tile(PangeaServerSideRenderingLayerHandle layer,
                                                        PangeaRendererCommandQueueHandle     queue,
                                                        void const*                          tile_data,
                                                        size_t                               tile_data_size,
                                                        size_t                               tile_data_offset,
                                                        PangeaPixelFormat                    pixel_format,
                                                        PangeaTileSize                       tile_size,
                                                        int                                  tile_x,
                                                        int                                  tile_y,
                                                        int                                  tile_z);

PangeaError pangea_server_side_rendering_layer_set_opacity(PangeaServerSideRenderingLayerHandle layer,
                                                           PangeaRendererCommandQueueHandle     queue,
                                                           float                                value);

PangeaError pangea_server_side_rendering_layer_set_tile_filter(PangeaServerSideRenderingLayerHandle layer,
                                                               PangeaRendererCommandQueueHandle     queue,
                                                               PangeaTileFilterHandle               filter);

PangeaError pangea_server_side_rendering_layer_add_empty_tile(PangeaServerSideRenderingLayerHandle layer,
                                                              PangeaRendererCommandQueueHandle     queue,
                                                              int                                  tile_x,
                                                              int                                  tile_y,
                                                              int                                  tile_z);

PangeaError pangea_plog_set_level(int const level);

//----------------------------------------------------------------------------------------------------------------------
// Windstream V1
//----------------------------------------------------------------------------------------------------------------------

typedef enum PangeaLinesQuality {
    PANGEA_LOW_QUALITY_LINES  = 0,
    PANGEA_HIGH_QUALITY_LINES = 1,
} PangeaLinesQuality;

typedef struct PangeaWindstreamV1* PangeaWindstreamV1Handle;

PangeaError pangea_renderer_create_windstream_v1(PangeaRendererHandle      renderer,
                                                 PangeaWindstreamV1Handle* windstream,
                                                 char const*               config_xml,
                                                 size_t                    config_xml_length);

PangeaError pangea_renderer_destroy_windstream_v1(PangeaWindstreamV1Handle* windstream);

PangeaError pangea_windstream_v1_set_max_duration(PangeaWindstreamV1Handle         windstream,
                                                  PangeaRendererCommandQueueHandle queue,
                                                  double                           value);

PangeaError pangea_windstream_v1_set_emission_rate(PangeaWindstreamV1Handle         windstream,
                                                   PangeaRendererCommandQueueHandle queue,
                                                   double                           value);

PangeaError pangea_windstream_v1_set_max_particle_count(PangeaWindstreamV1Handle         windstream,
                                                        PangeaRendererCommandQueueHandle queue,
                                                        size_t                           value);

PangeaError pangea_windstream_v1_set_duration_scale(PangeaWindstreamV1Handle         windstream,
                                                    PangeaRendererCommandQueueHandle queue,
                                                    double                           value);

PangeaError pangea_windstream_v1_set_fade_in(PangeaWindstreamV1Handle         windstream,
                                             PangeaRendererCommandQueueHandle queue,
                                             double                           start,
                                             double                           stop);

PangeaError pangea_windstream_v1_set_fade_out(PangeaWindstreamV1Handle         windstream,
                                              PangeaRendererCommandQueueHandle queue,
                                              double                           start,
                                              double                           stop);

PangeaError pangea_windstream_v1_set_clip_region(PangeaWindstreamV1Handle         windstream,
                                                 PangeaRendererCommandQueueHandle queue,
                                                 double                           west,
                                                 double                           north,
                                                 double                           east,
                                                 double                           south);

PangeaError pangea_windstream_v1_enable_clipping(PangeaWindstreamV1Handle         windstream,
                                                 PangeaRendererCommandQueueHandle queue,
                                                 bool                             enabled);

PangeaError pangea_windstream_v1_set_sprite_sheet(PangeaWindstreamV1Handle         windstream,
                                                  PangeaRendererCommandQueueHandle queue,
                                                  size_t                           bitmap_width,
                                                  size_t                           bitmap_height,
                                                  void const*                      bitmap_argb_8888,
                                                  size_t                           bitmap_size_bytes);

PangeaError pangea_windstream_v1_set_lines_quality(PangeaWindstreamV1Handle         windstream,
                                                   PangeaRendererCommandQueueHandle queue,
                                                   PangeaLinesQuality               quality);

PangeaError pangea_windstream_v1_set_palette(PangeaWindstreamV1Handle         windstream,
                                             PangeaRendererCommandQueueHandle queue,
                                             size_t                           bitmap_width,
                                             size_t                           bitmap_height,
                                             void const*                      bitmap_argb_8888,
                                             size_t                           bitmap_size_bytes);

PangeaError pangea_windstream_v1_set_sprite_size(PangeaWindstreamV1Handle         windstream,
                                                 PangeaRendererCommandQueueHandle queue,
                                                 double                           width,
                                                 double                           height);

PangeaError pangea_windstream_v1_set_speed_range(PangeaWindstreamV1Handle         windstream,
                                                 PangeaRendererCommandQueueHandle queue,
                                                 double const                     lower_bound,
                                                 double const                     upper_bound);

PangeaError pangea_windstream_v1_set_uvt(PangeaWindstreamV1Handle         windstream,
                                         PangeaRendererCommandQueueHandle queue,
                                         size_t                           bitmap_width,
                                         size_t                           bitmap_height,
                                         void const*                      bitmap_argb_8888,
                                         size_t                           bitmap_size_bytes);

PangeaError pangea_windstream_v1_set_uvt_region(PangeaWindstreamV1Handle         windstream,
                                                PangeaRendererCommandQueueHandle queue,
                                                double const                     west,
                                                double const                     south,
                                                double const                     east,
                                                double const                     north);

PangeaError pangea_windstream_v1_draw(PangeaWindstreamV1Handle         windstream,
                                      PangeaRendererCommandQueueHandle queue,
                                      PangeaCameraHandle               camera);

typedef enum WindFormat {

    WIND_FORMAT_U_V_TEMPERATURE             = 0,
    WIND_FORMAT_SPEED_DIRECTION_TEMPERATURE = 1,

} WindFormat;

PangeaError pangea_windstream_v1_set_data(PangeaWindstreamV1Handle         windstream,
                                          PangeaRendererCommandQueueHandle queue,
                                          WindFormat const                 data_format,
                                          void const*                      data,
                                          size_t const                     data_width,
                                          size_t const                     data_height,
                                          double const                     data_bounds_west,
                                          double const                     data_bounds_south,
                                          double const                     data_bounds_east,
                                          double const                     data_bounds_north);

typedef enum WindColorSource {

    WIND_COLOR_SOURCE_NONE        = 0,
    WIND_COLOR_SOURCE_PROGRESS    = 1,
    WIND_COLOR_SOURCE_TEMPERATURE = 2,
    WIND_COLOR_SOURCE_SPEED       = 3,

} WindColorSource;

PangeaError pangea_windstream_v1_set_color_source(PangeaWindstreamV1Handle         windstream,
                                                  PangeaRendererCommandQueueHandle queue,
                                                  WindColorSource const            color_source);

PangeaError pangea_windstream_v1_set_opacity(PangeaWindstreamV1Handle         windstream,
                                             PangeaRendererCommandQueueHandle queue,
                                             double const                     opacity);

#if defined(__cplusplus)
}
#endif
