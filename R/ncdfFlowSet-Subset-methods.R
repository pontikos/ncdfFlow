

###"select" is channel 
setMethod("Subset",
		signature=signature(x="ncdfFlowSet",
				subset="filterResultList"),
		definition=function(x, subset, select, ...)
		{
			flowCore:::validFilterResultList(subset, x, strict=FALSE)

			ncfs<-clone.ncdfFlowSet(x,isNew=FALSE)

			for(i in names(subset)) {
					
					rawIndice<-getIndices(x,i)
					localIndice<-as(subset[[i]],"logical")
#					
					##update original indice vector with the new subset indice which is shorter than original one
					if(all(is.na(rawIndice)))
						rawIndice<-localIndice
					else
						rawIndice[which(rawIndice)]<-localIndice
					updateIndices(x=ncfs,y=i,z=rawIndice)
					#update channel info if necessary
					if(!missing(select))
					{
						expr1<-paste("ncfs@frames$'",i,"'@parameters@data <-subset(x[[i]]@parameters@data,name%in%select)",sep="")
						eval(parse(text=expr1))
						
					}
			}
			if(!missing(select))
				ncfs@colnames<-select
			ncfs
		})
    
setMethod("Subset",
    signature=signature(x="ncdfFlowList",
        subset="filterResultList"),
    definition=function(x, subset, select, ...)
    {
      
#      browser()
      if(missing(select))select <- NULL
      
      res <- lapply(x, function(fs){
            
            this_subset <- subset[sampleNames(fs)]
            if(is.null(select))
              Subset(fs,this_subset, ...)
            else
              Subset(fs, this_subset, select, ...)
          },level = 1)
      res <- as(res, "ncdfFlowList")
      res@samples <- x@samples
      res
    })    
    
###"select" is channel 
setMethod("Subset",
		signature=signature(x="ncdfFlowSet",
				subset="filter"),
		definition=function(x, subset, ...)
		{
			fr <- filter(x,subset)
			Subset(x,fr,...)
		})
setMethod("Subset",
    signature=signature(x="ncdfFlowList",
        subset="filter"),
    definition=function(x, subset, ...)
    {
      selectMethod("Subset", signature = c("ncdfFlowSet", "filter"))(x, subset, ...)
      
    })
    
			

setMethod("Subset",
		signature=signature(x="ncdfFlowSet",
				subset="list"),
		definition=function(x, subset, select, ...)
		{
			
			if(is.null(names(subset)))
				stop("Filter list must have names to do something reasonable")
			nn <- names(subset)
			sn <- sampleNames(x)
			unused <- nn[!(nn %in% sn)]
			notfilter <- sn[!(sn %in% nn)]
			##Do some sanity checks
			if(length(unused) > 0)
				warning(paste("Some filters were not used:\n",
								paste(unused,sep="",collapse=", ")), call.=FALSE)
			if(length(notfilter) > 0)
				warning(paste("Some frames were not filtered:\n",
								paste(notfilter,sep="",collapse=", ")),
						.call=FALSE)	
			if(length(x) != length(subset))
				stop("You must supply a list of the same length as the ncdfFlowSet.")
			used <- nn[nn %in% sn]
			
			ncfs<-clone.ncdfFlowSet(x,isNew=FALSE)
			for(i in used) {
#				
				rawIndice<-getIndices(x,i)
				localIndice<-as(subset[[i]],"logical")
				##update original indice vector with the new subset indice which is shorter than original one
				if(all(is.na(rawIndice)))
					rawIndice<-localIndice
				else
					rawIndice[which(rawIndice)]<-localIndice
					
				updateIndices(ncfs,i,rawIndice)
				#update channel info if necessary
				if(!missing(select))
				{
					expr1<-paste("ncfs@frames$",i,"@parameters@data <-subset(x[[i]]@parameters@data,name%in%select)",sep="")
					eval(parse(text=expr1))
					
				}
			}
			if(!missing(select))
				ncfs@colnames<-select
#			phenoData(ncfs) <- phenoData(x)
			
			return(ncfs)
		})

