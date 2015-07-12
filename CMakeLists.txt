PROJECT(pumpkin C)

CMAKE_MINIMUM_REQUIRED(VERSION 3.0)
CMAKE_POLICY(VERSION 3.0)

# Includes
LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
INCLUDE(FindVala)
INCLUDE(ValaPrecompile)

# Find packages
FIND_PACKAGE(PkgConfig REQUIRED)
FIND_PACKAGE(Vala REQUIRED)
PKG_CHECK_MODULES(DEPS REQUIRED glib-2.0>=2.38 gtk+-3.0 libnotify webkit2gtk-4.0 libsoup-2.4 json-glib-1.0)

# Find resource compiler
FIND_PROGRAM(GLIB_COMPILE_RESOURCES NAMES glib-compile-resources)
IF(NOT GLIB_COMPILE_RESOURCES)
MESSAGE(FATAL "Could not find glib-compile-resources")
ENDIF()

# Definitions
ADD_DEFINITIONS(${DEPS_CFLAGS} ${DEPS_CFLAGS_OTHER})
LINK_LIBRARIES(${DEPS_LIBRARIES})
LINK_DIRECTORIES(${DEPS_LIBRARY_DIRS})

# Compile resources
SET(RESOURCES
    data/pumpkin.gresource.xml
    data/ui/window.ui
    data/ui/tab-label.ui
    data/ui/notebook.ui
)
SET(GRESOURCE ${CMAKE_SOURCE_DIR}/data/pumpkin.gresource.xml)
SET(RESOURCE_FILE ${PROJECT_BINARY_DIR}/resource.c)

ADD_CUSTOM_COMMAND(
    OUTPUT ${RESOURCE_FILE}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/data
    COMMAND ${GLIB_COMPILE_RESOURCES}
        --generate-source
        --target=${RESOURCE_FILE}
        ${GRESOURCE}
    DEPENDS
        ${GRESOURCE}
        ${RESOURCES}
)

ADD_CUSTOM_TARGET(resource
    DEPENDS
        ${RESOURCE_FILE}
        ${RESOURCES}
)

# Precompile Vala
VALA_PRECOMPILE(VALA_C ${PROJECT_NAME}
    src/pumpkin.vala
    src/pumpkin-application.vala
    src/pumpkin-application-window.vala
    src/pumpkin-notebook.vala
    src/pumpkin-tab-label.vala
    src/pumpkin-google-completion.vala
    src/pumpkin-util.vala
PACKAGES
    posix
    libnotify
    gtk+-3.0
    glib-2.0
    webkit2gtk-4.0
    libsoup-2.4
    json-glib-1.0
OPTIONS
    --target-glib=2.38
GRESOURCES
    ${GRESOURCE}
DEPENDS
    ${RESOURCE_FILE}
    ${RESOURCES}
)

# Set properties
SET_SOURCE_FILES_PROPERTIES(${RESOURCE_FILE} PROPERTIES GENERATED 1)

# Create executable
ADD_EXECUTABLE(${PROJECT_NAME}
    ${VALA_C} ${RESOURCE_FILE}
)

INSTALL(TARGETS pumpkin RUNTIME DESTINATION bin)
INSTALL(FILES ${CMAKE_SOURCE_DIR}/data/pumpkin.desktop DESTINATION share/applications)