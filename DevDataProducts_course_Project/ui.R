library(shiny)
library(shinythemes)

shinyUI(fluidPage(
  theme = shinytheme("flatly"),
  titlePanel("Titanic: Machine learning from disaster"),
  
  navlistPanel(selected = "Summary",
#------------------------------------------------------------------------------------------------------    
  "Introduction",
             
    tabPanel("Summary", 
                  
    tags$strong("Georgios Mintzopoulos. Coursera MOOC 'Developing Data Products, Course Project'"), hr(),
                        
     p("The sinking of the RMS Titanic is one of the most infamous shipwrecks in history.  On April 15, 1912, during her maiden voyage, the Titanic sank after colliding with an iceberg, killing 1502 out of 2224 passengers and crew. This sensational tragedy shocked the international community and led to better safety regulations for ships."), br(),
                        
     p("One of the reasons that the shipwreck led to such loss of life was that there were not enough lifeboats for the passengers and crew. Although there was some element of luck involved in surviving the sinking, some groups of people were more likely to survive than others, such as women, children, and the upper-class."), br(),
                        
     p("In this exercise as provided in Kaggle (www.kaggle.com), we want to analyze what sorts of people were likely to survive. We will do some data preproceesing and apply a couple of machine learning algorithms to predict which passengers survived the tragedy."), br(),
                        
     p("The data is highly structured, but there are some preprocessing steps performed prior to the final model implementation."), 
                        
     p("The purpose of this project is to utilize the shiny package to produce an App in the context of Coursera MOOC, Developing Data Products. We use regarding the actual machine learning problem an approach that is simple enough to fit its purpose. Therefore we use out of the box algorithms offered by R, using mostly the default tuning values."),
     hr(), tags$a("https://www.kaggle.com/c/titanic")),
#------------------------------------------------------------------------------------------------------
 "Exploratory Analysis",
               
 tabPanel("Data Summary", 
  h4('Structure of training data set'),
  verbatimTextOutput("structure"), br(),
  h4('Summary of variables that have interest as predictors'),
  verbatimTextOutput("dfSum")),
               
 tabPanel("Plots",
  radioButtons("diagrama", "Select Plot", choices = list(
    "Missing Values" = 1, "Age distribution" = 2, "Who Survived" = 3, "Travelling Class" = 4, "Sex" = 5, "Sib/Sp" = 6, "Parents" = 7, "Survived per Class" = 8, "Survived per Sex" = 9, "Age and Sex of Survivors" = 10), selected = 1),
  plotOutput("plotType")),
#------------------------------------------------------------------------------------------------------
 "Data-Wrangling",
               
 tabPanel("Description of Actions",
   tags$ul(
     tags$li("Variable Survived is the response variable and was coerced to a factor "),
     tags$li("Missing Data were found in Variables 'Age', 'Cabin' and 'Embarked'. Only variable Age from them was kept as a predictor in this exercise"),
     tags$li("Replaced missing male Ages according median value for groups Survived vs Perished"),
     tags$li("Replaced missing female Ages with median of ages for groups Mrs vs Miss"),
     tags$li("Standardize variables Age, Fare")), hr(),
   em("The wrangled dataset has the structure ..."), hr(),
   #actionLink("view", "View Training set"),
   verbatimTextOutput("viewTraining")),
#-------------------------------------------------------------------------------------------------------
 "Fit Models",
               
 tabPanel('Training information',
  p("For this application we will utilize only a very limited number of the available tuning parmaters that we can possibly use for simplicity. The input parameters will be chosen as:"),
  tags$ol(
    tags$li("A test set will be produced by splitting the train test in two sets by some percenatge. The default us 80% training vs 20% test split of the original data."),
     tags$li("Model Specific parameters per algorithm as following:")), hr(),
  tags$pre("model = 'rpart', Type: Regression, Classification, Tuning Parameters: cp (Complexity Parameter)"), hr(),
  tags$pre("model = 'rf', Type: Regression, Classification, Tuning Parameters: mtry (#Randomly Selected Predictors), ntree (Number of trained trees"), br(),
  p("A model will be trained on the train test set. Then a prediction will be done on the response varibale of the test set, and the accuracy of this prediction is checked against the actual test set respone values. The results are presented in a confusion matrix.")),
               
 tabPanel("Baseline",
  h4('Baseline, description:'), hr(),
  p('This is the most likely class prediction (Positive class is 0). In our case we have:'), br(),
  em('891 passengers, of which 549 perished and 342 survived. The baseline prediction is therefore perished with accuracy 542/891 = 61%  and Survived with 39%'), hr()),
               
 tabPanel("CART",
  h4('Classification and Regression Tree:'), hr(),
  p('Classification and regression trees (as described by Brieman, Freidman, Olshen, and Stone) can be generated through the rpart package. The general steps are:'), br(),
  tags$b('1. Grow the Tree'),
  p('To grow a tree, use ...'),
  tags$code('rpart(formula, data, weights, subset, na.action = na.rpart, method, model = FALSE, x = FALSE, y = TRUE, parms, control, cost, ...)'),
  p('where formula	is in the format outcome ~ predictor1+predictor2+predictor3+ect. data=	specifies the data frame,  method=	"class" for a classification tree or "anova" for a regression tree, control=	optional parameters for controlling tree growth.'), br(),
  tags$b('2. Examine the results'),
  p('The following functions help us to examine the results. printcp(fit)	display cp table. plotcp(fit)	plot cross-validation results. rsq.rpart(fit)	plot approximate R-squared and relative error for different splits. print(fit)	print results. summary(fit)	detailed results including surrogate splits. plot(fit)	plot decision tree. text(fit)	label the decision tree plot. post(fit, file=)	create postscript plot of decision tree'), br(),
  tags$b('3. Prune tree'),
  p('Prune back the tree to avoid overfitting the data.'), hr(),
  strong(em('References:')), br(),
  a('https://cran.r-project.org/web/packages/rpart/index.html'), br(),hr(),
  em("Select options:"),
  wellPanel(
    sliderInput("split", "Train/Test set Split %", min = .66, max = .95, value = .80),
    sliderInput("cp", "Complexity parameter", min = .01, max = 1.0, value = .01),
    #submitButton(text = "Train CART", icon = NULL), br(),
    verbatimTextOutput("fit_rpart"))),
               
tabPanel("Random Forest", 
  h4('Random Forests'), hr(),
  p('Random forests improve predictive accuracy by generating a large number of bootstrapped trees (based on random samples of variables), classifying a case using each tree in this new "forest", and deciding a final predicted outcome by combining the results across all of the trees (an average in regression, a majority vote in classification). Breiman and Cutler\'s random forest approach is implimented via the randomForest package.'),
  tags$code("Usage:  randomForest(formula, data=NULL, ..., subset, na.action=na.fail)"),
  p("The parameters we will modify will be:"),
  em("mtry:  Number of variables randomly sampled as candidates at each split. Note that the default values are different for classification (sqrt(p) where p is number of variables in x) and regression (p/3)"), br(),
  em("ntree:  Number of trees to grow. This should not be set to too small a number, to ensure that every input row gets predicted at least a few times"), br(), hr(),
  strong(em('References')), br(),
  tags$a("http://oz.berkeley.edu/users/breiman/Using_random_forests_V3.1.pdf"), br(),
  tags$a("https://cran.r-project.org/web/packages/randomForest/index.html"),hr(), br(),
  em("Select options:"),
  wellPanel(
    sliderInput("split", "Train/Test set Split %", min = .66, max = .95, value = .80),
    sliderInput("ntree", "Number of Trees", min = 100, max = 1000, step = 10, value = 500),
    sliderInput("mtry", "mtry", min = 1, max = 6, step = 1, value = 2),
    #submitButton(text = "Train Random Forest", icon = NULL)), br(),
    verbatimTextOutput("fit_rf")))
               
  ) # end of navlistPanel
 ) # end of fluidPage
) # end of shinyUI

