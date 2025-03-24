#if !defined(RENDER_PASS)
#define RENDER_PASS RENDER_PASS_DEFAULT
#endif

////////////////////////////////////////////////////////////////////////////////////////////////////
// Common stuff:

varying vec2 v_texcoord;

////////////////////////////////////////////////////////////////////////////////////////////////////
// Vertex shader:

#if SHADER_STAGE == SHADER_STAGE_VERTEX
attribute highp vec2 a_position;
attribute vec2       a_texcoord;

// This is the model-view-projection matrix.
uniform highp mat4 u_MVP;

void main() {
    v_texcoord  = a_texcoord;
    gl_Position = u_MVP * vec4(a_position, 0, 1); 
}
#endif // SHADER_STAGE == SHADER_STAGE_VERTEX

////////////////////////////////////////////////////////////////////////////////////////////////////
// Fragment shader:

// Default render pass:
#if (SHADER_STAGE == SHADER_STAGE_FRAGMENT) && (RENDER_PASS == RENDER_PASS_DEFAULT)

uniform float u_opacity;

#if defined(CLIENT_SIDE_RENDERING)
uniform highp sampler2D u_tile_data;
uniform float           u_tile_data_lower_bound;
uniform float           u_tile_data_upper_bound;
uniform int             u_tile_data_packed;
uniform int             u_tile_data_simulate_linear;
uniform int             u_tile_data_enable_filtering;
uniform float           u_palette_lower_bound;
uniform float           u_palette_upper_bound;
uniform int             u_palette_filter_lower_bound;
uniform int             u_palette_filter_upper_bound;

uniform int u_palette_is_interpolated;

vec4 interpolate(in vec4 from, in vec4 to, in float t) {
    if (1 == u_palette_is_interpolated) {
        return mix(from, to, t);
    }
    return from;
}

#if include "palette.glsl"
#else
vec4 palette_color(in float x) {
    float t = (x - u_tile_data_lower_bound) / (u_tile_data_upper_bound - u_tile_data_lower_bound);
    return vec4(t, t, t, 1.0);
}
#endif

// There's no `isnan(float)` in GLSL 1.00. This is our own implementation of it for this GLSL
// version. Please note, this function does not make sense for those OpenGL implementations
// that do not implement `texture_float` extension.
// @see https://www.khronos.org/registry/OpenGL-Refpages/es3.1/html/isnan.xhtml
#if __VERSION__ == 100
// NOTE: based on the results of our tests, this is a safe version of isnan detection
// which works well against GLSL optimizer.
bool isnan(float value) {
    vec3  v = vec3(value > 0.0 ? 1.0 : 0.0, value < 0.0 ? 2.0 : 0.0, value == 0.0 ? 3.0 : 0.0);
    vec3  u = vec3(4.0, 5.0, 6.0);
    float r = dot(v, u);
    return (r == 0.0);
}
#endif

// This is structure contains the result of `sample_*()` functions. It packs together the
// sampled value and a flag that indicates whether that value is NaN.
struct sample_result {
    float value;
    bool  is_nan;
};

// This function takes a packed floating point value (this is our internal format) and checks
// whether that value is NaN. We need to do this because it is very likely that the OpenGL
// implementation, that does not implement `texture_float` extension, is not able to represent
// NaN at all (so that our own `isnan(float)` won't work as well).
bool check_nan(vec4 texel) {
    // Texel contents:
    //      r - 8-bit exponent
    //      g - 1-bit sign, 7-bit mantissa (bits 16..22)
    //      b -             8-bit mantissa (bits  8..15)
    //      a -             8-bit mantissa (bits  0..7 )

    vec4 bytes = floor(texel * 255.0);

    // Get rid of the sign bit.
    if (bytes.g > float(0x7F)) {
        bytes.g -= float(0x80);
    }

    // If it's NaN, then the exponent bits are all set.
    bool nan_exponent = float(0xFF) == bytes.r;

    // If it's NaN, then the some mantissa bits must be set.
    bool nan_mantissa = float(0x00) != bytes.g || float(0x00) != bytes.b || float(0x00) != bytes.a;

    return nan_exponent && nan_mantissa;
}

