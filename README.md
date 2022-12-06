# Project2: Cloud Data Classification

## Authors:

-   Yiliang Yuan & Yiyu Lin

## Steps of reproducing paper:

Our projects consist of files including:

-   $\textbf{Proj2.Rmd}$ which contains most of the codes for generating tables and pictures, and some write-ups
-   $\textbf{Data/}$ which contains the three images we were working on
-   $\textbf{Saved_images/}$ which contains all the plots we generated in Proj2.Rmd
-   $\textbf{CVmaster.R}$ which contains the function CVmaster and some helper functions
-   $\textbf{Proj2.docx}$ which is the file that we use to generate the final pdf report

Firstly, we wrote our codes in the Proj2.Rmd and CVmaster.R according to the requirement of this project to generate plots and tables we are going to show. Then, we saved all graphs we plotted in the file Saved_images/ for later use. After that, we moved all of the write-ups in Proj.Rmd files to a word document, and insert graphs and tables we already saved from the Rmd file. After that, we added some labels to the graphs and more write-ups. Finally, we could generate the final pdf report by the word file we wrote.

## CVmaster

In 2(d) of the project, we are asked to write a CVmaster funcion in a separate R script file and use this in the later part. It takes input including:

-   $\textbf{"gen_model"}$ which is a function that will run a specific classifier.
-   $\textbf{train_feature}$ which is a dataframe containing values of features in we want to use for prediction.
-   $\textbf{train_label}$ which is a vector representing the actual value of labels of our training datasets.
-   $\textbf{train_folds}$ which is a vector representing the fold number of each pixels we divided before using the CVmaster function.
-   $\textbf{K}$ which is a integer representing the number of folds we want to use. We set its default value to be 10.

In the CVmaster function, we create a formula for the model and combine three data we input first. Then, we input the formula, combined dataframe and K into the gen_model function to get the CV accuracies across folds.

In the CVmaster.R, we wrote functions of many classifiers which can be used as the gen_model input in the CVmaster function. Each Classifier function will take three inputs, which are:

-   $\textbf{formula}$ which is a formula we can use to build some models. The formula of our project is always "expert_label \~ NDAI+SD+CORR"
-   $\textbf{folds}$ which is a dataframe we got by combining $\textbf{train_feature}$, $\textbf{train_label}$ and $\textbf{train_folds}$ we input in the CVmaster function
-   $\textbf{K}$ which is the number of folds

These classifier functions can help us get the CV accuracies across folds by certain kind of algorithm. Our classifiers include Logistic Regression, Naive Bayes, LDA, QDA, KNN, and XGBoost. For KNN and XGboost, we need to set values for some parameters such as the K for KNN model and max.depth for XGBoost model. We set K=20 for KNN because pixels have spatial dependency so k=20 can be very efficient in creating a good boundary for classification. For XGBoost model, we set the max.depth to be 3 and all other parameters as default because they are generally very good. However, in the Diagnostic part of our project, we will further explore the value of our parameters to see whether we have more optimal choices for those parameters.
