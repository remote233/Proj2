library(tidyverse)
library(caret)
library(e1071)
library(MASS)
library(class)

# helper functions
lr_model <- function(formula, folds, K){
  accuracy = matrix(NA,ncol=2,nrow=K)
  colnames(accuracy) <- c("folds","accuracy")
  accuracy[,1] = sapply(1:K, function(i) paste("folds",i,sep=""))
  for(i in 1:K){
    validation = folds %>% filter(folds==i)
    train = folds %>% filter(folds!=i)
    train_logit = glm(formula,data=train,family = "binomial")
    pred_prob = predict(train_logit, validation, type="response")
    pred = rep(0,length(pred_prob))
    pred[pred_prob>0.5] = 1
    accuracy[i,2] = round(mean(pred==validation$expert_label),3)
  }
  return(accuracy)
}

nb_model <- function(formula, folds, K){
  accuracy = matrix(NA,ncol=2,nrow=K)
  colnames(accuracy) <- c("folds","accuracy")
  accuracy[,1] = sapply(1:K, function(i) paste("folds",i,sep=""))
  for(i in 1:K){
    validation = folds %>% filter(folds==i)
    train = folds %>% filter(folds!=i)
    train_nb = naiveBayes(formula,data=train)
    pred = predict(train_nb, validation)
    accuracy[i,2] = round(mean(pred==validation$expert_label),3)
  }
  return(accuracy)
}

qda_model <- function(formula, folds, K){
  accuracy = matrix(NA,ncol=2,nrow=K)
  colnames(accuracy) <- c("folds","accuracy")
  accuracy[,1] = sapply(1:K, function(i) paste("folds",i,sep=""))
  for(i in 1:K){
    validation = folds %>% filter(folds==i)
    train = folds %>% filter(folds!=i)
    train_qda = qda(formula,data=train)
    pred = predict(train_qda, validation)
    accuracy[i,2] = round(mean(pred$class==validation$expert_label),3)
  }
  return(accuracy)
}

lda_model <- function(formula, folds, K){
  accuracy = matrix(NA,ncol=2,nrow=K)
  colnames(accuracy) <- c("folds","accuracy")
  accuracy[,1] = sapply(1:K, function(i) paste("folds",i,sep=""))
  for(i in 1:K){
    validation = folds %>% filter(folds==i)
    train = folds %>% filter(folds!=i)
    train_lda = lda(formula,train)
    pred = predict(train_lda, validation)
    accuracy[i,2] = round(mean(pred$class==validation$expert_label),3)
  }
  return(accuracy)
}

knn_model <- function(formula, folds, K){
  accuracy = matrix(NA,ncol=2,nrow=K)
  colnames(accuracy) <- c("folds","accuracy")
  accuracy[,1] = sapply(1:K, function(i) paste("folds",i,sep=""))
  for(i in 1:K){
    validation = folds %>% filter(folds==i)
    train = folds %>% filter(folds!=i)
    knn_pred = knn(train[,c("NDAI","SD","CORR")], validation[,c("NDAI","SD","CORR")], train$expert_label, k=10)
    accuracy[i,2] = round(mean(knn_pred==validation$expert_label),3)
  }
  return(accuracy)
}

CVmaster <- function(gen_model, train_feature, train_label, train_folds, K=10){
  form = as.formula(paste(colnames(train_label), paste(colnames(train_feature),collapse = "+"),sep = "~"))
  folds = cbind(train_feature, train_label, train_folds)
  gen_model(form, folds, K)
}