float unpack(vec4 texel) {
    // Texel contents:
    //      r - 8-bit exponent
    //      g - 1-bit sign, 7-bit mantissa (bits 16..22)
    //      b -             8-bit mantissa (bits  8..15)
    //      a -             8-bit mantissa (bits  0..7 )

    vec4 bytes = floor(texel * 255.0);

    float sign_bit = 1.0;
    if (bytes.g > float(0x7F)) {
        bytes.g -= float(0x80);
        sign_bit = -1.0;
    }

    float exponent = bytes.r;

    // On my LG L90 (powered by Qualcomm GPU) shader compilation returns 'integer overflow' error. That's why I have
    // to replace this code:
    //	float mantissa = dot(bytes.gba, vec3(0x10000, 0x100, 1.0));
    // with:
    float mantissa = dot(bytes.gba, vec3(65536.0, 256.0, 1.0));

    // On my LG L90 (powered by Qualcomm GPU) shader compilation returns 'integer overflow' error. That's why I have
    // to replace this code:
    //	return sign_bit * (1.0 + (mantissa / float(0x800000))) * pow(2.0, exponent - 127.0);
    // with:
    return sign_bit * (1.0 + (mantissa / 8388608.0)) * pow(2.0, exponent - 127.0);
}

// Sample from packed data texture, simulate linear filtering.
sample_result sample_packed(highp sampler2D packed_floats, vec2 texture_size, vec2 tex_coord) {
    vec2 pixel_pos = tex_coord * (texture_size - 1.0);
    vec2 x0y0      = floor(pixel_pos);
    vec2 x1y1      = ceil(pixel_pos);
    vec2 uv_x0y0   = (x0y0 + 0.5) / texture_size;
    vec2 uv_x1y1   = (x1y1 + 0.5) / texture_size;
    // Сheck whether the value is NaN (Not a Number).
    bool is_nan = check_nan(texture2D(packed_floats, vec2(uv_x0y0.x, uv_x0y0.y))) ||
                  check_nan(texture2D(packed_floats, vec2(uv_x0y0.x, uv_x1y1.y))) ||
                  check_nan(texture2D(packed_floats, vec2(uv_x1y1.x, uv_x0y0.y))) ||
                  check_nan(texture2D(packed_floats, vec2(uv_x1y1.x, uv_x1y1.y)));
    if (is_nan) {
        // If it is, then we return the empty value and that NaN is true.
        return sample_result(0.0, is_nan);
    }
    float value_x0y0 = unpack(texture2D(packed_floats, vec2(uv_x0y0.x, uv_x0y0.y)));
    float value_x0y1 = unpack(texture2D(packed_floats, vec2(uv_x0y0.x, uv_x1y1.y)));
    float value_x1y0 = unpack(texture2D(packed_floats, vec2(uv_x1y1.x, uv_x0y0.y)));
    float value_x1y1 = unpack(texture2D(packed_floats, vec2(uv_x1y1.x, uv_x1y1.y)));
    float a_x        = abs(pixel_pos.x - x0y0.x);
    float a_y        = abs(pixel_pos.y - x0y0.y);
    float value_x0   = value_x0y0 * (1.0 - a_x) + value_x1y0 * a_x;
    float value_x1   = value_x0y1 * (1.0 - a_x) + value_x1y1 * a_x;
    return sample_result(value_x0 * (1.0 - a_y) + value_x1 * a_y, is_nan);
}

