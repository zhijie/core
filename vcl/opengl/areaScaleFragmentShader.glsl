/* -*- Mode: C++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This file is part of the LibreOffice project.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

#version 120
#if __VERSION__ < 130
int min( int a, int b ) { return a < b ? a : b; }
float min( float a, float b ) { return a < b ? a : b; }
#endif

uniform sampler2D sampler;
uniform int swidth;
uniform int sheight;
uniform float xscale;
uniform float yscale;
uniform float xsrcconvert;
uniform float ysrcconvert;
uniform float xdestconvert;
uniform float ydestconvert;

varying vec2 tex_coord;

// This mode makes the scaling work like maskedTextureFragmentShader.glsl
// (instead of like plain textureVertexShader.glsl).
#ifdef MASKED
varying vec2 mask_coord;
uniform sampler2D mask;
#endif

float calculateContribution(float fLow, float fHigh, int value)
{
    float start = max(0.0, fLow - value);
    float end   = max(0.0, (value + 1) - fHigh);
    return (1.0 - start - end) / (fHigh - fLow);
}

void main(void)
{
    // Convert to pixel coordinates again.
    int dx = int(tex_coord.s * xdestconvert);
    int dy = int(tex_coord.t * ydestconvert);

    // Compute the range of source pixels which will make up this destination pixel.
    float fsx1 = min(dx * xscale,   float(swidth - 1));
    float fsx2 = min(fsx1 + xscale, float(swidth - 1));

    float fsy1 = min(dy * yscale,   float(sheight - 1));
    float fsy2 = min(fsy1 + yscale, float(sheight - 1));

    // To whole pixel coordinates.
    int xstart = int(floor(fsx1));
    int xend   = int(floor(fsx2));

    int ystart = int(floor(fsy1));
    int yend   = int(floor(fsy2));

#ifdef ARRAY_BASED
    int posX = 0;
    float ratio[16];

    for (int x = xstart; x <= xend; ++x)
    {
        float contributionX = calculateContribution(fsx1, fsx2, x);
        ratio[posX] = contributionX;
        posX++;
    }
#endif

    vec4 sumAll = vec4(0.0, 0.0, 0.0, 0.0);

    for (int y = ystart; y <= yend; ++y)
    {
        vec4 sumX = vec4(0.0, 0.0, 0.0, 0.0);

#ifdef ARRAY_BASED
        posX = 0;
#endif
        for (int x = xstart; x <= xend; ++x)
        {
#ifdef ARRAY_BASED
            float contributionX = ratio[posX];
            posX++;
#else
            float contributionX = calculateContribution(fsx1, fsx2, x);
#endif
            vec2 offset = vec2(x * xsrcconvert, y * ysrcconvert);
            vec4 texel = texture2D(sampler, offset);
#ifdef MASKED
            texel.a = 1.0 - texture2D(mask, offset).r;
#endif
            sumX += texel * contributionX;
        }

        float contributionY = calculateContribution(fsy1, fsy2, y);

        sumAll += sumX * contributionY;
    }

    gl_FragColor = sumAll;
}

/* vim:set shiftwidth=4 softtabstop=4 expandtab: */
