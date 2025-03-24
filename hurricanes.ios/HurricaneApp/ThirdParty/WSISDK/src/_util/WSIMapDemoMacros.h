// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

/*
 Wrap various macros that are GNU extensions with code to enable / disable
 pedantic warning checks.
 The pedantic checks catch some valid issues but also flags these unless we
 disable the warnings here.
 */
#define __PRAGMA_PUSH_NO_GNU_WARNINGS _Pragma("clang diagnostic push") _Pragma("clang diagnostic ignored \"-Wpedantic\"")
#define __PRAGMA_POP_NO_GNU_WARNINGS _Pragma("clang diagnostic pop")

#define MAL_MIN(A,B)\
    __PRAGMA_PUSH_NO_GNU_WARNINGS\
    MIN(A,B)\
    __PRAGMA_POP_NO_GNU_WARNINGS\

#define MAL_MAX(A,B)\
    __PRAGMA_PUSH_NO_GNU_WARNINGS\
    MAX(A,B)\
     __PRAGMA_POP_NO_GNU_WARNINGS\

#define MAL_ABS(A)\
    __PRAGMA_PUSH_NO_GNU_WARNINGS\
    ABS(A)\
     __PRAGMA_POP_NO_GNU_WARNINGS\

/*
 Macros to handle rounding to various types that can change size for 32- vs 64-
 bit builds.
 We do the operation using the double version of the math library functions then
 cast the result (which in the case of a 64-bit build, will have no effect).
 */

#define MAL_CEIL_TO_CGFLOAT(A)      ((CGFloat)ceil(A))
#define MAL_CEIL_TO_NSINTEGER(A)    ((NSInteger)ceil(A))
#define MAL_CEIL_TO_NSUINTEGER(A)   ((NSUInteger)ceil(A))

#define MAL_FLOOR_TO_CGFLOAT(A)     ((CGFloat)floor(A))
#define MAL_FLOOR_TO_NSINTEGER(A)   ((NSInteger)floor(A))
#define MAL_FLOOR_TO_NSUINTEGER(A)  ((NSUInteger)floor(A))

#define MAL_POW_TO_CGFLOAT(A, B)    ((CGFloat)pow((A), (B)))

#define MAL_ROUND_TO_CGFLOAT(A)     ((CGFloat)round(A))
#define MAL_ROUND_TO_NSINTEGER(A)   ((NSInteger)round(A))
#define MAL_ROUND_TO_NSUINTEGER(A)  ((NSUInteger)round(A))

// trigonometric
#define MAL_COS_TO_CGFLOAT(A)       ((CGFloat)cos(A))
#define MAL_SIN_TO_CGFLOAT(A)       ((CGFloat)sin(A))
#define MAL_TAN_TO_CGFLOAT(A)       ((CGFloat)tan(A))

