attribute highp vec4 position;
attribute highp vec2 texCoord;

varying highp vec2 vTexCoord;

void main() {
    vTexCoord = texCoord;
    gl_Position = position;                                     
}