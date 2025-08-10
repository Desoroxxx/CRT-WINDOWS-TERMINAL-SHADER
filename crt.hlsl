// -------------------------- CRT WINDOWS TERMINAL SHADER --------------------------
//
// ╔═╗╦═╗╔╦╗  ╦ ╦╦╔╗╔╔╦╗╔═╗╦ ╦╔═╗  ╔╦╗╔═╗╦═╗╔╦╗╦╔╗╔╔═╗╦   ╔═╗╦ ╦╔═╗╔╦╗╔═╗╦═╗
// ║  ╠╦╝ ║───║║║║║║║ ║║║ ║║║║╚═╗───║ ║╣ ╠╦╝║║║║║║║╠═╣║───╚═╗╠═╣╠═╣ ║║║╣ ╠╦╝
// ╚═╝╩╚═ ╩   ╚╩╝╩╝╚╝═╩╝╚═╝╚╩╝╚═╝   ╩ ╚═╝╩╚═╩ ╩╩╝╚╝╩ ╩╩═╝ ╚═╝╩ ╩╩ ╩═╩╝╚═╝╩╚═
//
// A CRT shader for the Windows Terminal.
//
// Default settings are for a readable but still stylized look.
//
// Trying to balance looks and performance.
// The film grain and flicker effects are very expensive,
// they require constant redraw of the terminal.
//
// A lot of this is probably not the best, as it is my first time writing HLSL.
// Also, I am not that great at math, and this was done under 4 hours.
//
// Originally based on "CRT Shader Effect for Windows Terminal" by Lorgar Horusov.
//
// @author Luna Mira Lage
// @version 1.0
// @see https://github.com/Lorgar-Horusov/Retro-Windows-Terminal
// @see https://github.com/microsoft/terminal/blob/main/samples/PixelShaders
// ---------------------------------------------------------------------------------

Texture2D shaderTexture;
SamplerState samplerState;

cbuffer PixelShaderSettings {
  float  time;
  float  scale;
};

#define ENABLE_BOOST 1
#define BRIGHTNESS 1.0F
#define BOOST_SIGMA 0.6F

#define ENABLE_FILM_GRAIN 1
#define NOISE_STRENGTH 0.2F

#define ENABLE_SCANLINE 1
#define SCANLINE_FACTOR 0.4F

#define ENABLE_FLICKER 0

float4 applyGaussianBoost(float4 color) {
    static float scaledGaussianSigma = BOOST_SIGMA * scale;
    static float inverseSigmaSquared = 1.0F / (scaledGaussianSigma * scaledGaussianSigma);

    static float gaussianExp = exp(-0.5F * inverseSigmaSquared);
    static float gaussianExpSquared = gaussianExp * gaussianExp;

#if ENABLE_SCANLINE
    static float luminanceBoostFactor = (BRIGHTNESS + SCANLINE_FACTOR) * (3.582F / scaledGaussianSigma) * gaussianExpSquared;
#else
    static float luminanceBoostFactor = (BRIGHTNESS) * (3.582F / scaledGaussianSigma) * gaussianExpSquared;
#endif

    color += color * luminanceBoostFactor;

    return color;
}

float4 applyFilmGrain(float4 color, float2 tex) {
    float grainMix = lerp(1, frac(sin(dot((tex + time * float2(0.123f, 1.123f)), float2(12.9898f, 78.233f))) * 43758.5453f), NOISE_STRENGTH);

    color *= grainMix;

    return color;
}

float4 applyScanlineMask(float4 color, float4 pos) {
    float scanlineWeight = 1 - (floor(pos.y / scale) % 2) * SCANLINE_FACTOR;

    color *= scanlineWeight;

    return color;
}

float4 applyFlicker(float4 color) {
    static float grainMix = lerp(1, frac(sin(dot((time * float2(0.123f, 1.123f)), float2(12.9898f, 78.233f))) * 43758.5453f), NOISE_STRENGTH);

    color *= grainMix;

    return color;
}

float4 main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET {
    float4 color = shaderTexture.Sample(samplerState, tex);

#if ENABLE_BOOST
    color = applyGaussianBoost(color);
#endif
#if ENABLE_FILM_GRAIN
    color = applyFilmGrain(color, tex);
#endif
#if ENABLE_SCANLINE
    color = applyScanlineMask(color, pos);
#endif
#if ENABLE_FLICKER
    color = applyFlicker(color);
#endif

    return color;
}