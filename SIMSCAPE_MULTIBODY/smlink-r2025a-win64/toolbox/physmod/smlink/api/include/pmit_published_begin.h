/* Copyright 2004-2015 The MathWorks, Inc. */

#ifndef __pmit_published_begin_h__
#define __pmit_published_begin_h__

#ifdef __cplusplus
extern "C" {
#endif

enum PmitError
{
	PMIT_NO_ERROR = 0,
	PMIT_GENERIC_FAIL,
	PMIT_CAD_MODEL_NOTSET,
	PMIT_XML_DOM_ERROR,
	PMIT_UNHANDLED_CONSTRAIN,
	PMIT_INVALID_CON_COMPS,
	PMIT_UNSUPPORTED_INERTIA_UNIT,
    PMIT_COULDNOT_CONNECTTO_MATLAB
};

enum PmitConstrainType
{
	PMIT_CON_UNKNOWN = -1,
	PMIT_CON_COINCIDENT = 0,
	PMIT_CON_CONCENTRIC,
	PMIT_CON_PERPEND,
	PMIT_CON_PARALLEL,
	PMIT_CON_TANGENT,
	PMIT_CON_DISTANCE,
	PMIT_CON_ANGLE,
    PMIT_CON_FULL,
	PMIT_CON_LAST
};

enum PmitGeomType
{
	PMIT_GEO_UNKNOWN = -1,
	PMIT_GEO_POINT = 0,
	PMIT_GEO_LINE,
	PMIT_GEO_PLANE,
	PMIT_GEO_CYL ,
	PMIT_GEO_CONE,
	PMIT_GEO_CIRCLE,
	PMIT_GEO_LAST
};

static const int PMIT_NO_CONSTRAIN_TYPES = PMIT_CON_LAST;
static const int PMIT_NO_BODY_TYPES = PMIT_GEO_LAST;

enum PmitMassUnit
{
	PMIT_MU_UNKNOWN = -1,
	PMIT_MU_KG = 0,
	PMIT_MU_G,
	PMIT_MU_MG,
	PMIT_MU_LBM,
	PMIT_MU_OZ,
	PMIT_MU_SLUG
};

enum PmitLengthUnit
{
	PMIT_LU_UNKNOWN = -1,
	PMIT_LU_M = 0,
	PMIT_LU_CM,
	PMIT_LU_MM,
	PMIT_LU_KM,
	PMIT_LU_IN,
	PMIT_LU_FT,
	PMIT_LU_MI,
	PMIT_LU_YD
};

typedef struct pmit_vis_mat_prop
{
     double rgb[3];
     double ambient;
     double diffuse;
     double specular;
     double shininess;
     double transparency;
     double emission;
} PmitVisMatProp;

#ifdef __cplusplus
}
#endif

#endif

