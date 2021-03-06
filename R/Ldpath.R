
## make sure system.file returns an absolute path
ncdfFlow.system.file <- function(pkg , ...){
	
    tools:::file_path_as_absolute( base:::system.file( ..., package = pkg ) )
}

## identifies if the default linking on the platform should be static
## or dynamic. Currently only linux uses dynamic linking by default
## although it works fine on mac osx as well
staticLinking <- function() {
    ! grepl( "^linux", R.version$os )
}

## Use R's internal knowledge of path settings to find the lib/ directory
## plus optinally an arch-specific directory on system building multi-arch
ncdfFlowLdPath <- function(pkg) {
  
    if (nzchar(.Platform$r_arch)) {	## eg amd64, ia64, mips
        path <- ncdfFlow.system.file("lib", pkg = pkg, .Platform$r_arch)
    } else {
        path <- ncdfFlow.system.file("lib", pkg = pkg)
    }
    path
}

## Provide linker flags -- i.e. -L/path/to/libncdfFlow -- as well as an
## optional rpath call needed to tell the Linux dynamic linker about the
## location.  This is not needed on OS X where we encode this as library
## built time (see src/Makevars) or Windows where we use a static library
## Updated Jan 2010:  We now default to static linking but allow the use
##                    of rpath on Linux if static==FALSE has been chosen
##                    Note that this is probably being called from LdFlags()
ncdfFlowLdFlags <- function(static=staticLinking(), pkg = "ncdfFlow") {
    ncdfFlowdir <- ncdfFlowLdPath(pkg)
    if (static) {                               # static is default on Windows and OS X
        flags <- paste(ncdfFlowdir, "/lib", pkg,".a", sep="")
#        #if (.Platform$OS.type=="windows") {
#        #    flags <- shQuote(flags)
#        #}
    } else {					# else for dynamic linking
        flags <- paste("-L", ncdfFlowdir, " -l", pkg, ",", sep="") # baseline setting
#        if ((.Platform$OS.type == "unix") &&    # on Linux, we can use rpath to encode path
#            (length(grep("^linux",R.version$os)))) {
          if (.Platform$OS.type == "unix") {
            flags <- paste(flags, " -Wl,-rpath,", ncdfFlowdir, sep="")
        }
    }
    invisible(flags)
}

# indicates if ncdfFlow was compiled with GCC >= 4.3
canUseCXX0X <- function() .Call( "canUseCXX0X", PACKAGE = "ncdfFlow" )

## Provide compiler flags -- i.e. -I/path/to/ncdfFlow.h
ncdfFlowCxxFlags <- function(cxx0x=FALSE) {
    # path <- ncdfFlowLdPath()
    path <- ncdfFlow.system.file( "include" )
    #if (.Platform$OS.type=="windows") {
    #    path <- shQuote(path)
    #}
    paste("-I", path, if( cxx0x && canUseCXX0X() ) " -std=c++0x" else "", sep="")
}

## Shorter names, and call cat() directly
## CxxFlags defaults to no using c++0x extensions are these are considered non-portable
CxxFlags <- function(cxx0x=FALSE) {
    cat(ncdfFlowCxxFlags(cxx0x=cxx0x))
}
## LdFlags defaults to static linking on the non-Linux platforms Windows and OS X
LdFlags <- function(static=staticLinking()) {
    cat(ncdfFlowLdFlags(static=static))
}

# capabilities
ncdfFlowCapabilities <- capabilities <- function() .Call("capabilities", PACKAGE = "ncdfFlow")

# compile, load and call the cxx0x.c script to identify whether
# the compiler is GCC >= 4.3
ncdfFlowCxx0xFlags <- function(){
    script <- ncdfFlow.system.file( "discovery", "cxx0x.R" )
    flag <- capture.output( source( script ) )
    flag
}

Cxx0xFlags <- function() cat( ncdfFlowCxx0xFlags() )

