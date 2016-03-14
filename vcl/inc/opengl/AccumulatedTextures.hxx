/* -*- Mode: C++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This file is part of the LibreOffice project.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

#ifndef INCLUDED_VCL_INC_OPENGL_ACCUMULATEDTEXTURES_H
#define INCLUDED_VCL_INC_OPENGL_ACCUMULATEDTEXTURES_H

#include <o3tl/make_unique.hxx>
#include "opengl/texture.hxx"
#include <memory>

struct AccumulatedTexturesEntry
{
    OpenGLTexture maTexture;
    std::unordered_map<SalColor, std::vector<SalTwoRect>> maColorTwoRectMap;

    AccumulatedTexturesEntry(const OpenGLTexture& rTexture)
        : maTexture(rTexture)
    {}

    void insert(const SalColor& aColor, const SalTwoRect& r2Rect)
    {
        maColorTwoRectMap[aColor].push_back(r2Rect);
    }
};

class AccumulatedTextures
{
private:
    typedef std::unordered_map<GLuint, std::unique_ptr<AccumulatedTexturesEntry>> AccumulatedTexturesMap;

    AccumulatedTexturesMap maEntries;

public:
    AccumulatedTextures()
    {}

    bool empty()
    {
        return maEntries.empty();
    }

    void clear()
    {
        maEntries.clear();
    }

    void insert(const OpenGLTexture& rTexture, const SalColor& aColor, const SalTwoRect& r2Rect)
    {
        GLuint nTextureId = rTexture.Id();

        auto iterator = maEntries.find(nTextureId);

        if (iterator == maEntries.end())
        {
            maEntries[nTextureId] = o3tl::make_unique<AccumulatedTexturesEntry>(rTexture);
        }

        std::unique_ptr<AccumulatedTexturesEntry>& rEntry = maEntries[nTextureId];
        rEntry->insert(aColor, r2Rect);
    }

    AccumulatedTexturesMap& getAccumulatedTexturesMap()
    {
        return maEntries;
    }
};

#endif // INCLUDED_VCL_INC_OPENGL_TEXTURE_H

/* vim:set shiftwidth=4 softtabstop=4 expandtab: */
