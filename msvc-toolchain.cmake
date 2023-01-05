if(VBAM_STATIC_CRT)
    set(runtime "/MT")
else()
    set(runtime "/MD")
endif()

if(X86_32)
    set(ADDITIONAL_RELEASE_FLAGS "")
else()
    if(CMAKE_CXX_COMPILER_ID STREQUAL MSVC)
        set(ADDITIONAL_RELEASE_FLAGS "/Ob3")
    endif()
endif()

set(ADDITIONAL_FLAGS "")
if(ENABLE_LTO)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        set(ADDITIONAL_FLAGS "/GL")
        set(ADDITIONAL_LINKER_FLAGS "/LTCG")
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        string(APPEND ADDITIONAL_RELEASE_FLAGS " -flto -fuse-ld=lld -fsplit-lto-unit")
    endif()
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL MSVC AND NOT CMAKE_GENERATOR MATCHES "Ninja")
    string(APPEND ADDITIONAL_FLAGS " /MP")
endif()

set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:DEBUG>:Debug>$<$<NOT:$<BOOL:${VBAM_STATIC_CRT}>>:DLL>" CACHE INTERNAL "")

set(PREPROCESSOR_FLAGS "/D_FORCENAMELESSUNION /DWIN32_LEAN_AND_MEAN /DWIN32 /D_WINDOWS /D__STDC_LIMIT_MACROS /D__STDC_CONSTANT_MACROS /D_CRT_SECURE_NO_WARNINGS")

set(CMAKE_CXX_FLAGS "/nologo ${PREPROCESSOR_FLAGS} /GR /EHsc /W4 /std:c++17 ${ADDITIONAL_FLAGS}" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS "/nologo ${PREPROCESSOR_FLAGS} /W4 /std:c11 ${ADDITIONAL_FLAGS}" CACHE STRING "" FORCE)
set(CMAKE_RC_FLAGS "-c65001 /DWIN32" CACHE STRING "" FORCE)

set(CMAKE_CXX_FLAGS_DEBUG "/D_DEBUG /DDEBUG ${runtime}d /ZI /Ob0 /Od /RTC1" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_DEBUG "/D_DEBUG /DDEBUG ${runtime}d /ZI /Ob0 /Od /RTC1" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_RELEASE "/DNDEBUG ${runtime} /O2 /Oi /Gy /Zi ${ADDITIONAL_RELEASE_FLAGS}" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_RELEASE "/DNDEBUG ${runtime} /O2 /Oi /Gy /Zi ${ADDITIONAL_RELEASE_FLAGS}" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "/DNDEBUG ${runtime} /O2 /Ob1 /Oi /Gy /Zi" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_RELWITHDEBINFO "/DNDEBUG ${runtime} /O2 /Ob1 /Oi /Gy /Zi" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_MINSIZEREL "/DNDEBUG ${runtime} /O1 /Ob1 /Oi /Gy /Zi" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_MINSIZEREL "/DNDEBUG ${runtime} /O1 /Ob1 /Oi /Gy /Zi" CACHE STRING "" FORCE)

foreach(link_var IN ITEMS EXE SHARED MODULE)
    string(APPEND CMAKE_${link_var}_LINKER_FLAGS " ${ADDITIONAL_LINKER_FLAGS}")
    set(CMAKE_${link_var}_LINKER_FLAGS "${CMAKE_${link_var}_LINKER_FLAGS}" CACHE STRING "" FORCE)
    set(CMAKE_${link_var}_LINKER_FLAGS_RELEASE "/DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF" CACHE STRING "" FORCE)
endforeach()

list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES VBAM_STATIC_CRT ENABLE_LTO)
