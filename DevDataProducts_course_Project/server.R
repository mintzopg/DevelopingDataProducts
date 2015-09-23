library(shiny)

library(Amelia); library(caret, rattle);library(rpart);library(randomForest);library(e1071)
train <- read.csv("data/train.csv", na.strings = c("NA", "", " ", NULL))
train$Survived <- as.factor(train$Survived)
training <- read.csv("data/training.csv")
training$Survived <- as.factor(training$Survived)

#--------------------- shiny server function ----------------------

shinyServer(function(input, output) {
  output$structure <- renderPrint(str(train))
  output$dfSum <- renderPrint(summary(train[, -c(1, 4)]))
  
  output$plotType <- renderPlot({
  if (input$diagrama == 1){
    missmap(train, main="Titanic Training Data - Missings Map", legend=F)
  } else if (input$diagrama == 2){
    hist(train$Age, main="Age", xlab = NULL, col="brown", density = 20, breaks = 40)
  } else if (input$diagrama == 3) {
    barplot(table(train$Survived), names.arg = c("Died", "Survided"), main="Survived (passenger fate)")
  } else if (input$diagrama == 4) {
    barplot(table(train$Pclass), names.arg = c("1st class", "2nd class", "3rd class"),
            main="Pclass (passenger traveling class)", col="firebrick")
  } else if (input$diagrama == 5) {
    barplot(table(train$Sex), main="Sex (gender)", col=c("pink", "blue"))
  } else if (input$diagrama == 6) {
    barplot(table(train$SibSp), main="SibSp (siblings + spouse aboard)", col="darkblue")
  } else if (input$diagrama == 7) {
    barplot(table(train$Parch), main="Parch (parents + kids aboard)", col="gray50")
  } else if (input$diagrama == 8) {
    mosaicplot(train$Pclass ~ train$Survived, main="Passenger Survival vs Traveling Class", shade=FALSE, 
               color=TRUE, xlab="Pclass", ylab="Survived, 1 = yes / 0 = No")
  } else if (input$diagrama == 9) {
    mosaicplot(train$Sex ~ train$Survived, main="Passenger Fate by Sex", shade=F, 
               color=TRUE, xlab="Sex", ylab="Survived, 1 = yes / 0 = No")
  } else if (input$diagrama == 10) {
    boxplot(train$Age~train$Sex+train$Survived, varwidth = T, names = c("F/Died", "Male/Died", "F/Survived", "M/Survived"), border = c("red", "red", "green", "green"))}
})
  
  #observeEvent(input$view, {output$viewTraining = renderPrint(str(training))})
  output$viewTraining = renderPrint(str(training))
  
  # Train Cart
  output$fit_rpart <- renderPrint({
    set.seed(2)
    inTrain <- createDataPartition(training$Survived, p = input$split, list = F)
    train.set <- training[inTrain, ]
    test.set <- training[- inTrain, ]
    ctr <- rpart.control(cp = input$cp)
    fit1 <- rpart(Survived ~., data = train.set, method = "class", control = ctr)
    p1 <- predict(fit1, test.set, type = "class")
    caret::confusionMatrix(test.set$Survived, p1)
  })
  
  # Train RF
  output$fit_rf <- renderPrint({
    set.seed(5)
    inTrain <- createDataPartition(training$Survived, p = input$split, list = F)
    train.set <- training[inTrain, ]
    test.set <- training[- inTrain, ]
    fit2 <- randomForest(Survived ~., data = train.set, ntree = input$ntree, mtry = input$mtry)
    p2 <- predict(fit2, test.set, type = "class")
    caret::confusionMatrix(test.set$Survived, p2)
  })
  
 } # function
) # shinyServer