// Sample from data texture, simulate linear filtering. NOTE: this is copy-n-paste from sample_packed function.
// TODO: figure out how to split these two functions, so that we could re-use more code.
sample_result sample_floats(highp sampler2D floats, vec2 texture_size, vec2 tex_coord) {
    vec2  pixel_pos    = tex_coord * (texture_size - 1.0);
    vec2  x0y0         = floor(pixel_pos);
    vec2  x1y1         = ceil(pixel_pos);
    vec2  uv_x0y0      = (x0y0 + 0.5) / texture_size;
    vec2  uv_x1y1      = (x1y1 + 0.5) / texture_size;
    float value_x0y0   = texture2D(floats, vec2(uv_x0y0.x, uv_x0y0.y)).r;
    float value_x0y1   = texture2D(floats, vec2(uv_x0y0.x, uv_x1y1.y)).r;
    float value_x1y0   = texture2D(floats, vec2(uv_x1y1.x, uv_x0y0.y)).r;
    float value_x1y1   = texture2D(floats, vec2(uv_x1y1.x, uv_x1y1.y)).r;
    float a_x          = abs(pixel_pos.x - x0y0.x);
    float a_y          = abs(pixel_pos.y - x0y0.y);
    float value_x0     = value_x0y0 * (1.0 - a_x) + value_x1y0 * a_x;
    float value_x1     = value_x0y1 * (1.0 - a_x) + value_x1y1 * a_x;
    float result_value = value_x0 * (1.0 - a_y) + value_x1 * a_y;
    return sample_result(result_value, isnan(result_value));
}

sample_result sample_temperature() {
    if (1 == u_tile_data_packed) {
        // TODO
        //	Get rid of hard-coded texture size.
        return sample_packed(u_tile_data, vec2(256.0), v_texcoord);
    }

    if (1 == u_tile_data_simulate_linear) {
        // TODO
        //	Get rid of hard-coded texture size.
        return sample_floats(u_tile_data, vec2(256.0), v_texcoord);
    }

    float value = texture2D(u_tile_data, v_texcoord).r;
    return sample_result(value, isnan(value));
}

void main() {
    sample_result temperature = sample_temperature();

    if (temperature.is_nan) {
        discard;

        // NOTE
        //
        //  Need to return, because whether discard cancels execution depends entirely on
        //  the hardware.
        return;
    }

    if (1 == u_tile_data_enable_filtering) {
        if (u_tile_data_lower_bound > temperature.value || temperature.value > u_tile_data_upper_bound) {
            discard;

            // NOTE
            //
            //  Need to return, because whether discard cancels execution depends entirely on
            //  the hardware.
            return;
        }
    }

    if (1 == u_palette_filter_lower_bound) {
        if (u_palette_lower_bound > temperature.value) {
            discard;

            // NOTE
            //
            //  Need to return, because whether discard cancels execution depends entirely on
            //  the hardware.
            return;
        }
    }
    if (1 == u_palette_filter_upper_bound) {
        if (u_palette_upper_bound < temperature.value) {
            discard;

            // NOTE
            //
            //  Need to return, because whether discard cancels execution depends entirely on
            //  the hardware.
            return;
        }
    }

    vec4 out_color = palette_color(temperature.value);
    out_color.a *= u_opacity;
    gl_FragColor = vec4(out_color.rgb * out_color.a, out_color.a);
}
#endif

#if defined(SERVER_SIDE_RENDERING)
uniform sampler2D u_tile_data;

void main() {
    // Output premultiplied alpha.
    //
    // NOTE:
    //  This code makes assumption that u_tile_data contains premultiplied alpha.
    vec4 out_color = texture2D(u_tile_data, v_texcoord);
    gl_FragColor = out_color * u_opacity;
}
#endif

#endif // (SHADER_STAGE == SHADER_STAGE_FRAGMENT) && (RENDER_PASS == RENDER_PASS_DEFAULT)

// Stencil render pass:
#if (SHADER_STAGE == SHADER_STAGE_FRAGMENT) && (RENDER_PASS == RENDER_PASS_STENCIL)
void main() { gl_FragColor = vec4(v_texcoord, 0.0, 1.0); }
#endif
