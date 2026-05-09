/*********************************************************************************************************************
 ** File: cadapi_example.cpp
 ** Abstract: 
 **             Example C++ file to demonstrate how to use SMLink API functions
 ** 
 ** Copyright 2007-2008 The MathWorks, Inc.
 *********************************************************************************************************************/

#include "stdio.h"
#include "pmi_api_pub.h"

int main(int argc, char* argv[])
{
    PmitError pmitstatus;

    //Connect to MATLAB session
    printf("Connecting to a MATLAB session...\n");
    pmitstatus = pmit_connectto_matlab();
    if (pmitstatus == PMIT_COULDNOT_CONNECTTO_MATLAB) {
        printf("Error connecting to a MATLAB session.\n");
    } else if (pmitstatus != PMIT_NO_ERROR) {
        printf("An unknown error occurred while connecting to a MATLAB session.\n");
    } else {
        printf("Successfully connected to a MATLAB session.\n");
    }

	//Create top model
	PmitCadModelH cadmodel;
	double cg[3] = { 5.0, 5.0, 5.0 };
	double inertia[6] = { 5.0, 5.0, 5.0, 5.0, 5.0, 5.0 };
	pmitstatus = pmit_create_cadmodel(&cadmodel, "testModel", 20.0, 
												inertia, cg, 500.0, 
                                                200.0, "", 0L);

	//Create fixed child model 1
	PmitCadModelH cadmodelChild1;
	pmitstatus = pmit_create_cadmodel(&cadmodelChild1, "testModelChild", 10.0, 
												inertia, cg, 100.0, 
												100.0, "", 0L);

    PmitVisMatProp matProp;
    matProp.rgb[0] = 1.;
    matProp.rgb[1] = 0.;
    matProp.rgb[2] = 0.;
    matProp.ambient = 0.8;
    matProp.diffuse = 0.8;
    matProp.specular = 0.;
    matProp.shininess = 0.8;
    matProp.transparency = 0.;
    matProp.emission = 0.0;

	double trans[3] = { -5.0, -5.0, -5.0 };
	double rotation[9] = { 1, 0, 0, 0, 1, 0, 0, 0, 1 }; 
	//Create fixed child model 1 ref
	PmitCadModelRefH pmitModelRef1;
	pmitstatus = pmit_create_cadmodelref(&pmitModelRef1, "child model ref", "modelID_1", cadmodelChild1, rotation, trans, 1.0, 0, true, &matProp);
	
	//Create constrained child model 2
	PmitCadModelH cadmodelChild2;
	pmitstatus = pmit_create_cadmodel(&cadmodelChild2, "testModelChild", 10.0, 
												inertia, cg, 100.0, 
												100.0, "", &matProp);

	//Create fixed child model 2 ref
	PmitCadModelRefH pmitModelRef2;
	pmitstatus = pmit_create_cadmodelref(&pmitModelRef2, "child model ref2", "modelID_2" , cadmodelChild2, rotation, trans, 1.0, 0, false, 0L);

	//Add child model 1 ref to top cad model
	pmitstatus = pmit_add_refincadmodel(cadmodel, pmitModelRef1);

	//Add child model 2 ref to top cad model
	pmitstatus = pmit_add_refincadmodel(cadmodel, pmitModelRef2);

	pmit_release_object(cadmodelChild1);
	pmit_release_object(cadmodelChild2);

	//Create component 1
	PmitAssemCompH pmitComp1;
	pmitstatus = pmit_create_assemcomp(&pmitComp1);

	//Add ref in comp1
	pmitstatus = pmit_add_refincomp(pmitComp1, pmitModelRef1);

	//Create component 2
	PmitAssemCompH pmitComp2;
	pmitstatus = pmit_create_assemcomp(&pmitComp2);

	//Add ref in comp2
	pmitstatus = pmit_add_refincomp(pmitComp2, pmitModelRef2);

	pmit_release_object(pmitModelRef2);
	pmit_release_object(pmitModelRef1);

	//Create constraint
	PmitConstrainH constraint;
	double refpoint[3] = {-0.5, -0.5, -0.5};
	double refaxis[3] = {0, 0, 1};
	pmitstatus = pmit_create_constrain(&constraint, "", PMIT_CON_COINCIDENT, 
								   pmitComp1, pmitComp2,
								   PMIT_GEO_PLANE, PMIT_GEO_PLANE, 
								   refpoint, refaxis, 
								   refpoint, refaxis);
	
	//Add constraint
	pmitstatus = pmit_add_constrain(cadmodel, constraint);
	pmit_release_object(constraint);
	pmit_release_object(pmitComp2);
	pmit_release_object(pmitComp1);

  if (pmitstatus == PMIT_NO_ERROR) 
      printf("Successfully created example CAD assembly.\n");
  else {
      printf("Error occurred while creating example CAD assembly.\n");
      return 1;
  }

	//create cad2sm
	PmitCad2SMH cad2SM;
	pmitstatus = pmit_create_cad2sm(&cad2SM, cadmodel, "Test", "Scratch", "", "Devel", "Test Example");

  char* errorOut;
  printf("Exporting CAD assembly to XML file...\n");

  pmitstatus = pmit_write_xml(&errorOut, cad2SM, "cadapi_example.xml");
  if (pmitstatus == PMIT_NO_ERROR) 
      printf("Successfully translated CAD assembly to Simscape Multibody model. The %s file has been written.\n", "cadapi_example.xml");
  else
      printf("Error occurred while translating CAD assembly.\n");
  
  pmit_release_buffer(&errorOut);   

  //release objects
	pmit_release_object(cadmodel);
	pmit_release_object(cad2SM);

  //Disconnect from MATLAB session
  pmitstatus = pmit_disconnectfrom_matlab();
  if (pmitstatus != PMIT_NO_ERROR) {
      printf("Error occurred while disconnecting from MATLAB session.\n");
  } else {
      printf("Successfully disconnected from MATLAB session.\n");
  }

  return 0;
}

