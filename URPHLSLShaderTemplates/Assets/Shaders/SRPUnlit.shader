/************************************************************************************
 * SRPUnlit.shader
 * --------------------------
 * This is a simple unlit shader that displays a texture with a color tint. It supports SRP batching by the CBUFFER code block
 */

 Shader "ShaderTemplates/SRPUnlit"
 {
     Properties
     {
         // _MainTex ("Texture", 2D) = "white" {}
         _BaseMap("BaseTexture", 2D) = "white" {}
         _BaseColor("BaseColor", Color) = (1,1,1,1)
     }
     SubShader
     {
         Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline"}
 //        LOD 100
         
         Pass
         {
             Name "Forward"
             Tags { "LightMode" = "UniversalForward" }
 
             Cull Back
             ZWrite On
 
             HLSLPROGRAM
             #pragma exclude_renderers gles gles3 glcore
             #pragma target 4.5
             #pragma vertex vert
             #pragma fragment frag
 
             #pragma multi_compile_instancing
             #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
             // The following line of code is covered by multi_compile_instancing
             // #pragma multi_compile _ DOTS_INSTANCING_ON
 
             #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
 
             TEXTURE2D(_BaseMap);             SAMPLER(sampler_BaseMap);
 
             CBUFFER_START(UnityPerMaterial)
                 half4 _BaseColor;
                 float4 _BaseMap_ST;
             CBUFFER_END
 
             #ifdef UNITY_DOTS_INSTANCING_ENABLED
                 UNITY_INSTANCING_BUFFER_START(MaterialPropertyMetadata)
                     UNITY_DOTS_INSTANCED_PROP(float4, _BaseColor)
                 UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

                // Simple way to access instanced properties in shaders, if no property set found, it will use the default value
                //  #define _BaseColor UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4, _BaseColor)
                // But, We do not use this since it can cause the compiler to regenerate the property loading code for each use of _BaseColor.

                // To avoid this, the property loads are cached in some static values at the beginning of the shader.
                // The properties such as _BaseColor are then overridden so that it expand directly to the static value like this:
                // #define _BaseColor unity_DOTS_Sampled_BaseColor
                //
                // This simple fix happened to improve GPU performances by ~10% on Meta Quest 2 with URP on some scenes.
                 
                static float4 unity_DOTS_Sampled_BaseColor;

                void SetupDOTSLitMaterialPropertyCaches()
                {
                    // Still, in Unity6000.0.32f1, UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT only takes floats not halfs, so shader can only use float
                    unity_DOTS_Sampled_BaseColor            = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4, _BaseColor);
                }

                #undef UNITY_SETUP_DOTS_MATERIAL_PROPERTY_CACHES
                #define UNITY_SETUP_DOTS_MATERIAL_PROPERTY_CACHES() SetupDOTSLitMaterialPropertyCaches()
                
                #define _BaseColor              unity_DOTS_Sampled_BaseColor
             #endif
             
 
             struct Attributes
             {
                 float4 positionOS : POSITION;
                 float2 uv : TEXCOORD0;
                 UNITY_VERTEX_INPUT_INSTANCE_ID
             };
 
             struct Varyings
             {
                 float4 positionHCS : SV_POSITION;
                 float2 uv : TEXCOORD0;
                 UNITY_VERTEX_INPUT_INSTANCE_ID
             };
 
             Varyings vert (Attributes input)
             {
                 Varyings output;
 
                 UNITY_SETUP_INSTANCE_ID(input);
                 UNITY_TRANSFER_INSTANCE_ID(input, output);
 
                 output.positionHCS = TransformObjectToHClip(input.positionOS);
                 output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                 return output;
             }
 
             half4 frag (Varyings input) : SV_Target
             {
                 UNITY_SETUP_INSTANCE_ID(input);
                 half4 col = _BaseColor * SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                 
                 return col;
             }
             ENDHLSL
         }
     }
 }
 