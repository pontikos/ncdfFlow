\name{read.ncdfFlowSet}
\alias{read.ncdfFlowSet}
\title{
create ncdfFlowSet from FCS files
}
\description{
read FCS files from the disk and load them into a ncdfFlowSet object 
}
\usage{
read.ncdfFlowSet(files = NULL,ncdfFile,flowSetId,
	isWriteSlice=TRUE,isSaveMeta=FALSE,phenoData,channels=NULL,...) 
}
\arguments{
  
  \item{files}{ A character vector giving the source FCS raw file paths.}
  
  \item{ncdfFile}{A character scalar giving the output file name. Default is NULL and the function will generate a random
    file in the temporary folder, potentially adding the \code{.cdf} suffix unless a file
    extension is already present. It is sometimes useful to specify this file path to avoid the failure of writing large flow data set to cdf file 
    due to the the shortage of disk space in system temporary folder. 
    It is only valid when isNewNcFile=TRUE }
    
  \item{flowSetId}{ A character scalar giving the unique ncdfFlowSet ID.}
  
  \item{isWriteSlice}{A logical scalar indicating whether the raw data should also be copied.if FALSE,
  				an empty cdf file is created with the dimensions (sample*events*channels) supplied by raw FCS files. }
  
  \item{isSaveMeta}{A logical scalar indicating whether the meta data other than raw data should be saved in cdf.
  					It should be set as TRUE if the entire ncdfFlowSet is going to be loaded by \code{\link{ncdfFlowSet_open,character-method}}.
  					}
  \item{phenoData}{An object of \code{AnnotatedDataFrame} providing a way to manually set the phenotyoic data for the whole data set in ncdfFlowSet.}
  
  \item{channels}{ A character vector specifying which channels to extract from FCS files.
  					It can be useful when FCS files do not share exactly the same channel names.
  					Thus this argument is used to select those common channels that are of interests.
  					Default value is NULL and the function will try to scan the FCS headers of all files
  					and determine the common channels.
  			}
  \item{...}{extra arguments to be passed to \code{\link{read.FCS}}.}
    					
}

\value{
  
  A ncdfFlowSet object
  
}

\author{
Mike Jiang,Greg Finak,N.Gopalakrishnan


Maintainer: Mike Jiang <wjiang2@fhcrc.org>
}

\seealso{\code{\link{clone.ncdfFlowSet}}}

\examples{
library(ncdfFlow)

path<-system.file("extdata","compdata","data",package="flowCore")
files<-list.files(path,full.names=TRUE)[1:3]

#create ncdfFlowSet from fcs with the actual raw data written in cdf
nc1  <- read.ncdfFlowSet(isSaveMeta=FALSE,files=files,ncdfFile="ncfsTest.nc",flowSetId="fs1",isWriteSlice= TRUE)
nc1
nc1[[1]]
ncfsUnlink(nc1)
rm(nc1)

#create empty ncdfFlowSet from fcs and add data slices afterwards
nc1  <- read.ncdfFlowSet(files=files,ncdfFile="ncfsTest.nc",flowSetId="fs1",isWriteSlice= FALSE)
fs1<-read.flowSet(files)
nc1[[1]] <- fs1[[1]]
nc1[[1]]
nc1[[2]]

}
\keyword{IO}

