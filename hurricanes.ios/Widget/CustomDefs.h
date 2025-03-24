//
//  CustomDefs.h
//  Hurricane
//
//  Created by Swati Verma on 31/10/14.
//  Copyright (c) 2014 PNSDigital. All rights reserved.
//

//  A file for target-specific values required by today extensions.
//


/***************************************  KPRC   ********************************************/
#if defined(KPRCExtension)
#define kAppURL @"PNSDigitalKPRCHurricane://"
#define kApplicationGroup @"group.grahamdigital.hurricane.kprc"

/***************************************  KSAT   ********************************************/
#elif defined(KSATExtension)
#define kAppURL @"PNSDigitalKSATHurricane://"
#define kApplicationGroup @"group.grahamdigital.hurricane.ksat"

/***************************************  WJXT   ********************************************/
#elif defined(WJXTExtension)
#define kAppURL @"PNSDigitalWJXTHurricane://"
#define kApplicationGroup @"group.grahamdigital.hurricane.wjxt"

/***************************************  WKMG   ********************************************/
#elif defined(WKMGExtension)
#define kAppURL @"PNSDigitalWKMGHurricane://"
#define kApplicationGroup @"group.grahamdigital.hurricane.wkmg"

/***************************************  WPLG   ********************************************/
#elif defined(WPLGExtension)
#define kAppURL @"PNSDigitalWPLGHurricane://"
#define kApplicationGroup @"group.grahamdigital.hurricane.wplg"

/***************************************  Test   ********************************************/
#elif defined(TESTExtension)
#define kAppURL @"PNSDigitalTESTHurricane://"
#define kApplicationGroup @"group.GrahamDigital.TestHurricane"

/***************************************  END   ********************************************/
#endif
