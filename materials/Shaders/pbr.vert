%%VERTEX_GLOBAL_NAMESPACE%%
#line 10002

/***********************************************************************/
// Uniforms

//The api_custom_unit_shaders supplies these definitions:
uniform mat4 camera;		//ViewMatrix (gl_ModelViewMatrix is ModelMatrix!)
uniform vec3 cameraPos;

//The api_custom_unit_shaders supplies this definition:
uniform mat4 shadowMatrix;

/***********************************************************************/
// Varyings

out Data {
	vec3 worldPos;
	vec3 cameraDir;
	vec2 texCoord;

	vec4 shadowTexCoord;

	#ifdef GET_NORMALMAP
		#ifdef HAS_TANGENTS
			mat3 worldTBN;
		#else
			vec3 worldNormal;
		#endif
	#else
		vec3 worldNormal;
	#endif
};

//For a moment pretend we have passed OpenGL 2.0 era
#define modelMatrix gl_ModelViewMatrix			// don't trust the ModelView name, it's modelMatrix in fact
#define viewMatrix camera						// viewMatrix is mat4 uniform supplied by CUS gadget
#define normalMatrix gl_NormalMatrix			// world space matrix for normals transformation
#define projectionMatrix gl_ProjectionMatrix	// just because I don't like gl_BlaBla

void main(void)	{
	vec4 modelPos = gl_Vertex;
	vec3 modelNormal = gl_Normal;

	%%VERTEX_PRE_TRANSFORM%%

	#ifdef GET_NORMALMAP
		#ifdef HAS_TANGENTS
			vec3 worldNormalN = normalize(normalMatrix * modelNormal);
			// The use of gl_MultiTexCoord[5,6] is a hack due to lack of support of proper attributes
			// TexCoord5 and TexCoord6 are defined and filled in engine. See: rts/Rendering/Models/AssParser.cpp
			vec3 modelTangent = gl_MultiTexCoord5.xyz;
			vec3 worldTangent = normalize(vec3(modelMatrix * vec4(modelTangent, 0.0)));

			// Do Gramm-Schmidt re-ortogonalization
			#if 1
				worldTangent = normalize(worldTangent - worldNormalN * dot(worldNormalN, worldTangent));
			#endif

			#if 1 //take modelBitangent from attributes
				vec3 modelBitangent = -gl_MultiTexCoord6.xyz;
				vec3 worldBitangent = normalize(vec3(modelMatrix * vec4(modelBitangent, 0.0)));
			#else //calculate worldBitangent
				//vec3 worldBitangent = normalize( cross(worldTangent, worldNormalN) );
				vec3 worldBitangent = normalize( cross(worldNormalN, worldTangent) );
			#endif

			float handednessSign = sign(dot(cross(worldNormalN, worldTangent), worldBitangent));
			worldTangent = worldTangent * handednessSign;
			worldTBN = mat3(worldTangent, worldBitangent, worldNormalN);
		#else
			worldNormal = normalMatrix * modelNormal;
		#endif
	#else
		worldNormal = normalMatrix * modelNormal;
	#endif

	vec4 worldPos = modelMatrix * modelPos;

	shadowTexCoord = shadowMatrix * worldPos;
	#if 1
		shadowTexCoord.xy = shadowTexCoord.xy + 0.5;
	#else
		shadowTexCoord.xy *= (inversesqrt(abs(shadowTexCoord.xy) + shadowParams.zz) + shadowParams.ww);
		shadowTexCoord.xy += shadowParams.xy;
	#endif

	cameraDir = cameraPos - worldPos;

	texCoord = gl_MultiTexCoord0.xy;

	//TODO:
	// 2) flashlights ?
	// 3) treadoffset ?

	gl_Position = projectionMatrix * (viewMatrix * worldPos);

	%%VERTEX_POST_TRANSFORM%%
}