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
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
            CBUFFER_END
            

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings vert (Attributes input)
            {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                return output;
            }

            half4 frag (Varyings i) : SV_Target
            {
                // sample the texture
                // half4 col = tex2D(_MainTex, i.uv);
                half4 col = _BaseColor * SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                
                return col;
            }
            ENDHLSL
        }
    }
}
