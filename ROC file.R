alpha=seq(0.01,0.99,0.01)
FPR2=c()
TPR2=c()
for(i in 1:99){
  prob=predict(logm1_2, temp_validation_method1, type="response")
  pred=rep(0,nrow(temp_validation_method1))
  pred[prob>alpha[i]]=1
  
  obs=temp_validation_method1$expert_label
  tablem1_2=table(obs,factor(pred,level=0:1))
  
  ## sum of 1st column is pred's label=0, sum of 2nd column is pred's label=1, 
  FPR2[i]=tablem1_2[1,2]/(tablem1_2[1,1]+tablem1_2[1,2])
  TPR2[i]=tablem1_2[2,2]/(tablem1_2[2,1]+tablem1_2[2,2])
}
plot(x=FPR,y=FPR,col="red")
lines(x=FPR2,y=FPR2, col="blue")