# setwd("~/Downloads")

setwd("C:/Users/Edgano/Desktop")

# df <- read.table("data - Sheet2.csv", header=TRUE, sep=",")
df <- read.table("data - top20 (1).csv", header=TRUE, sep=",")


avgGapVar=df$AVGgapXseq
tcScoreVar=df$tc

scatter.smooth(x=avgGapVar, y=tcScoreVar, main="TC ~ Gap")  # scatterplot


##Using Density Plot To Check If Response Variable Is Close To Normal

library(e1071)  # for skewness function
par(mfrow=c(1, 2))  # divide graph area in 2 columns

plot(density(avgGapVar), main="Density Plot: avgGap", ylab="Frequency", sub=paste("Skewness:", round(e1071::skewness(avgGapVar), 2)))  # density plot for 'speed'

polygon(density(avgGapVar), col="red")

plot(density(tcScoreVar), main="Density Plot: TC score", ylab="Frequency", sub=paste("Skewness:", round(e1071::skewness(tcScoreVar), 2)))  # density plot for 'dist'

polygon(density(tcScoreVar), col="red")

##

cor(avgGapVar, tcScoreVar)  # calculate correlation between speed and distance 
# [1] -0.4027615

##linear regression
linearMod <- lm(tc ~ AVGgapXseq, data=df)  # build linear regression model on full data
print(linearMod)

summary(linearMod)


##
# https://community.rstudio.com/t/multiple-linear-regression-lines-in-a-graph-with-ggplot2/9328
##

#install.packages("ggplot2")
library(ggplot2)
#install.packages("plotly")
library(plotly)



#df_select <- df %>% filter(family == "gluts")
#gluts<-ggplot(df_select, aes(AVGgapXseq, tc, shape=aligner, colour=tree)) +
  #geom_smooth(method="lm") +
  #geom_point(size = 4)+
  #theme_bw() + 
  #xlab("% Gap") +
  ##ylab("TC score") +
  ##ggtitle("TC - Gap accuracy") + 
  ##expand_limits(y=0) ##+
  ##scale_y_continuous(breaks = 0:100) + 
  ##scale_x_continuous(breaks = 0:1)

#ggplotly(gluts)






#######
###### GENERATE ALL PLOTS IN A LIST
#######

province_list=list()
for (i in unique(df$tree)) {
  
  province_number <- paste("tree",i)
  prov_filter <- filter(df, tree == i)
  #print(prov_filter)
  
  plot <- ggplot(prov_filter, aes(AVGgapXseq, tc, color=aligner)) + 
    #geom_smooth(method="lm") +
    geom_point(size = 4)+
    theme_bw() + 
    #xlab("% Gap") +
    #ylab("TC score") +
    ggtitle(paste(i)) + 
    expand_limits(y=0)+
    scale_x_continuous(breaks = seq(0.6, 1, 0.2)) +
    theme(legend.position = "none")
  
  #filename=paste(province_number,".pdf",sep="")
  
  province_list[[i]] = plot
  #print(plot)
}

province_list[[1]]

####
####
## FINALLY WORK!!!
####
####

temp_legend <- ggplot(prov_filter, aes(AVGgapXseq, tc, color=aligner)) + 
  #geom_smooth(method="lm") +
  geom_point(size = 4)+
  theme_bw() + 
  #xlab("% Gap") +
  #ylab("TC score") +
  ggtitle(paste(i)) + 
  expand_limits(y=0)+
  scale_x_continuous(breaks = seq(0.6, 1, 0.2)) +
  theme(legend.direction = "horizontal", 
        legend.position = "bottom")

library(gridExtra)
# create get_legend function
get_legend<-function(myggplot){
  tmp <- ggplot_gtable(ggplot_build(myggplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)
}

# Extract legend using get_legend function
legend <- get_legend(temp_legend)

main <- grid.arrange(grobs=province_list,ncol=3, bottom=legend)
main
