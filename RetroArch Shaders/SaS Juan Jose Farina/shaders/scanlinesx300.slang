#version 450

layout(std140, set = 0, binding = 0) uniform UBO
{
   mat4 MVP;
   vec4 OutputSize;
   vec4 OriginalSize;
   vec4 SourceSize;
} global;

#pragma stage vertex
layout(location = 0) in vec4 Position;
layout(location = 1) in vec2 TexCoord;
layout(location = 0) out vec2 vTexCoord;

void main()
{
   gl_Position = global.MVP * Position;
   vTexCoord = TexCoord;
}

#pragma stage fragment
layout(location = 0) in vec2 vTexCoord;
layout(location = 0) out vec4 FragColor;
layout(set = 0, binding = 2) uniform sampler2D Source;

void main()
{
    vec4 color = texture(Source, vTexCoord);

    int scanlines = 300;
    int currentRow = int(vTexCoord.y * global.OutputSize.y);  // 0.001 * 1000 = 1
    int totalRows = int(global.OutputSize.y);  // 1000
    int sectionHeight = totalRows / scanlines;  // 1000 / 50 = 20

    if (currentRow % sectionHeight < sectionHeight * 0.5) {
        vec3 darkenedColor = color.rgb * 0.2;
        FragColor = vec4(darkenedColor, color.a);
    } else {
        vec3 brightenedColor = color.rgb * 1.2;
        brightenedColor = clamp(brightenedColor, 0.0, 1.0);
        FragColor = vec4(brightenedColor, color.a);
    }
}

