library(tidyverse)
library(caret)
library(e1071)
library(MASS)
library(class)
library(xgboost)
# helper functions
lr_model <- function(formula, folds, K){
  accuracy = matrix(NA,ncol=2,nrow=K+1)
  colnames(accuracy) <- c("folds","lr_accuracy")
  accuracy[,1] = c(sapply(1:K, function(i) paste("folds",i,sep="")), "Avg Accuracy")
  for(i in 1:K){
    validation = folds %>% filter(folds==i)
    train = folds %>% filter(folds!=i)
    train_logit = glm(formula,data=train,family = "binomial")
    pred_prob = predict(train_logit, validation, type="response")
    pred = rep(0,length(pred_prob))
    pred[pred_prob>0.5] = 1
    accuracy[i,2] = round(mean(pred==validation$expert_label),3)
  }
  accuracy[K+1,2] = mean(as.double(accuracy[1:K,2]))
  accuracy = as.data.frame(accuracy)
  return(accuracy)
}

nb_model <- function(formula, folds, K){
  accuracy = matrix(NA,ncol=2,nrow=K+1)
  colnames(accuracy) <- c("folds","nb_accuracy")
  accuracy[,1] = c(sapply(1:K, function(i) paste("folds",i,sep="")), "Avg Accuracy")
  for(i in 1:K){
    validation = folds %>% filter(folds==i)
    train = folds %>% filter(folds!=i)
    train_nb = naiveBayes(formula,data=train)
    pred = predict(train_nb, validation)
    accuracy[i,2] = round(mean(pred==validation$expert_label),3)
  }
  accuracy[K+1,2] = mean(as.double(accuracy[1:K,2]))
  accuracy = as.data.frame(accuracy)
  return(accuracy)
}

qda_model <- function(formula, folds, K){
  accuracy = matrix(NA,ncol=2,nrow=K+1)
  colnames(accuracy) <- c("folds","qda_accuracy")
  accuracy[,1] = c(sapply(1:K, function(i) paste("folds",i,sep="")), "Avg Accuracy")
  for(i in 1:K){
    validation = folds %>% filter(folds==i)
    train = folds %>% filter(folds!=i)
    train_qda = qda(formula,data=train)
    pred = predict(train_qda, validation)
    accuracy[i,2] = round(mean(pred$class==validation$expert_label),3)
  }
  accuracy[K+1,2] = mean(as.double(accuracy[1:K,2]))
  accuracy = as.data.frame(accuracy)
  return(accuracy)
}

lda_model <- function(formula, folds, K){
  accuracy = matrix(NA,ncol=2,nrow=K+1)
  colnames(accuracy) <- c("folds","lda_accuracy")
  accuracy[,1] = c(sapply(1:K, function(i) paste("folds",i,sep="")), "Avg Accuracy")
  for(i in 1:K){
    validation = folds %>% filter(folds==i)
    train = folds %>% filter(folds!=i)
    train_lda = lda(formula,train)
    pred = predict(train_lda, validation)
    accuracy[i,2] = round(mean(pred$class==validation$expert_label),3)
  }
  accuracy[K+1,2] = mean(as.double(accuracy[1:K,2]))
  accuracy = as.data.frame(accuracy)
  return(accuracy)
}

knn_model <- function(formula, folds, K){
  accuracy = matrix(NA,ncol=2,nrow=K+1)
  colnames(accuracy) <- c("folds","knn_accuracy")
  accuracy[,1] = c(sapply(1:K, function(i) paste("folds",i,sep="")), "Avg Accuracy")
  for(i in 1:K){
    validation = folds %>% filter(folds==i)
    train = folds %>% filter(folds!=i)
    knn_pred = knn(train[,c("NDAI","SD","CORR")], validation[,c("NDAI","SD","CORR")], train$expert_label, k=20)
    accuracy[i,2] = round(mean(knn_pred==validation$expert_label),3)
  }
  accuracy[K+1,2] = mean(as.double(accuracy[1:K,2]))
  accuracy = as.data.frame(accuracy)
  return(accuracy)
}

XGBoost_model <- function(formula, folds, K){
  accuracy = matrix(NA,ncol=2,nrow=K+1)
  colnames(accuracy) <- c("folds","xgb_accuracy")
  accuracy[,1] = c(sapply(1:K, function(i) paste("folds",i,sep="")), "Avg Accuracy")
  for(i in 1:K){
    validation = folds %>% filter(folds==i)
    train = folds %>% filter(folds!=i)
    xgb_train = xgb.DMatrix(data = data.matrix(train[,c("NDAI","SD","CORR")]), label = train$expert_label)
    xgb_validation = xgb.DMatrix(data = data.matrix(validation[,c("NDAI","SD","CORR")]), label = validation$expert_label)
    watchlist = list(train=xgb_train, test=xgb_validation)
    #find the value of rounds which have the least test MSE
    model = xgb.train(data = xgb_train, max.depth = 3, watchlist=watchlist, nrounds = 1000, verbose = 0)
    final_rounds = as.integer(model$evaluation_log[which.min(test_rmse),1])
    train_xgb = xgboost(data = xgb_train, max.depth = 3, nrounds = final_rounds, verbose = 0)
    pred_prob = predict(train_xgb, xgb_validation)
    pred = rep(0,length(pred_prob))
    pred[pred_prob>0.5] = 1
    accuracy[i,2] = round(mean(pred==validation$expert_label),3)
  }
  accuracy[K+1,2] = mean(as.double(accuracy[1:K,2]))
  accuracy = as.data.frame(accuracy)
  return(accuracy)
}

CVmaster <- function(gen_model, train_feature, train_label, train_folds, K=10){
  form = as.formula(paste(colnames(train_label), paste(colnames(train_feature),collapse = "+"),sep = "~"))
  folds = cbind(train_feature, train_label, train_folds)
  gen_model(form, folds, K)
}

