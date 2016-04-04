/* -*- Mode: C++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This file is part of the LibreOffice project.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

#ifndef INCLUDED_VCL_INC_OPENGL_PACKEDTEXTUREATLAS_HXX
#define INCLUDED_VCL_INC_OPENGL_PACKEDTEXTUREATLAS_HXX

#include "opengl/texture.hxx"

struct PackedTexture;

class VCL_PLUGIN_PUBLIC PackedTextureAtlasManager
{
    std::vector<std::unique_ptr<PackedTexture>> maPackedTextures;

    int mnTextureWidth;
    int mnTextureHeight;

    void CreateNewTexture();

public:
    PackedTextureAtlasManager(int nTextureWidth, int nTextureHeight);
    ~PackedTextureAtlasManager();
    OpenGLTexture InsertBuffer(int nWidth, int nHeight, int nFormat, int nType, sal_uInt8* pData);
    OpenGLTexture Reserve(int nWidth, int nHeight);
};

#endif // INCLUDED_VCL_INC_OPENGL_PACKEDTEXTUREATLAS_HXX

/* vim:set shiftwidth=4 softtabstop=4 expandtab: */
