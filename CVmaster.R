
library(tidyverse) 
library(caret)

CVmaster <- function(gen_c,train_feature,train_label,K=10,loss_function){
  form = as.formula(paste(colnames(train_label), paste(colnames(train_feature),collapse = "+"),sep = "~"))
  df = cbind(train_label,train_feature)
  df$expert_label = as.factor(df$expert_label)
  tr_method = trainControl(method = "cv", number = 10, savePredictions=TRUE)
  if(gen_c == "glm")
    fit_train = train(form, data=df, method=gen_c, trControl = tr_method, family="binomial")
  else
    fit_train = train(form, data=df, method=gen_c, trControl = tr_method)
  pred_result <- fit_train$pred
  loss_function(pred_result)
}