#version 450

layout(std140, set = 0, binding = 0) uniform UBO
{
   mat4 MVP;
   vec4 OutputSize;
   vec4 OriginalSize;
   vec4 SourceSize;
} global;

vec3 dtt = vec3(65536.0,255.0,1.0);

float reduce(vec3 color)
{
	return dot(color, dtt);
}

#pragma stage vertex
layout(location = 0) in vec4 Position;
layout(location = 1) in vec2 TexCoord;
layout(location = 0) out vec2 vTexCoord;
layout(location = 1) out vec4 t1;
layout(location = 2) out vec4 t2;
layout(location = 3) out vec4 t3;
layout(location = 4) out vec4 t4;

void main()
{
   gl_Position = global.MVP * Position;
   vTexCoord = TexCoord;
   
   float dx = global.SourceSize.z;
   float dy = global.SourceSize.w;
   t1.xy = vTexCoord + vec2(-dx,-dy);
   t1.zw = vTexCoord + vec2(0 ,-dy);
   t2.xy = vTexCoord + vec2(+dx,-dy);
   t2.zw = vTexCoord + vec2(-dx, 0);
   t3.xy = vTexCoord + vec2(+dx, 0);
   t3.zw = vTexCoord + vec2(-dx, +dy);
   t4.xy = vTexCoord + vec2(0, +dy);
   t4.zw = vTexCoord + vec2(+dx, +dy);
}

#pragma stage fragment
layout(location = 0) in vec2 vTexCoord;
layout(location = 1) in vec4 t1;
layout(location = 2) in vec4 t2;
layout(location = 3) in vec4 t3;
layout(location = 4) in vec4 t4;
layout(location = 0) out vec4 FragColor;
layout(set = 0, binding = 2) uniform sampler2D Source;

float diffDegree(float dda, float ddb){
	float dd=0.0;
	if(dda>ddb){dd=dda-ddb;}
	else{dd=ddb-dda;}
	return dd;}

void main()
{
   vec2 fp = fract(vTexCoord * global.SourceSize.xy);

   // Reading the texels

   vec3 C11 = texture(Source, vTexCoord).xyz;//CENTER
   vec3 C01 = texture(Source, t2.zw).xyz;//LEFT
   vec3 C20 = texture(Source, t3.zw).xyz;//TOP-LEFT
   vec3 C12 = texture(Source, t4.xy).xyz;//TOP
   vec3 C22 = texture(Source, t4.zw).xyz;//TOP-RIGHT
   vec3 C21 = texture(Source, t3.xy).xyz;//RIGHT
   vec3 C02 = texture(Source, t2.xy).xyz;//BOTTOM-RIGHT
   vec3 C10 = texture(Source, t1.zw).xyz;//BOTTOM
   vec3 C00 = texture(Source, t1.xy).xyz;//BOTTOM-LEFT

   vec3 pFinal;

   // reducing vec3 to float	
   float c11 = reduce(C11);float c01 = reduce(C01);
   float c20 = reduce(C20);float c12 = reduce(C12);
   float c22 = reduce(C22);float c21 = reduce(C21);
   float c02 = reduce(C02);float c10 = reduce(C10);
   float c00 = reduce(C00);
   
	vec3 suaA=(C11+C01+C20+C12+C22+C21+C02+C10+C00)/9;
	vec3 suaB=(suaA+C11)/2;
	vec3 suaC=(suaB+C11)/2;
	vec3 suaD=(suaC+C11)/2;
	float uno=diffDegree(c11,c01);
	float dos=diffDegree(c11,c20);
	float tres=diffDegree(c11,c12);
	float cuatro=diffDegree(c11,c22);
	float cinco=diffDegree(c11,c21);
	float seis=diffDegree(c11,c02);
	float siete=diffDegree(c11,c10);
	float ocho=diffDegree(c11,c00);
	float nueve=diffDegree(reduce(suaA),c11);
	if(
		(uno<0.125)&&
		(dos<0.125)&&
		(tres<0.125)&&
		!(cuatro<0.25)&&
		!(cinco<0.25)&&
		!(seis<0.25)&&
		!(siete<0.25)&&
		!(ocho<0.25)
	){pFinal=(((C22+C00)/2)+C11)/2;}
	else if(
		!(uno<0.25)&&
		!(dos<0.25)&&
		(tres<0.125)&&
		(cuatro<=0.125)&&
		(cinco<=0.125)&&
		!(seis<=0.25)&&
		!(siete<=0.25)&&
		!(ocho<=0.25)
	){pFinal=(((C20+C02)/2)+C11)/2;}
	else if(
		!(uno<=0.25)&&
		!(dos<=0.25)&&
		!(tres<=0.25)&&
		!(cuatro<=0.25)&&
		(cinco<=0.125)&&
		(seis<=0.125)&&
		(siete<=0.125)&&
		!(ocho<=0.25)
	){pFinal=(((C22+C00)/2)+C11)/2;}
	else if(
		(uno<0.125)&&
		!(dos<0.25)&&
		!(tres<0.25)&&
		!(cuatro<0.25)&&
		!(cinco<0.25)&&
		!(seis<0.25)&&
		(siete<0.125)&&
		(ocho<0.125)
	){pFinal=(((C20+C02)/2)+C11)/2;}
	else{
		if(nueve>=0.5){pFinal=C11;}
		else if(nueve>=0.375){pFinal=suaD;}
		else if(nueve>=0.25){pFinal=suaC;}
		else if(nueve>=0.125){pFinal=suaB;}
		else{pFinal=suaA;}}
   FragColor = vec4(pFinal, 1.0);
}