#ifndef PRELOAD_RSC //set to:
#define PRELOAD_RSC 1 // 0 to allow using external resources or on-demand behaviour;
#endif // 1 to use the default behaviour;
								// 2 for preloading absolutely everything;

// If this is uncommented, will attempt to load prof.dll (windows) or libprof.so (unix)
// byond-tracy is not shipped with CM code. Build it yourself here: https://github.com/mafemergency/byond-tracy/
//#define BYOND_TRACY

#ifdef CIBUILDING
#define UNIT_TESTS
#endif

#ifdef CITESTING
#define TESTING
#endif

#if defined(UNIT_TESTS)
//Hard del testing defines
#define REFERENCE_TRACKING
#define REFERENCE_TRACKING_DEBUG
#define FIND_REF_NO_CHECK_TICK
#define GC_FAILURE_HARD_LOOKUP
//Ensures all early assets can actually load early
#define DO_NOT_DEFER_ASSETS
#endif

#ifdef TGS
// TGS performs its own build of dm.exe, but includes a prepended TGS define.
#define CBT
#endif

#if !defined(CBT) && !defined(SPACEMAN_DMM) && !defined(OPENDREAM)
#warn Building with Dream Maker is no longer supported and will result in errors.
#warn In order to build, run BUILD.bat in the bin directory.
#warn Consider switching to VSCode editor instead, where you can press Ctrl+Shift+B to build.
#endif

//#define UNIT_TESTS //If this is uncommented, we do a single run though of the game setup and tear down process with unit tests in between

// #define TESTING
// #define REFERENCE_TRACKING
// #define GC_FAILURE_HARD_LOOKUP

#if DM_BUILD < 1493
#define length_char(args...) length(args)
#define text2ascii_char(args...) text2ascii(args)
#define copytext_char(args...) copytext(args)
#define splittext_char(args...) splittext(args)
#define spantext_char(args...) spantext(args)
#define nonspantext_char(args...) nonspantext(args)
#define findtext_char(args...) findtext(args)
#define findtextEx_char(args...) findtextEx(args)
#define findlasttext_char(args...) findlasttext(args)
#define findlasttextEx_char(args...) findlasttextEx(args)
#define replacetext_char(args...) replacetext(args)
#define replacetextEx_char(args...) replacetextEx(args)
// /regex procs
#define Find_char(args...) Find(args)
#define Replace_char(args...) Replace(args)
#endif
