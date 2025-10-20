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
  min10float time;
  min10float scale;
};

#define ENABLE_BOOST 1
#define BRIGHTNESS 1.0F
#define BOOST_SIGMA 0.6F

#define ENABLE_FILM_GRAIN 1
#define NOISE_STRENGTH 0.2F

#define ENABLE_SCANLINE 1
#define SCANLINE_FACTOR 0.4F

#define ENABLE_FLICKER 0

min10float4 applyGaussianBoost(min10float4 color) {
    static min10float scaledGaussianSigma = BOOST_SIGMA * scale;
    static min10float inverseSigmaSquared = 1.0F / (scaledGaussianSigma * scaledGaussianSigma);

    static min10float gaussianExp = exp(-0.5F * inverseSigmaSquared);
    static min10float gaussianExpSquared = gaussianExp * gaussianExp;

#if ENABLE_SCANLINE
    static min10float luminanceBoostFactor = (BRIGHTNESS + SCANLINE_FACTOR) * (3.582F / scaledGaussianSigma) * gaussianExpSquared;
#else
    static min10float luminanceBoostFactor = (BRIGHTNESS) * (3.582F / scaledGaussianSigma) * gaussianExpSquared;
#endif

    color += color * luminanceBoostFactor;

    return color;
}

min10float4 applyFilmGrain(min10float4 color, min10float2 tex) {
    min10float grainMix = lerp(1, frac(sin(dot((tex + time * min10float2(0.123f, 1.123f)), min10float2(12.9898f, 78.233f))) * 43758.5453f), NOISE_STRENGTH);

    color *= grainMix;

    return color;
}

min10float4 applyScanlineMask(min10float4 color, min10float4 pos) {
    min10float scanlinePhase = frac(pos.y / (scale * 2.0f));
    min10float scanlineWeight = 1 - (step(0.5f, scanlinePhase) * SCANLINE_FACTOR);

    color *= scanlineWeight;

    return color;
}

min10float4 applyFlicker(min10float4 color) {
    static min10float grainMix = lerp(1, frac(sin(dot((time * min10float2(0.123f, 1.123f)), min10float2(12.9898f, 78.233f))) * 43758.5453f), NOISE_STRENGTH);

    color *= grainMix;

    return color;
}

min10float4 main(min10float4 pos : SV_POSITION, min10float2 tex : TEXCOORD) : SV_TARGET {
    min10float4 color = shaderTexture.Sample(samplerState, tex);

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
