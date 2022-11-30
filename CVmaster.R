
library(tidyverse) 
library(caret)

CVmaster <- function(gen_c,train_feature,train_label,K=10,loss_function){
  form = as.formula(paste(colnames(train_label), paste(colnames(train_feature),collapse = "+"),sep = "~"))
  df = cbind(train_label,train_feature)
  df$expert_label = as.factor(df$expert_label)
  tr_method = trainControl(method = "cv", number = 10, savePredictions=TRUE)
  fit_train = train(form, data=df, method=gen_c, trControl = tr_method)
  pred_result <- fit_train$pred
  obs <- pred_result$obs
  pred <- pred_result$pred
  pred_result$equal <- ifelse(pred == obs, 1,0)
  loss_function(pred,obs)
}