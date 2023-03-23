/*
 * AUTOGENERATED DON'T EDIT
 * Please make changes to the code generator (distutils/ccompiler_opt.py)
*/
#define NPY_WITH_CPU_BASELINE  "NEON NEON_FP16 NEON_VFPV4 ASIMD"
#define NPY_WITH_CPU_DISPATCH  "ASIMDHP ASIMDDP ASIMDFHM"
#define NPY_WITH_CPU_BASELINE_N 4
#define NPY_WITH_CPU_DISPATCH_N 3
#define NPY_WITH_CPU_EXPAND_(X) X
#define NPY_WITH_CPU_BASELINE_CALL(MACRO_TO_CALL, ...) \
	NPY_WITH_CPU_EXPAND_(MACRO_TO_CALL(NEON, __VA_ARGS__)) \
	NPY_WITH_CPU_EXPAND_(MACRO_TO_CALL(NEON_FP16, __VA_ARGS__)) \
	NPY_WITH_CPU_EXPAND_(MACRO_TO_CALL(NEON_VFPV4, __VA_ARGS__)) \
	NPY_WITH_CPU_EXPAND_(MACRO_TO_CALL(ASIMD, __VA_ARGS__))
#define NPY_WITH_CPU_DISPATCH_CALL(MACRO_TO_CALL, ...) \
	NPY_WITH_CPU_EXPAND_(MACRO_TO_CALL(ASIMDHP, __VA_ARGS__)) \
	NPY_WITH_CPU_EXPAND_(MACRO_TO_CALL(ASIMDDP, __VA_ARGS__)) \
	NPY_WITH_CPU_EXPAND_(MACRO_TO_CALL(ASIMDFHM, __VA_ARGS__))
/******* baseline features *******/
	/** NEON **/
	#define NPY_HAVE_NEON 1
	#include <arm_neon.h>
	/** NEON_FP16 **/
	#define NPY_HAVE_NEON_FP16 1
	/** NEON_VFPV4 **/
	#define NPY_HAVE_NEON_VFPV4 1
	/** ASIMD **/
	#define NPY_HAVE_ASIMD 1

/******* dispatch features *******/
#ifdef NPY__CPU_TARGET_ASIMDHP
	/** ASIMDHP **/
	#define NPY_HAVE_ASIMDHP 1
#endif /*NPY__CPU_TARGET_ASIMDHP*/
#ifdef NPY__CPU_TARGET_ASIMDDP
	/** ASIMDDP **/
	#define NPY_HAVE_ASIMDDP 1
#endif /*NPY__CPU_TARGET_ASIMDDP*/
#ifdef NPY__CPU_TARGET_ASIMDFHM
	/** ASIMDFHM **/
	#define NPY_HAVE_ASIMDFHM 1
#endif /*NPY__CPU_TARGET_ASIMDFHM*/

