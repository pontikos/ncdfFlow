# TODO: Add comment
# 
# Author: mike
###############################################################################





setMethod("rbind2",
		signature=c(x="ncdfFlowSet",
				y="ncdfFlowSet"),
		definition=function(x, y,ncdfFile=tempfile(pattern = "ncfs"))
		{
			env <- new.env(hash=TRUE, parent=emptyenv())
			env2<-new.env(hash=TRUE, parent=emptyenv())
			lx <- sampleNames(x)
			ly <- sampleNames(y)
			if(any(lx %in% ly))
				stop("These ncdfFlowSets contain overlapping samples.")
			pd1 <- phenoData(x)
			pd2 <- phenoData(y)
			if(!all(varLabels(pd1) == varLabels(pd2)))
				stop("The phenoData of the two ncdfFlowSets doesn't match.",
						call.=FALSE)
			if(!all(colnames(x)==colnames(y)))
				stop("The colnames of the two ncdfFlowSets doesn't match.",
						call.=FALSE)
			#new ncdf object 
			#make sure we put the new nc file in the same path as the old ncfile
#			newNcFile = ncdfFlow:::.guid()
#			newNcFile<-paste(dirname(x@file),newNcFile,sep="/")
			newNcFile<-ncdfFile
			if (!length(grep(".", newNcFile, fixed = TRUE)))  
				newNcFile <- paste(newNcFile, "nc", sep = ".")
			
			
			##init the environment slots to be able to pass the validity check of flowSet object
			for(i in lx)
			{
				assign(i, x@frames[[i]], env=env)
				assign(i, NA, env=env2)

			}
			for(i in ly)
			{
				
				assign(i, y@frames[[i]], env=env)
				assign(i, NA, env=env2)
			}
#			
			#create ncdf ncdf object 
			ncfs<-new("ncdfFlowSet"
						,file = newNcFile
						,colnames = colnames(x) 
						,frames = env
						,maxEvents=max(x@maxEvents,y@maxEvents)
						,flowSetId = ""
						,phenoData=AnnotatedDataFrame(rbind(pData(pd1), pData(pd2)))
						,indices=env2
						,origSampleVector=c(lx,ly)##need to assign the sample vector before add the actual frame
						,origColnames=colnames(x)
						)
			
			#create new ncdf file		
			#NOTE: rbind2 will not save the metadata in the new file..	
			msgCreate <- try(.Call(dll$createFile, newNcFile, as.integer(ncfs@maxEvents), 
							as.integer(length(colnames(ncfs))), as.integer(length(ncfs)),
							as.integer(0),as.logical(FALSE)),silent = TRUE)
			if(!msgCreate)stop(msgCreate)
			 
			
#			
			#add frames to env and ncdf file
			for(i in lx)
			{
				ncfs[[i]] <- x[[i]]
			}
			for(i in ly)
			{
				ncfs[[i]] <- y[[i]]
			}				
			#Comment out sync for metadata
			#ncdfFlowSet_sync(ncfs)
			
			
			
			
			return(ncfs)
		})
##this method is removed because it is pointless to add a flowFrame 
#without specifying the phenoData with the same structure as the existing ncdfFlowSet 
setMethod("rbind2",
		signature=c(x="ncdfFlowSet",
				y="flowFrame"),
		definition=function(x,y)
		{
			## create dummy phenoData
#			pd <- phenoData(x)[1,]
#			sampleNames(pd)
#			pData(pd)[1,] <- NA
#			
#			ncfs <- as(y,"flowSet")
#			sampleNames(pd) <- sampleNames(tmp) <- "anonymous frame"
#			phenoData(tmp) <- pd
#			rbind2(x, ncfs)
			warning("Please convert the flowFrame to ncdfFlowSet with the appropriate phenoData and then use rbind2 to combine the two ncdfFlowSets!")
			return(NULL)
		})
#do rbind for > 2 ncdfFlowSets (without the need to create cdf for every two ncfs)
setMethod("rbind2",
		signature=c("ncdfFlowList"),
		definition=function(x,ncdfFile=tempfile(pattern = "ncfs"))
		{
			
#			nclist<-x@datalist
			nclist<-x

			sn <-unlist(lapply(nclist, sampleNames, level = 1),use.names=F)
			isDuplicated<-duplicated(sn)
			if(any(isDuplicated))
				stop("duplicated samples:",sn[isDuplicated])
			
			
			pdlist <- lapply(nclist,phenoData, level = 1)
			
			
			varLabelList<-lapply(pdlist,varLabels)
			
			isDuplicated<-duplicated(varLabelList)
			isSame<-isDuplicated[-1]
			if(!all(isSame))
				stop("The phenoData of the ncdfFlowSets don't match.",
						call.=FALSE)
			
			collist <- lapply(nclist,colnames, level = 1)
			isDuplicated<-duplicated(collist)
			isSame<-isDuplicated[-1]
			if(!all(isSame))
				stop("The colnames of the ncdfFlowSets don't match.",
						call.=FALSE)
			
			#new ncdf object 
			#make sure we put the new nc file in the same path as the old ncfile

           
              
            
  			newNcFile<-ncdfFile
  			if (!length(grep(".", newNcFile, fixed = TRUE)))  
  				newNcFile <- paste(newNcFile, "nc", sep = ".")
  			
  			
  			##init the environment slots to be able to pass the validity check of flowSet object
  			frameEnv <- new.env(hash=TRUE, parent=emptyenv())
  			indiceEnv<-new.env(hash=TRUE, parent=emptyenv())
  			lapply(nclist,function(ncfs){
  								oldFrames<-ncfs@frames
  								copyEnv(oldFrames,frameEnv)
  				#				assign(i, nclist[[1]]@frames[[i]], env=env)
  									
  								lapply(ls(oldFrames),function(curSample)assign(curSample, NA, env=indiceEnv))
  								
  							}, level = 1)
  #			browser()
  			pdataList<-lapply(pdlist,pData)
  			newPd<-AnnotatedDataFrame(do.call(base::rbind,pdataList))
  			
  			
  			#create ncdf ncdf object 
  			ncfs<-new("ncdfFlowSet"
  					,file = newNcFile
  					,colnames = collist[[1]] 
  					,frames = frameEnv
  					,maxEvents=max(unlist(lapply(nclist,function(ncfs)ncfs@maxEvents, level = 1)))
  					,flowSetId = ""
  					,phenoData=newPd
  					,indices=indiceEnv
  					,origSampleVector=sn##need to assign the sample vector before add the actual frame
  					,origColnames=collist[[1]]
  			)
  			
            if(file.exists(newNcFile)){
              #it is useful to skip creating cdf file and only deal with in-memory merging
              #when the cdf file is already generated by the previous run
              message("Using the existing nc file: ",ncdfFile)
              
            }else{
    			#create new ncdf file		
    			#NOTE: rbind2 will not save the metadata in the new file..	
    			msgCreate <- try(.Call(dll$createFile, newNcFile, as.integer(ncfs@maxEvents), 
    							as.integer(length(colnames(ncfs))), as.integer(length(ncfs)),
    							as.integer(0),as.logical(FALSE)),silent = TRUE)
    			if(!msgCreate)stop(msgCreate)
    			
    			
    			
    			#add frames to env and ncdf file
    			for(nc in nclist@data)
    			{
    			
    				for(curSample in sampleNames(nc))
    				{	
    					ncfs[[curSample]] <- nc[[curSample]]
    				}	
    			}
	
          }				
			#Comment out sync for metadata
			#ncdfFlowSet_sync(ncfs)
			
			
			return(ncfs)
		})
