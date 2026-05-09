/* Copyright 2015-2016 The MathWorks, Inc. */
/*******************************************************************************
 ** File: cadsmapi.cpp
 **
 ** Abstract:
 **     API C linkage functions to translate CAD model to a Simscape Multibody
 **     Model.
 **
 ******************************************************************************/
#ifndef pmit_cadsmapi_hpp
#define pmit_cadsmapi_hpp

#ifdef __cplusplus
extern "C" {
#endif

/*!
* Following are the objects used in API functions
*/
typedef struct PmitCadModel_t* PmitCadModelH;
typedef struct PmitCadModelRef_t* PmitCadModelRefH;
typedef struct PmitCad2SM_t* PmitCad2SMH;
typedef struct PmitAssemComp_t* PmitAssemCompH;
typedef struct PmitConstrain_t* PmitConstrainH;
typedef void* PmitObjectH;
typedef struct PmitCadCS_t* PmitCadCSH;

/*!
* Creates a PmitCad2SMH object. PmitCad2SMH is a class that translates CAD model to SimMechanics model.
*/
PmitError pmit_create_cad2sm(PmitCad2SMH* const pmitCad2SMHOut,
                             PmitCadModelH const pmitCadModelH, 
                             const char* createdUsing, 
                             const char* createdFrom,
                             const char* createdOn, 
                             const char* createdBy, 
                             const char* name);

/*!
* Translates and writes translation output of PmitCad2SMH object to an XML file.
* Return error in pconstraintErrorOut, if any. Currently, pconstraintErrorOut
* returns an error only when there is a problem translating one or more constraints.
*/
PmitError pmit_write_xml(char** const pconstraintErrorOut,
                         PmitCad2SMH pmitCad2SMH, 
                         const char* filename);

/*!
* Sets linear, angular, and relative tolerances of PmitCad2SMH object
*/
PmitError pmit_set_tolerances(PmitCad2SMH pmitCad2SMH,
                              double linearTol, 
                              double angularTol, 
                              double relativeTol);

/*!
* Sets current unit used by API function
*/
PmitError pmit_set_units(PmitMassUnit massUnit,
                         PmitLengthUnit lenUnit);

/*!
* Creates PmitCadModelH object. PmitCadModelH is the representation of
* a part and assembly in CAD systems. It requires only data like mass,
* inertia, CG, volume, surface area, and body geometry file name used in SimMechanics.
*/
PmitError pmit_create_cadmodel(PmitCadModelH* const pmitCadModelHOut,
                               const char* name, 
                               double mass, 
                               const double inertia[6], 
                               const double cg[3], 
                               double volume, 
                               double sarea, 
                               const char* fileName,
                               const PmitVisMatProp* matprops);

/*!
* Adds a reference to a child model to a PmitCadModelH object
*/
PmitError pmit_add_refincadmodel(PmitCadModelH pmitCadModelH,
                                 PmitCadModelRefH pmitCadModelrefH);

/*!
* Adds a constraint to the PmitCadModelH object
*/
PmitError pmit_add_constrain(PmitCadModelH pmitCadModelH,
                             PmitConstrainH pmitConstrainH);

/*!
* Sets the body geometry filename of the PmitCadModelH object
*/
PmitError pmit_cadmodel_setfilename(PmitCadModelH pmitCadModelH,
                                    const char* fileName);

/*!
* Creates a PmitCadModelRefH object. A reference to a CadModel can be added
* as a child of another CadModel
*/
PmitError pmit_create_cadmodelref(PmitCadModelRefH* const pmitCadModelRefHOut,
                                  const char* name,
                                  const char* nodeID,
                                  PmitCadModelH pmitCadModelH, 
                                  double rotation[9], 
                                  double trans[3], 
                                  double scale, 
                                  int isFlexible, 
                                  int isFixed,
                                  const PmitVisMatProp* matprops);

/*!
* Gets flexible setting on Cad Model of PmitCadModelRefH object. If a CadModel's flexible setting is 0,
* then all child models and constraints between child models are ignored, and the
* CadModel is represented by a rigid body equivalent of all child bodies of the  
* CadModel.
*/
PmitError pmit_get_refflexibleflag(int* flexFlagOut,
                                   const PmitCadModelRefH cadModelRefH);

/*!
* Sets flexible setting on Cad Model of PmitCadModelRefH object. If a CadModel's flexible setting is set to 0,
* then all child models and constraints between child models are ignored, and the
* CadModel is represented by a rigid body equivalent of all child bodies of the  
* CadModel.
*/
PmitError pmit_set_refflexibleflag(PmitCadModelRefH cadModelRefH,
                                   int flag);

/*!
* Gets fixed flag on a PmitCadModelRefH object. If fixed flag is 1, then the corresponding
* body is welded to the assembly origin through a massless body.
*/
PmitError pmit_get_reffixedflag(int* fixedFlagOut,
                                const PmitCadModelRefH cadModelRefH);

/*!
* Sets fixed flag on a PmitCadModelRefH object. If fixed flag is 1, then the corresponding
* body is welded to the assembly origin through a massless body.
*/
PmitError pmit_set_reffixedflag(PmitCadModelRefH cadModelRefH,
                                int flag);

/*!
* Gets the PmitCadModelH object from the PmitCadModelRefH object. This function can be used
* to get the PmitCadModelH object from the children PmitCadModelRefH object.
*/
PmitError pmit_cadmodelref_getcadmodel(PmitCadModelH* pmitCadModelHOut,
                                       PmitCadModelRefH cadModelRefH);

/*!
* Creates a PmitAssemCompH object. The assembly component is used to reference the
* child CAD model in other model entities like constraints.
*/
PmitError pmit_create_assemcomp(PmitAssemCompH* const pmitAssemCompHOut);

/*!
* Creates a PmitAssemCompH object from its string representation. The string
* representation should be of the form Model1/Model2/Model3 etc.
*/
PmitError pmit_create_assemcomp_fromstr(PmitAssemCompH* const pmitAssemCompHOut,
                                        const char* compName, 
                                        PmitCadModelH parentModelH);

/*!
* Adds a PmitCadModelRefH object to the PmitAssemCompH object at the end. This
* function is used to create the correct assembly component to reference
* in a child model in an assembly.
*/
PmitError pmit_add_refincomp(PmitAssemCompH pmitAssemComp,
                             PmitCadModelRefH pmitCadModelrefH);

/*!
* Creates a PmitConstrainH object in an assembly CadModel
*/
PmitError pmit_create_constrain(PmitConstrainH* const pmitConstrainhOut,
                                const char* name, 
                                PmitConstrainType type, 
                                PmitAssemCompH body1Comp,
                                PmitAssemCompH body2Comp,
                                PmitGeomType body1Type,
                                PmitGeomType body2Type, 
                                const double body1Loc[3],
                                const double body1Axis[3], 
                                const double body2Loc[3],
                                const double body2Axis[3]);

/*!
* Releases the API object. This function is called after 
* an object is used up and no longer needed in client code.
* If an object is created and passed to another API function, then
* also it needs to be released after it is no longer needed.
*/
PmitError pmit_release_object(PmitObjectH objectH);

/*!
* Releases the character buffer returned by API in one of its functions
*/
PmitError pmit_release_buffer(char** buffer);

/*!
* Connects to a MATLAB session. It connects to an exisitng session if MATLAB is started with automation option or
* opens a new MATLAB session.
*/
PmitError pmit_connectto_matlab();

/*!
* Disconnects from a MATLAB session which is used by API function calls
*/
PmitError pmit_disconnectfrom_matlab();

/*!
* Opens the documentation in the MATLAB help system
*/
PmitError pmit_open_help(const char* helpItem);

/*!
* Opens the demo page in MATLAB help system
*/
PmitError pmit_open_demo();

/*!
* Creates a PmitCadCSH object. PmitCadCSH is a class for representing reference 
* coordinate system in CAD applications
*/
PmitError pmit_create_cadcs(PmitCadCSH* const pmitCadCSHOut,
                            const char* name,
                            const char* nodeID,
                            double rotation[9],
                            double trans[3]);

/*!
* Adds a PmitCadCSH object to the PmitCadModelH object
*/
PmitError pmit_add_cadcs(PmitCadModelH pmitCadModelH,
                         PmitCadCSH pmitCadCSH);

#ifdef __cplusplus
}
#endif

#endif /* pmit_cadsmapi_hpp */

