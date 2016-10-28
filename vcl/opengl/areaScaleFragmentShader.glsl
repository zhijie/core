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

vec4 getTexel(int x, int y)
{
    vec2 offset = vec2(x * xsrcconvert, y * ysrcconvert);
    vec4 texel = texture2D(sampler, offset);
#ifdef MASKED
    texel.a = 1.0 - texture2D(mask, offset).r;
#endif
    return texel;
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

    float xlength = fsx2 - fsx1;
    float ylength = fsy2 - fsy1;

    float xStartContribution  = (1.0 - max(0.0, fsx1 - xstart))     / xlength;
    float xMiddleContribution =  1.0 / xlength;
    float xEndContribution    = (1.0 - max(0.0, (xend + 1) - fsx2)) / xlength;

    float yStartContribution  = (1.0 - max(0.0, fsy1 - ystart))     / ylength;
    float yMiddleContribution =  1.0 / ylength;
    float yEndContribution    = (1.0 - max(0.0, (yend + 1) - fsy2)) / ylength;

    vec4 sumAll = vec4(0.0, 0.0, 0.0, 0.0);

    vec2 offset;
    vec4 texel;
    vec4 sumX;

    // First Y pass
    sumX = vec4(0.0, 0.0, 0.0, 0.0);

    sumX += getTexel(xstart, ystart) * xStartContribution;

    for (int x = xstart + 1; x < xend; ++x)
    {
       sumX += getTexel(x, ystart) * xMiddleContribution;
    }

    sumX += getTexel(xend, ystart) * xEndContribution;

    sumAll += sumX * yStartContribution;

    // Middle Y Passes
    for (int y = ystart + 1; y < yend; ++y)
    {
        sumX = vec4(0.0, 0.0, 0.0, 0.0);

        sumX += getTexel(xstart, y) * xStartContribution;

        for (int x = xstart + 1; x < xend; ++x)
        {
            sumX += getTexel(x, y) * xMiddleContribution;
        }

        sumX += getTexel(xend, y) * xEndContribution;

        sumAll += sumX * yMiddleContribution;
    }

    // Last Y pass
    sumX = vec4(0.0, 0.0, 0.0, 0.0);

    sumX += getTexel(xstart, yend) * xStartContribution;

    for (int x = xstart + 1; x < xend; ++x)
    {
        sumX += getTexel(x, yend) * xMiddleContribution;
    }

    sumX += getTexel(xend, yend) * xEndContribution;

    sumAll += sumX * yEndContribution;

    gl_FragColor = sumAll;
}

/* vim:set shiftwidth=4 softtabstop=4 expandtab: */
